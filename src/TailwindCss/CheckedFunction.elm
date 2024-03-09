module TailwindCss.CheckedFunction exposing
    ( class, classList
    , CheckedFunctionArg(..), CheckedFunction
    )

{-| Predefined `CheckedFunction` instances so you do not have to define them yourself.
These are designed for use in your TailwindCss.\* rules `Options`.

@docs class, classList

If you want to define your own checked functions, these are the building blocks you need

@docs CheckedFunctionArg, CheckedFunction

-}


{-| Declaratively extract literal arguments from functions.
For example to extract the class strings from the Html.Attributes.classList function

       classList : List (String, Bool) -> Attribute msg

you would provide

       ListArg ( TupleArg [ Just LiteralArg, Nothing ] )

-}
type CheckedFunctionArg
    = LiteralArg
    | ListArg CheckedFunctionArg
    | TupleArg (List (Maybe CheckedFunctionArg))


{-| Which function should be checked (for TailwindCss Linting purposes)?
You need to provide the name of the function and an argument extractor
(which arguments should be extracted and which parts of them).

You can look at the predefined functions in this module for examples.
Declaring a `moduleName` causes the function to only be matched if imported from the declared module.

You may need this if you have `class` functions from other modules that have nothing to do with css.

-}
type alias CheckedFunction =
    { functionName : String
    , moduleName : Maybe (List String)
    , arguments : List (Maybe CheckedFunctionArg)
    }


{-| Check all usages of "class" functions, regardless from which module they are from
and if they are used qualified (Html.Attributes.class) or unqualified (class).
Assumes that the class functions get called with a single string literal argument.
-}
class : CheckedFunction
class =
    { functionName = "class", moduleName = Nothing, arguments = [ Just LiteralArg ] }


{-| Check all usages of "classList" functions, regardless from which module they are from
and if they are used qualified (Html.Attributes.classList) or unqualified (classList).
Assumes that the class functions get called with a single list argument of (Bool, String) tuples.
-}
classList : CheckedFunction
classList =
    { functionName = "classList", moduleName = Nothing, arguments = [ Just <| ListArg <| TupleArg [ Just LiteralArg, Nothing ] ] }
