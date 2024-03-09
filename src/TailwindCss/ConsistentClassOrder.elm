module TailwindCss.ConsistentClassOrder exposing
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
import Review.Fix as Fix
import Review.Rule as Rule exposing (Rule)
import TailwindCss.CheckedFunction as CheckedFunction exposing (CheckedFunction)
import TailwindCss.Internal as Internal


{-| Reports if a css class string does not adhere to the [recommended class order](https://tailwindcss.com/blog/automatic-class-sorting-with-prettier#how-classes-are-sorted)

    config =
        [ TailwindCss.ConsistentClassOrder.rule { order = classOrder, checkedFunctions = [checkClassFunction] }
        ]

    It is not recommended to define the `order` option manually. Instead you can use the [postcss-plugin](https://www.npmjs.com/package/elm-review-tailwindcss-postcss-plugin)
    to generate the Elm code for you and then you can just import the `classOrder` in your `ReviewConfig.elm` file.


## Fail

    a =
        class "flex absolute"


## Success

    a =
        class "absolute flex"


## When (not) to enable this rule

This rule is useful when you are using tailwindcss and the recommended class order helps you read and understand the code faster.
This rule is not useful when you are not using tailwindcss, you do not care in which order the classes are, or you disagree with the recommended order.


## Try it out

You can try this rule out by adding the [postcss-plugin](https://www.npmjs.com/package/elm-review-tailwindcss-postcss-plugin) to your postcss.config.js
and running the following command:

```bash
elm-review --template anmolitor/elm-review-tailwindcss/example --rules TailwindCss.ConsistentClassOrder
```

Executing postcss (via your bundler for example) should generate the needed files in your /review directory
so that the template compiles.

-}
rule : Options -> Rule
rule order =
    Rule.newModuleRuleSchemaUsingContextCreator "TailwindCss.ConsistentClassOrder" (initialContext order)
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.providesFixesForModuleRule
        |> Rule.fromModuleRuleSchema


{-| Options for the ConsistentClassOrder rule.

    order:               should be generated from the postcss plugin
    checkedFunctions:    a list of function calls to check for consistent class order

-}
type alias Options =
    { order : Dict String Int
    , checkedFunctions : List CheckedFunction
    }


{-| Provide required options and defaults the other options
-}
defaultOptions : { order : Dict String Int } -> Options
defaultOptions { order } =
    { order = order
    , checkedFunctions = [ CheckedFunction.class, CheckedFunction.classList ]
    }


type alias Context =
    { order : Dict String Int
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
        runCheck context range classString =
            let
                classNames =
                    String.split " " classString
                        |> List.filter (not << String.isEmpty)

                sortedClassNames =
                    classNames |> List.sortWith (sortClassNames context.order)
            in
            if classNames == sortedClassNames then
                []

            else
                [ Rule.errorWithFix
                    Internal.consistentClassOrderError
                    range
                    [ Fix.replaceRangeBy range ("\"" ++ String.join " " sortedClassNames ++ "\"") ]
                ]
    in
    Internal.expressionVisitor runCheck


sortClassNames : Dict String Int -> String -> String -> Order
sortClassNames order class1 class2 =
    compare (Dict.get class1 order |> Maybe.withDefault 0) (Dict.get class2 order |> Maybe.withDefault 0)
