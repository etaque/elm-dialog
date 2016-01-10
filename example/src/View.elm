module View where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Signal exposing (..)

import Dialog

import Model exposing (..)


view : Address Action -> Model -> Html
view addr model =
  div
    [ ]
    [ p [] [ text (toString model.counter) ]
    , button
        [ Dialog.onClickOpenWithOptions
            (confirmOptions addr)
            (incConfirm addr)
        ]
        [ text "Increment?" ]
    , Dialog.view model.dialog
    ]

confirmOptions : Address Action -> Dialog.Options
confirmOptions addr =
  { duration = 500
  , onClose = Just (Signal.send addr Reset)
  }

incConfirm : Address Action -> Dialog.Options -> List Html
incConfirm addr options =
  [ Dialog.header options "Confirm"
  , Dialog.body
      [ p [] [ text "Sure?" ] ]
  , Dialog.footer
      [ a
          [ class "btn btn-default"
          , Dialog.onClickClose
          ]
          [ text "Nope, reset everything!" ]
      , a
          [ class "btn btn-primary"
          , Dialog.onClickCloseThenSend addr Inc
          ]
          [ text "Sure." ]
      ]
  ]
