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
        [ Dialog.openOnClick (dialog addr) ]
        [ text "Increment?" ]
    , Dialog.view model.dialog
    ]

dialog : Address Action -> Dialog.Options -> List Html
dialog addr options =
  [ Dialog.header options "Confirm"
  , Dialog.body
      [ p [] [ text "Sure?" ] ]
  , Dialog.footer
      [ a
          [ class "btn btn-default"
          , Dialog.closeOnClick
          ]
          [ text "Nope, reset everything!" ]
      , a
          [ class "btn btn-primary"
          , Dialog.closeThenSendOnClick addr Inc
          ]
          [ text "Sure." ]
      ]
  ]
