module Update where

import Effects exposing (Effects, none)
import Dialog

import Model exposing (..)


initialModel : Model
initialModel =
  { dialog = Dialog.initial
  , counter = 0
  }


actions : Signal Action
actions =
  Signal.map DialogAction Dialog.actions


init : (Model, Effects Action)
init =
  (initialModel, none)


update : Action -> Model -> (Model, Effects Action)
update action ({counter} as model) =
  case action of
    NoOp ->
      (model, none)

    Inc ->
      ({ model | counter = counter + 1 }, none)

    Reset ->
      ({ model | counter = 0 }, none)

    DialogAction a ->
      Dialog.wrappedUpdate DialogAction a model
