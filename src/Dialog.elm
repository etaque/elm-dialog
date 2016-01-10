module Dialog
  ( Dialog, WithDialog, Action
  , initial, update, wrappedUpdate, actions
  , address, show, hide, hideThenSend
  , view, header, body, footer
  , onClickShow, onClickHide, onClickHideThenSend, opacity, display
  , getContent, getTransition, isOpen
  ) where

{-|
A modal component for Elm. See README for usage instructions.

# Types
@docs Dialog, WithDialog, Action

# Init and update
@docs initial, update, wrappedUpdate, actions

# Send actions
@docs address, show, hide, hideThenSend

# Simple theme
@docs view, header, body, footer

# View helpers
@docs onClickShow, onClickHide, onClickHideThenSend, opacity, display

# State querying
@docs getContent, getTransition, isOpen
-}

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Effects exposing (Effects, Never, none)
import Task exposing (Task)
import Signal exposing (Mailbox, Address)
import Keyboard
import Transit exposing (Status(..), getValue, getStatus)
import Response exposing (..)
import Signal exposing (Address)


{-| Dialog state (opaque type). -}
type Dialog = S State

type alias State = Transit.WithTransition
  { open : Bool
  , content : List Html
  }

{-| Record extension that puts state in `dialog` field (see also [wrappedUpdate](#wrappedUpdate)). -}
type alias WithDialog model =
  { model | dialog : Dialog }

{-| Empty, hidden state for model init. -}
initial : Dialog
initial =
  { transition = Transit.initial
  , open = False
  , content = []
  } |> S

{-| Dialog actions. -}
type Action
  = NoOp
  | Show (List Html)
  | Hide
  | Do (Task Never ())
  | TransitAction (Transit.Action Action)

mailbox : Mailbox Action
mailbox =
  Signal.mailbox NoOp

{-| Dialog actions signal: consumption required! -}
actions : Signal Action
actions =
  Signal.mergeMany
    [ mailbox.signal
    , Signal.map (\_ -> Hide) (Keyboard.isDown 27)
    ]

{-| Where to send your actions -}
address : Address Action
address =
  mailbox.address

{-| Action builder for showing up dialog with content. -}
show : List Html -> Action
show =
  Show

{-| Action build for hiding dialog. -}
hide : Action
hide =
  Hide

{-| Action build for hiding dialog then sending an action to an address. -}
hideThenSend : Address a -> a -> Action
hideThenSend addr action =
  Do (Signal.send addr action)

{-| Update dialog state. Takes effect duration in ms as first parameter. -}
update : Float -> Action -> Dialog -> (Dialog, Effects Action)
update duration action (S state) =
  case action of

    Show content ->
      let
        timeline = Transit.timeline 0 NoOp duration
        newModel =
          { state
            | open = True
            , content = content
          }
      in
        Transit.init TransitAction timeline newModel
          |> mapModel S

    Hide ->
      if state.open then
        let
          timeline = Transit.timeline duration NoOp 0
          newState = { state | open = False }
        in
          Transit.init TransitAction timeline newState
            |> mapModel S
      else
        (S state, none)

    Do task ->
      let
        newModel = S
          { state
            | open = False
            , content = []
          }
        fx = Effects.task task |> Effects.map (\_ -> NoOp)
      in
        (newModel, fx)

    TransitAction a ->
      Transit.update TransitAction a state
        |> mapModel S

    NoOp ->
      (S state, none)

{-| Wrapped update for `WithDialog`, saves you a model field update and an Effects map. -}
wrappedUpdate : Float -> (Action -> action) -> Action -> WithDialog model -> (WithDialog model, Effects action)
wrappedUpdate duration actionWrapper action model =
  let
    (newDialog, dialogFx) = update duration action model.dialog
  in
    ({ model | dialog = newDialog }, Effects.map actionWrapper dialogFx)

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
    , div [ class "modal-backdrop" ] []
    ]

{-| Header decorator, with a Close button. -}
header : String -> Html
header title =
  header' title (Just (address, hide))

{-| Header decorator, without a Close button. -}
headerNoClose : String -> Html
headerNoClose title =
  header' title Nothing

{-| Header decorator, with a custom address/action for the Close button. -}
headerCustomClose : String -> Address a -> a -> Html
headerCustomClose title address action =
  header' title (Just (address, action))

header' : String -> Maybe (Address a, a) -> Html
header' title maybeClose =
  div
    [ class "modal-header" ] <|
    [ h1 [ class "modal-title" ] [ text title ]
    ] ++ (Maybe.map closeButton maybeClose |> Maybe.withDefault [])

closeButton : (Address a, a) -> List Html
closeButton (address, action) =
  [ button
      [ class "close"
      , attribute "aria-label" "Close"
      , onClick address action
      ]
      [ span
        [ attribute "aria-hidden" "true" ]
        [ text "×" ]
      ]
  ]

{-| Body decorator. -}
body : List Html -> Html
body =
  div [ class "modal-body" ]

{-| Footer decorator. -}
footer : List Html -> Html
footer =
  div [ class "modal-footer" ]

{-| On click, fill and show up dialog with the provided content. -}
onClickShow : List Html -> Attribute
onClickShow content =
  onClick address (show content)

{-| On click, hide dialog. -}
onClickHide : Attribute
onClickHide =
  onClick address hide

{-| On click, hide dialog then send action. -}
onClickHideThenSend : Address a -> a -> Attribute
onClickHideThenSend addr action =
  onClick address (hideThenSend addr action)

{-| Get current dialog content. -}
getContent : Dialog -> List Html
getContent (S {content}) =
  content

{-| Get current transition state. -}
getTransition : Dialog -> Transit.Transition
getTransition (S {transition}) =
  transition

{-| Is the dialog currently open? -}
isOpen : Dialog -> Bool
isOpen (S {open}) =
  open

{-| Opacity helper for fading effect. -}
opacity : Dialog -> Float
opacity (S {open, transition}) =
  if open then
    case Transit.getStatus transition of
      Exit -> 0
      Enter -> Transit.getValue transition
      Done -> 1
  else
    case Transit.getStatus transition of
      Exit -> 1 - Transit.getValue transition
      _ -> 0

{-| Visibility helper. -}
display : Dialog -> String
display (S {open, transition}) =
  if open || Transit.getStatus transition == Exit then
    "block"
  else
    "none"
