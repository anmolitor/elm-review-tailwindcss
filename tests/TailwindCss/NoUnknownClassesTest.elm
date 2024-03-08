module TailwindCss.NoUnknownClassesTest exposing (all)

import Dict
import Review.Test
import TailwindCss.Internal as Internal
import TailwindCss.NoUnknownClasses exposing (defaultOptions, rule)
import Test exposing (Test, describe, test)


all : Test
all =
    describe "TailwindCss.NoUnknownClasses"
        [ test "should not report an error when all classes are known" <|
            \() ->
                """module A exposing (..)
a = class "flex absolute"
"""
                    |> Review.Test.run (defaultOptions { order = Dict.fromList [ ( "flex", 0 ), ( "absolute", 1 ) ] } |> rule)
                    |> Review.Test.expectNoErrors
        , test "should report an error when an unknown class is encountered" <|
            \() ->
                """module A exposing (..)
a = class "flex unknown-class absolute"
"""
                    |> Review.Test.run (defaultOptions { order = Dict.fromList [ ( "flex", 0 ), ( "absolute", 1 ) ] } |> rule)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = (Internal.unknownClassesError [ "unknown-class" ]).message
                            , details = (Internal.unknownClassesError [ "unknown-class" ]).details
                            , under = "\"flex unknown-class absolute\""
                            }
                            |> Review.Test.whenFixed """module A exposing (..)
a = class "flex absolute"
"""
                        ]
        ]
