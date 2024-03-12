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
        [ Html.div [ class "bgd peer mx-8xl flex items-center justify-center p-4 dark:bg-slate-50" ]
            [ Html.h1 [ class "known-class w-48 p-8 peer-checked:left-0 bgd:bg-slate-500 sm:w-12 lg:w-24" ] [ text model.message ]
            , Html.p [ class "p-2 p-4", classList [ ( "block bg-black peer-open:hover:dark:right-0", True ), ( "m-4", False ) ] ] [ text "Some text" ]
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
