module Foo.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dialog
import Foo.Model exposing (..)
import Layout exposing (Layout)


view : Model -> Layout Msg
view model =
    Layout
        [ div
            []
            [ p [] [ text "Hello from Foo." ]
            , button [ onClick ShowDialog ] [ text "Open dialog" ]
            ]
        ]
        (Dialog.view DialogMsg model.dialog (dialogContent model))


dialogContent : Model -> Dialog.Content Msg
dialogContent model =
    if model.showDialog then
        { header = [ Dialog.title "Some header title" ]
        , body = [ text "Here goes content" ]
        , footer = []
        }
    else
        Dialog.emptyContent
