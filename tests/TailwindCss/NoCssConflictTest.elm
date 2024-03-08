module TailwindCss.NoCssConflictTest exposing (all)

import TailwindCss.NoCssConflict exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


all : Test
all =
    describe "TailwindCss.NoCssConflict"
        [ test "should not report an error when REPLACEME" <|
            \() ->
                """module A exposing (..)
a = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectNoErrors
        , test "should report an error when REPLACEME" <|
            \() ->
                """module A exposing (..)
a = 1
"""
                    |> Review.Test.run rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "REPLACEME"
                            , details = [ "REPLACEME" ]
                            , under = "REPLACEME"
                            }
                        ]
        ]
