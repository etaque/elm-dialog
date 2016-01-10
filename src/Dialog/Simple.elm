module Dialog.Simple
  ( view, header, closeButton, body, footer ) where

{-|
A simple theme for Elm Dialog.

@docs view, header, closeButton, body, footer
-}

import Html exposing (..)
import Html.Attributes exposing (..)

import Dialog exposing (..)


{-| A simple decorator for the dialog, with backdrop. Put it at the bottom of your body. -}
view : Dialog -> Html
view dialog =
  div
    [ class "modal"
    , style [ ("opacity", toString (opacity dialog)), ("display", display dialog) ]
    ]
    [ div
        [ class "modal-dialog" ]
        [ div [ class "modal-content" ] (getContent dialog)
        ]
    , div [ class "modal-backdrop", closeOnClick ] []
    ]

{-| Header decorator, showing Close button if options.onClose is set. -}
header : Options -> String -> Html
header options title =
  div
    [ class "modal-header" ] <|
    [ h1 [ class "modal-title" ] [ text title ]
    ] ++ (closeButton options)

{-| Close button with action. -}
closeButton : Options -> List Html
closeButton options =
  case options.onClose of
    Just task ->
      [ button
          [ class "close"
          , attribute "aria-label" "Close"
          , closeOnClick
          ]
          [ span
            [ attribute "aria-hidden" "true" ]
            [ text "×" ]
          ]
      ]
    Nothing ->
      []

{-| Body decorator. -}
body : List Html -> Html
body content =
  div [ class "modal-body" ] content

{-| Footer decorator. -}
footer : List Html -> Html
footer content =
  div [ class "modal-footer" ] content
