module TailwindCss.NoCssConflictTest exposing (all)

import Dict exposing (Dict)
import Review.Test
import Set exposing (Set)
import TailwindCss.Internal as Internal
import TailwindCss.NoCssConflict exposing (defaultOptions, rule)
import Test exposing (Test, describe, test)


exampleProps : Dict String (Set String)
exampleProps =
    Dict.fromList
        [ ( "p-2", Set.singleton "padding" )
        , ( "p-4", Set.singleton "padding" )
        , ( "text-xl", Set.fromList [ "font-size", "line-height" ] )
        , ( "flex", Set.singleton "display" )
        ]


all : Test
all =
    describe "TailwindCss.NoCssConflict"
        [ test "should not report an error when classes are not conflicting" <|
            \() ->
                """module A exposing (..)
a = class "p-2 flex text-xl unknown-class"
"""
                    |> Review.Test.run (defaultOptions { props = exampleProps } |> rule)
                    |> Review.Test.expectNoErrors
        , test "should report an error when classes are conflicting" <|
            \() ->
                """module A exposing (..)
a = class "p-2 flex text-xl p-4 unknown-class"
"""
                    |> Review.Test.run (defaultOptions { props = exampleProps } |> rule)
                    |> Review.Test.expectErrors
                        [ let
                            expectedError =
                                Internal.cssConflictError { conflictingClasses = ( "p-2", "p-4" ), conflictingProperties = [ "padding" ] }
                          in
                          Review.Test.error
                            { message = expectedError.message
                            , details = expectedError.details
                            , under = "\"p-2 flex text-xl p-4 unknown-class\""
                            }
                        ]
        ]
