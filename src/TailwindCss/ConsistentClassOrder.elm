module TailwindCss.ConsistentClassOrder exposing
    ( rule
    , Options, defaultOptions
    )

{-|

@docs rule

-}

import Dict exposing (Dict)
import Elm.Syntax.Expression exposing (Expression(..))
import Elm.Syntax.Node exposing (Node)
import Review.Fix as Fix
import Review.Rule as Rule exposing (Rule)
import TailwindCss.CheckedFunction exposing (checkClassFunction, checkClassListFunction)
import TailwindCss.Internal as Internal


{-| Reports if a css class string does not adhere to the [recommended class order](https://tailwindcss.com/blog/automatic-class-sorting-with-prettier#how-classes-are-sorted)

    config =
        [ TailwindCss.ConsistentClassOrder.rule { order = classOrder, checkedFunctions = [checkClassFunction] }
        ]

    It is not recommended to define the `order` option manually. Instead you can use the postcss-plugin (TODO add link)
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

You can try this rule out by running the following command:

```bash
elm-review --template anmolitor/elm-review-tailwindcss/example --rules TailwindCss.ConsistentClassOrder
```

-}
rule : Options -> Rule
rule order =
    Rule.newModuleRuleSchemaUsingContextCreator "TailwindCss.ConsistentClassOrder" (initialContext order)
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.providesFixesForModuleRule
        |> Rule.fromModuleRuleSchema


type alias Options =
    { order : Dict String Int
    , checkedFunctions : List Internal.CheckedFunction
    }


defaultOptions : { order : Dict String Int } -> Options
defaultOptions { order } =
    { order = order
    , checkedFunctions = [ checkClassFunction, checkClassListFunction ]
    }


type alias Context =
    { order : Dict String Int
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
