module TailwindCss.Internal exposing (consistentClassOrderError, cssConflictError, expressionVisitor, unknownClassesError)

import Elm.Syntax.Expression exposing (Expression(..))
import Elm.Syntax.ModuleName exposing (ModuleName)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.Rule as Rule
import TailwindCss.CheckedFunction exposing (CheckedFunction, CheckedFunctionArg(..))


expressionVisitor :
    ({ ctx | checkedFunctions : List CheckedFunction } -> Range -> String -> List (Rule.Error {}))
    -> Node Expression
    -> { ctx | checkedFunctions : List CheckedFunction }
    -> ( List (Rule.Error {}), { ctx | checkedFunctions : List CheckedFunction } )
expressionVisitor runCheck node context =
    case matchFunction node of
        Just function ->
            let
                helper checkedFunctions =
                    case checkedFunctions of
                        [] ->
                            ( [], context )

                        { functionName, moduleName, arguments } :: rest ->
                            let
                                moduleMatch =
                                    case moduleName of
                                        Nothing ->
                                            True

                                        Just mod ->
                                            mod == function.moduleName
                            in
                            if functionName == function.name && moduleMatch && List.length arguments == List.length function.args then
                                ( List.map2
                                    extractArgs
                                    arguments
                                    function.args
                                    |> List.concat
                                    |> List.concatMap (\( range, classString ) -> runCheck context range classString)
                                , context
                                )

                            else
                                helper rest
            in
            helper context.checkedFunctions

        Nothing ->
            ( [], context )


matchFunction : Node Expression -> Maybe { args : List (Node Expression), name : String, moduleName : ModuleName }
matchFunction node =
    case Node.value node of
        Application (fun :: args) ->
            case Node.value fun of
                FunctionOrValue moduleName name ->
                    Just { args = args, name = name, moduleName = moduleName }

                _ ->
                    Nothing

        _ ->
            Nothing


extractArgs : Maybe CheckedFunctionArg -> Node Expression -> List ( Range, String )
extractArgs argExtractor arg =
    case ( argExtractor, Node.value arg ) of
        ( Just LiteralArg, Literal classString ) ->
            [ ( Node.range arg, classString ) ]

        ( Just (ListArg listArgExtractor), ListExpr exprs ) ->
            List.concatMap (extractArgs (Just listArgExtractor)) exprs

        ( Just (TupleArg tupleArgExtractors), TupledExpression exprs ) ->
            if List.length tupleArgExtractors == List.length exprs then
                List.map2
                    extractArgs
                    tupleArgExtractors
                    exprs
                    |> List.concat

            else
                []

        _ ->
            []


consistentClassOrderError : { message : String, details : List String }
consistentClassOrderError =
    { message = "Order css class names in a consistent way to improve readability."
    , details =
        [ """Ordering css classes is very helpful when using tailwind css, since there are often a lot of them.
Scoped functionality such as dark mode, media queries etc. are better understood if grouped together."""
        , "See this link for more information on the ordering used: https://tailwindcss.com/blog/automatic-class-sorting-with-prettier#how-classes-are-sorted"
        ]
    }


unknownClassesError : List String -> { message : String, details : List String }
unknownClassesError unknownClassNames =
    let
        formattedClassNames =
            List.map (\className -> "'" ++ className ++ "'") unknownClassNames |> String.join ", "

        message =
            if List.length unknownClassNames > 1 then
                "Css classes " ++ formattedClassNames ++ " are not in your stylesheet."

            else
                "Css class " ++ formattedClassNames ++ " is not in your stylesheet."
    in
    { message = message
    , details =
        [ """Assuming things are setup correctly, all your stylesheets went into postcss and our postcss plugin generated a list of valid classes.
The above list of classes were not in that list. You can probably just delete the classes and move on.
When in doubt, rerun postcss and elm-review or look for the classes in your stylesheets."""
        , "If you have any styles external to your application, e.g. your Elm app is not the entire website and there are some shared styles, you should probably disable this rule."
        ]
    }


cssConflictError : { conflictingClasses : ( String, String ), conflictingProperties : List String } -> { message : String, details : List String }
cssConflictError { conflictingClasses, conflictingProperties } =
    let
        ( class1, class2 ) =
            conflictingClasses

        formattedCssPropertyList =
            List.map (\className -> "'" ++ className ++ "'") conflictingProperties |> String.join ", "

        propertiesPlural =
            if List.length conflictingProperties > 1 then
                "properties"

            else
                "property"

        message =
            "Css classes '" ++ class1 ++ "' and '" ++ class2 ++ "' both set the same css " ++ propertiesPlural ++ " " ++ formattedCssPropertyList ++ ". Delete one of them."
    in
    { message = message
    , details =
        [ "This makes it hard to reason about which style actually applies at runtime and in some cases it can depend on things like the order of declarations in your css file."
        , "Try to make your classes smaller and more modular or alternatively, duplicate styles where necessary instead of overriding other classes."
        , "This is a pretty strict rule. If you have usecases where this makes sense, you should probably disable the rule and move on."
        ]
    }
