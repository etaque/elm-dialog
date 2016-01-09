module Model where

import Dialog exposing (Dialog)


type Action = NoOp | Inc | DialogAction Dialog.Action

type alias Model = { dialog : Dialog, counter : Int }

