module Dialog
  ( Dialog, WithDialog, Action, Options
  , initial, update, wrappedUpdate, actions
  , address, open, openWithOptions, updateContent, closeThenSend, closeThenDo
  , openOnClick, openWithOptionsOnClick, closeOnClick, closeThenSendOnClick, opacity, display
  , getContent, getOptions, getTransition, isOpen, isVisible
  ) where

{-|
A modal component for Elm. See README for usage instructions.

# Types
@docs Dialog, WithDialog, Action, Options

# Init and update
@docs initial, update, wrappedUpdate, actions

# Send actions
@docs address, open, openWithOptions, updateContent, closeThenSend, closeThenDo

# View helpers
@docs openOnClick, openWithOptionsOnClick, closeOnClick, closeThenSendOnClick, opacity, display

# State querying
@docs getContent, getOptions, getTransition, isOpen, isVisible
-}

import Html exposing (..)
import Html.Events exposing (..)

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
  , options : Options
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
  , options = defaultOptions
  , content = []
  } |> S

{-| Dialog actions. -}
type Action
  = NoOp
  | Open (Maybe Options) (Options -> List Html)
  | UpdateContent (Options -> List Html)
  | Escape
  | Close
  | CloseThenDo (Task Never ())
  | Do (Task Never ())
  | TransitAction (Transit.Action Action)

{-| Display and behaviour options (see showWithOptions):
* `duration` of the fade transition,
* `onClose`: what should be done when closing the modal. Set it to Nothing to prevent closing.
 -}
type alias Options =
  { duration : Float
  , onClose : Maybe (Task Never ())
  }

{-| Default options: 150ms transition, closable. -}
defaultOptions : Options
defaultOptions =
  { duration = 150
  , onClose = Just (Signal.send address Close)
  }

{-| Private -}
mailbox : Mailbox Action
mailbox =
  Signal.mailbox NoOp

{-| Dialog actions signal: consumption required! -}
actions : Signal Action
actions =
  Signal.mergeMany
    [ mailbox.signal
    , Signal.map (\_ -> Escape) (Keyboard.isDown 27)
    ]

{-| Where to send your actions -}
address : Address Action
address =
  mailbox.address

{-| Action builder for opening dialog with default options and content. -}
open : (Options -> List Html) -> Action
open =
  Open Nothing

{-| Action builder for open dialog with custom options and content. -}
openWithOptions : Options -> (Options -> List Html) -> Action
openWithOptions options =
  Open (Just options)

{-| Action builder for content update -}
updateContent : (Options -> List Html) -> Action
updateContent =
  UpdateContent

{-| Action builder for closing dialog without further any action. -}
close : Action
close =
  Close

{-| Action builder for closing dialog then sending an action to an address. -}
closeThenSend : Address a -> a -> Action
closeThenSend addr action =
  closeThenDo (Signal.send addr action)

{-| Action builder for closing dialog send performing a task. -}
closeThenDo : Task Never () -> Action
closeThenDo =
  CloseThenDo

{-| Update dialog state. Takes effect duration in ms as first parameter. -}
update : Action -> Dialog -> Response Dialog Action
update action (S state) =
  case action of

    Open maybeOptions template ->
      let
        options = Maybe.withDefault defaultOptions maybeOptions
        timeline = Transit.timeline 0 NoOp options.duration
        newModel =
          { state
            | open = True
            , content = template options
            , options = options
          }
      in
        Transit.init TransitAction timeline newModel
          |> mapModel S

    Escape ->
      case state.options.onClose of
        Just task ->
          taskRes (S state) (Task.succeed Close)
        Nothing ->
          res (S state) none

    UpdateContent template ->
      let
        newModel = S { state | content = template state.options }
      in
        res newModel none

    Close ->
      case state.options.onClose of
        Just task ->
          updateCloseThenDo task (S state)
        Nothing ->
          res (S state) none

    CloseThenDo task ->
      updateCloseThenDo task (S state)

    Do task ->
      taskRes (S { state | content = [] }) (Task.map (\_ -> NoOp) task)

    TransitAction a ->
      Transit.update TransitAction a state
        |> mapModel S

    NoOp ->
      (S state, none)

{-| Internal -}
updateCloseThenDo : Task Never () -> Dialog -> Response Dialog Action
updateCloseThenDo task (S state) =
  if state.open then
    let
      timeline = Transit.timeline state.options.duration (Do task) 0
      newState = { state | open = False }
    in
      Transit.init TransitAction timeline newState
        |> mapModel S
  else
    (S state, none)


{-| Wrapped update for `WithDialog`, saves you a model field update and an Effects map. -}
wrappedUpdate : (Action -> action) -> Action -> WithDialog model -> Response (WithDialog model) (action)
wrappedUpdate actionWrapper action model =
  let
    (newDialog, dialogFx) = update action model.dialog
  in
    ({ model | dialog = newDialog }, Effects.map actionWrapper dialogFx)


{-| On click, fill and show up dialog with the provided content. -}
openOnClick : (Options -> List Html) -> Attribute
openOnClick template =
  onClick address (open template)

{-| On click, fill and show up dialog with the provided options and content. -}
openWithOptionsOnClick : Options -> (Options -> List Html) -> Attribute
openWithOptionsOnClick options template =
  onClick address (openWithOptions options template)

{-| On click, hide dialog. -}
closeOnClick : Attribute
closeOnClick =
  onClick address close

{-| On click, hide dialog then send action. -}
closeThenSendOnClick : Address a -> a -> Attribute
closeThenSendOnClick addr action =
  onClick address (closeThenSend addr action)

{-| Get current dialog content. -}
getContent : Dialog -> List Html
getContent (S {content}) =
  content

{-| Get current dialog options -}
getOptions : Dialog -> Options
getOptions (S {options}) =
  options

{-| Get current transition state. -}
getTransition : Dialog -> Transit.Transition
getTransition (S {transition}) =
  transition

{-| Is the dialog currently open? -}
isOpen : Dialog -> Bool
isOpen (S {open}) =
  open

{-| Visibility helper: either open, or transitionning to closed -}
isVisible : Dialog -> Bool
isVisible (S {open, transition}) =
  open || Transit.getStatus transition == Exit

{-| CSS opacity helper for fading effect. -}
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

{-| CSS display helper. -}
display : Dialog -> String
display dialog =
  if isVisible dialog then "block" else "none"
