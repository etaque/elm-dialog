module Foo.Model exposing (..)

import Dialog exposing (WithDialog)


type alias Model =
    WithDialog { showDialog : Bool }


type Msg
    = ShowDialog
    | DialogMsg Dialog.Msg


initial : Model
initial =
    { dialog = Dialog.initial, showDialog = False }
