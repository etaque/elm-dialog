module Model where

import Dialog exposing (WithDialog)


type Action
  = NoOp
  | Inc
  | DialogAction Dialog.Action

type alias Model = WithDialog
  { counter : Int }

