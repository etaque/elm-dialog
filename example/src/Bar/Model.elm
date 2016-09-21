module Bar.Model exposing (..)

import Dialog exposing (WithDialog)


type alias Model =
    WithDialog { currentDialog : Maybe DialogKind }


initial : Model
initial =
    { dialog = Dialog.initial, currentDialog = Nothing }


type Msg
    = SetDialog DialogKind
    | DialogMsg Dialog.Msg


type DialogKind
    = Confirm
    | Congratulate
