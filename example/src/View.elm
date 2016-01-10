module View where

import Html exposing (..)
import Html.Attributes exposing (..)

import Signal exposing (..)

import Dialog
import Dialog.Simple as Simple

import Model exposing (..)


view : Address Action -> Model -> Html
view addr model =
  div
    [ ]
    [ p [] [ text (toString model.counter) ]
    , button
        [ Dialog.openOnClick (dialog addr) ]
        [ text "Increment?" ]
    , Simple.view model.dialog
    ]

dialog : Address Action -> Dialog.Options -> List Html
dialog addr options =
  [ Simple.header options "Confirm"
  , Simple.body
      [ p [] [ text "Sure?" ] ]
  , Simple.footer
      [ a
          [ class "btn btn-default"
          , Dialog.closeOnClick
          ]
          [ text "Nope" ]
      , a
          [ class "btn btn-primary"
          , Dialog.closeThenSendOnClick addr Inc
          ]
          [ text "Sure." ]
      ]
  ]
