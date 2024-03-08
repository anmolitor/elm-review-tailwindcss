module TailwindCss.ConsistentClassOrderTest exposing (all)

import Dict
import Review.Test
import TailwindCss.ConsistentClassOrder exposing (defaultOptions, rule)
import TailwindCss.Internal as Internal
import Test exposing (Test, describe, test)


all : Test
all =
    describe "TailwindCss.ConsistentClassOrder"
        [ test "should not report an error when no rules are configured" <|
            \() ->
                """module A exposing (..)
a = class "test block p-2"
"""
                    |> Review.Test.run (defaultOptions { order = Dict.empty } |> rule)
                    |> Review.Test.expectNoErrors
        , test "should report an error when classes are not in the configured order" <|
            \() ->
                """module A exposing (..)
a = class "p-2 block"
"""
                    |> Review.Test.run (defaultOptions { order = Dict.fromList [ ( "block", 1 ), ( "p-2", 2 ) ] } |> rule)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = Internal.consistentClassOrderError.message
                            , details = Internal.consistentClassOrderError.details
                            , under = "\"p-2 block\""
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
a = class "block p-2"
"""
                        ]
        ]
