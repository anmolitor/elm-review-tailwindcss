module TailwindCss.CheckedFunction exposing (class, classList)

{-| Predefined `CheckedFunction` instances so you do not have to define them yourself.
These are designed for use in your TailwindCss.\* rules `Options`.

    @docs class, classList

-}

import TailwindCss.Internal exposing (CheckedFunction, CheckedFunctionArg(..))


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
