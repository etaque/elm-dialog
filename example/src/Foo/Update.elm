module Foo.Update exposing (..)

import Dialog
import Foo.Model exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map DialogMsg (Dialog.subscriptions model.dialog)


init : ( Model, Cmd Msg )
init =
    ( initial, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowDialog ->
            Dialog.taggedOpen DialogMsg { model | showDialog = True }

        DialogMsg a ->
            Dialog.taggedUpdate DialogMsg a model
