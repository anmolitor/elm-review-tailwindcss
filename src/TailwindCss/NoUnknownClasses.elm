module TailwindCss.NoUnknownClasses exposing
    ( rule
    , Options, defaultOptions
    )

{-|

@docs rule

-}

import Dict
import Elm.Syntax.Expression exposing (Expression)
import Elm.Syntax.Node exposing (Node)
import Review.Fix as Fix
import Review.Rule as Rule exposing (Rule)
import TailwindCss.CheckedFunction exposing (checkClassFunction, checkClassListFunction)
import TailwindCss.Internal as Internal


{-| Reports if you are using classes in your Html that are not known to postcss.

    config =
        [ TailwindCss.NoUnknownClasses.rule { order = classOrder, checkedFunctions = [checkClassFunction] }
        ]

    It is not recommended to define the `order` option manually. Instead you can use the postcss-plugin (TODO add link)
    to generate the Elm code for you and then you can just import the `classOrder` in your `ReviewConfig.elm` file.


## Fail

    a =
        class "flex absolute unknown-class"


## Success

    a =
        class "flex absolute"


## When (not) to enable this rule

This rule is useful when you are using tailwindcss and all your styles are known at build-time.
This rule is not useful when you are not using tailwindcss, or you have stylesheets in your application that are injected at runtime.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template anmolitor/elm-review-tailwindcss/example --rules TailwindCss.NoUnknownClasses
```

-}
rule : Options -> Rule
rule options =
    Rule.newModuleRuleSchemaUsingContextCreator "TailwindCss.NoUnknownClasses" (initialContext options)
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.providesFixesForModuleRule
        |> Rule.fromModuleRuleSchema


type alias Options =
    { order : Internal.Order
    , checkedFunctions : List Internal.CheckedFunction
    }


defaultOptions : { order : Internal.Order } -> Options
defaultOptions { order } =
    { order = order
    , checkedFunctions = [ checkClassFunction, checkClassListFunction ]
    }


type alias Context =
    { order : Internal.Order
    , checkedFunctions : List Internal.CheckedFunction
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

                ( knownClassNames, unknownClassNames ) =
                    classNames |> List.partition (\className -> Dict.member className context.order)
            in
            if List.isEmpty unknownClassNames then
                []

            else
                [ Rule.errorWithFix
                    (Internal.unknownClassesError unknownClassNames)
                    range
                    [ Fix.replaceRangeBy range ("\"" ++ String.join " " knownClassNames ++ "\"") ]
                ]
    in
    Internal.expressionVisitor runCheck
