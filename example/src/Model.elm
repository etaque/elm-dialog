module Model where

import Dialog exposing (WithDialog)


type Action
  = NoOp
  | Inc
  | Reset
  | DialogAction Dialog.Action

type alias Model = WithDialog
  { counter : Int }

