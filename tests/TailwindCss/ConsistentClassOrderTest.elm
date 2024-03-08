module TailwindCss.ConsistentClassOrderTest exposing (all)

import Dict exposing (Dict)
import Review.Test
import TailwindCss.ConsistentClassOrder exposing (defaultOptions, rule)
import TailwindCss.Internal as Internal
import Test exposing (Test, describe, test)


exampleOrder : Dict String Int
exampleOrder =
    Dict.fromList [ ( "block", 1 ), ( "p-2", 2 ), ( "bg-gray-100", 3 ) ]


all : Test
all =
    describe "TailwindCss.ConsistentClassOrder"
        [ test "should not report an error when classes in a 'class' call are in the correct order" <|
            \() ->
                """module A exposing (..)
a = class "test block p-2"
"""
                    |> Review.Test.run (defaultOptions { order = exampleOrder } |> rule)
                    |> Review.Test.expectNoErrors
        , test "should report an error when classes in a 'class' call are not in the configured order" <|
            \() ->
                """module A exposing (..)
a = class "p-2 block"
"""
                    |> Review.Test.run (defaultOptions { order = exampleOrder } |> rule)
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
        , test "should not report an error when classes in a 'classList' call are in the correct order" <|
            \() ->
                """module A exposing (..)
a = classList [ ( "test block p-2", True ) ]
"""
                    |> Review.Test.run (defaultOptions { order = exampleOrder } |> rule)
                    |> Review.Test.expectNoErrors
        , test "should report an error when classes in a 'classList' call are not in the configured order" <|
            \() ->
                """module A exposing (..)
a = classList [ ( "p-2 block", True ) ]
"""
                    |> Review.Test.run (defaultOptions { order = exampleOrder } |> rule)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = Internal.consistentClassOrderError.message
                            , details = Internal.consistentClassOrderError.details
                            , under = "\"p-2 block\""
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
a = classList [ ( "block p-2", True ) ]
"""
                        ]
        ]
