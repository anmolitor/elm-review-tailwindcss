module Main exposing (main)

import Browser
import Html exposing (Html, text)
import Html.Attributes exposing (class, classList)


type alias Model =
    { message : String }


initialModel : Model
initialModel =
    { message = "Hello, Elm!" }


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


view : Model -> Browser.Document Msg
view model =
    { title = "Elm app"
    , body =
        [ Html.div [ class "justify-center p-4 items-center flex mx-8xl" ]
            [ Html.h1 [ class "unknown-class p-8 known-class" ] [ text model.message ]
            , Html.p [ class "p-2 p-4", classList [ ( "bg-black block", True ), ( "unknown m-4", False ) ] ] [ text "Some text" ]
            ]
        ]
    }



-- PROGRAM


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = \msg model -> ( update msg model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
