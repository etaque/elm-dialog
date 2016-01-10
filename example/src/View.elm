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
        [ Dialog.onClickShow (incConfirm addr) ]
        [ text "Increment?" ]
    , Dialog.view model.dialog
    ]

incConfirm : Address Action -> List Html
incConfirm addr =
  [ Dialog.header "Confirm"
  , Dialog.body
      [ p [] [ text "Sure?" ] ]
  , Dialog.footer
      [ a
          [ class "btn btn-default"
          , Dialog.onClickHide
          ]
          [ text "Nope" ]
      , a
          [ class "btn btn-primary"
          , Dialog.onClickHideThenSend addr Inc
          ]
          [ text "Sure" ]
      ]
  ]
