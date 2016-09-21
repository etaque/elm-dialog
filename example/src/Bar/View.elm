module Bar.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Bar.Model exposing (..)
import Layout exposing (Layout)
import Dialog


view : Model -> Layout Msg
view model =
    Layout
        [ div
            []
            [ text "This is bar"
            , ul
                []
                [ li [ onClick (SetDialog Confirm) ] [ text "This will open a confirmation dialog" ]
                , li [ onClick (SetDialog Congratulate) ] [ text "This will open a congratulation dialog" ]
                ]
            ]
        ]
        (Dialog.view DialogMsg model.dialog (dialogContent model))


dialogContent : Model -> Dialog.Content Msg
dialogContent model =
    case model.currentDialog of
        Just Confirm ->
            { header = [ Dialog.title "Hmm" ]
            , body = [ text "Are you sure?" ]
            , footer = []
            }

        Just Congratulate ->
            { header = [ Dialog.title "Woaw" ]
            , body = [ text "Congrats!" ]
            , footer = []
            }

        Nothing ->
            Dialog.emptyContent
