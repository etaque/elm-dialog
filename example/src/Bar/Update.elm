module Bar.Update exposing (..)

import Bar.Model exposing (..)
import Dialog


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DialogMsg (Dialog.subscriptions model.dialog)


init : ( Model, Cmd Msg )
init =
    ( initial, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDialog kind ->
            Dialog.taggedOpen DialogMsg { model | currentDialog = Just kind }

        DialogMsg a ->
            Dialog.taggedUpdate DialogMsg a model
