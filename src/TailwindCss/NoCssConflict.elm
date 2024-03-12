module TailwindCss.NoCssConflict exposing
    ( rule
    , Options, defaultOptions
    )

{-|

@docs rule
@docs Options, defaultOptions

-}

import Dict exposing (Dict)
import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.Node exposing (Node)
import Review.Rule as Rule exposing (Rule)
import Set exposing (Set)
import TailwindCss.CheckedFunction as CheckedFunction exposing (CheckedFunction)
import TailwindCss.Internal as Internal


{-| Reports if two classes in a class list modify the same css properties.
This avoids some weird behaviour like the order of classes in the stylesheet being relevant.

    config =
        [ TailwindCss.NoCssConflict.rule { props = classProps, checkedFunctions = [checkClassFunction] }
        ]

    It is not recommended to define the `props` option manually. Instead you can use the [postcss-plugin](https://www.npmjs.com/package/elm-review-tailwindcss-postcss-plugin)
    to generate the Elm code for you and then you can just import the `classProps` in your `ReviewConfig.elm` file.


## Fail

    a =
        class "p-2 p-4 flex"


## Success

    a =
        "p-2 flex"


## When (not) to enable this rule

This rule is useful when your CSS classes are generally really small and composable.
This rule is not useful when you want to override properties of other classes explicitely.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template anmolitor/elm-review-tailwindcss/example --rules TailwindCss.NoCssConflict
```

-}
rule : Options -> Rule
rule options =
    Rule.newModuleRuleSchemaUsingContextCreator "TailwindCss.NoCssConflict" (initialContext options)
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| Options for the NoCssConflict rule.

    props:               should be generated from the postcss plugin
    checkedFunctions:    a list of function calls to check for css conflicts

-}
type alias Options =
    { props : Dict String (Set String)
    , checkedFunctions : List CheckedFunction
    }


{-| Provide required options and defaults the other options
-}
defaultOptions : { props : Dict String (Set String) } -> Options
defaultOptions { props } =
    { props = props
    , checkedFunctions = [ CheckedFunction.class, CheckedFunction.classList ]
    }


type alias Context =
    { props : Dict String (Set String)
    , checkedFunctions : List CheckedFunction
    }


initialContext : Options -> Rule.ContextCreator () Context
initialContext options =
    Rule.initContextCreator
        (\() ->
            options
        )


expressionVisitor : Node Expression -> Context -> ( List (Rule.Error {}), Context )
expressionVisitor =
    let
        runCheck ctx range classString =
            let
                classNames =
                    String.split " " classString
                        |> List.filter (not << String.isEmpty)

                modifiers className =
                    String.split ":" className
                        |> List.tail
                        |> Maybe.withDefault []
                        |> Set.fromList

                classNamesWithMetadata =
                    List.map
                        (\className ->
                            { name = className
                            , props =
                                Dict.get className ctx.props |> Maybe.withDefault Set.empty
                            , modifiers = modifiers className
                            }
                        )
                        classNames
            in
            uniquePairs classNamesWithMetadata
                |> List.concatMap
                    (\( c1, c2 ) ->
                        let
                            propsIntersection =
                                Set.intersect c1.props c2.props

                            modifierEquality =
                                c1.modifiers == c2.modifiers
                        in
                        if Set.isEmpty propsIntersection || not modifierEquality then
                            []

                        else
                            [ Rule.error
                                (Internal.cssConflictError
                                    { conflictingClasses = ( c1.name, c2.name ), conflictingProperties = Set.toList propsIntersection }
                                )
                                range
                            ]
                    )
    in
    Internal.expressionVisitor runCheck


uniquePairs : List a -> List ( a, a )
uniquePairs xs =
    case xs of
        [] ->
            []

        x :: xs_ ->
            List.map (\y -> ( x, y )) xs_ ++ uniquePairs xs_
