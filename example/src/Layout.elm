module Layout exposing (..)

import Html.App as Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dialog
import Model exposing (..)


type alias Layout msg =
    { content : List (Html msg)
    , dialog : Dialog.View msg
    }


renderLayout : (msg -> Msg) -> Layout msg -> Html Msg
renderLayout tagger { content, dialog } =
    div
        [ class "root" ]
        [ ul
            [ class "nav" ]
            [ li [ onClick (SetRoute Foo) ] [ text "Foo" ]
            , li [ onClick (SetRoute Bar) ] [ text "Bar" ]
            ]
        , hr [] []
        , Html.map tagger <|
            div [ class "content" ] (content ++ [ dialog.box ])
        , Html.map tagger dialog.backdrop
        ]
