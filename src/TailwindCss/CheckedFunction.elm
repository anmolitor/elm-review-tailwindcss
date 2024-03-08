module TailwindCss.CheckedFunction exposing (checkClassFunction, checkClassListFunction)

import TailwindCss.Internal exposing (CheckedFunction)
import TailwindCss.Internal exposing (CheckedFunctionArg(..))


checkClassFunction : CheckedFunction
checkClassFunction =
    { functionName = "class", moduleName = Nothing, arguments = [ Just LiteralArg ] }


checkClassListFunction : CheckedFunction
checkClassListFunction =
    { functionName = "classList", moduleName = Nothing, arguments = [ Just ListOfLiteralsArg ] }
