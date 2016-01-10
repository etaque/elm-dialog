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
update action model =
  case action of
    NoOp ->
      (model, none)

    Inc ->
      let
        counter = model.counter + 1
      in
        ({ model | counter = counter }, none)

    DialogAction a ->
      Dialog.wrappedUpdate 150 DialogAction a model
