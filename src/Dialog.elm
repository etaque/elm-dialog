module Dialog where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

import Effects exposing (Effects, Never, none)
import Task exposing (Task)
import Signal exposing (Mailbox, Address)
import Keyboard
import Transit exposing (Status(..), getValue, getStatus)
import Signal exposing (Address)


type alias Dialog = Transit.WithTransition
  { open : Bool
  , content : Content
  }

initial : Dialog
initial =
  { transition = Transit.initial
  , open = False
  , content = emptyContent
  }

emptyContent : Content
emptyContent =
  []

type alias Content = List Html

type Action
  = NoOp
  | Show Content
  | Hide
  | Do (Task Never ())
  | TransitAction (Transit.Action Action)

mailbox : Mailbox Action
mailbox =
  Signal.mailbox NoOp

actions : Signal Action
actions =
  Signal.mergeMany
    [ mailbox.signal
    , Signal.map (\_ -> Hide) (Keyboard.isDown 27)
    ]

address : Address Action
address =
  mailbox.address

show : Content -> Action
show =
  Show

hide : Action
hide =
  Hide

hideThenSend : Address a -> a -> Action
hideThenSend addr action =
  Do (Signal.send addr action)

sendShow : Content -> action -> Effects action
sendShow content noOp =
  Signal.send address (Show content)
    |> Effects.task
    |> Effects.map (\_ -> noOp)

update : Float -> Action -> Dialog -> (Dialog, Effects Action)
update duration action model =
  case action of

    Show content ->
      let
        timeline = Transit.timeline 0 NoOp duration
        newModel =
          { model
            | open = True
            , content = content
          }
      in
        Transit.init TransitAction timeline newModel

    Hide ->
      if model.open then
        let
          timeline = Transit.timeline duration NoOp 0
          newModel = { model | open = False }
        in
          Transit.init TransitAction timeline newModel
      else
        (model, none)

    Do task ->
      let
        newModel =
          { model
            | open = False
            , content = emptyContent
          }
        fx = Effects.task task |> Effects.map (\_ -> NoOp)
      in
        (newModel, fx)

    TransitAction a ->
      Transit.update TransitAction a model

    NoOp ->
      (model, none)


view : Dialog -> Html
view ({open, content, transition} as dialog) =
  div
    [ class "modal"
    , style [ ("opacity", toString (opacity dialog)), ("display", display dialog) ]
    ]
    [ div
        [ class "modal-dialog" ]
        [ div [ class "modal-content" ] content
        ]
    , div [ class "modal-backdrop" ] []
    ]

header : String -> Html
header title =
  header' title (Just (address, hide))

headerNoClose : String -> Html
headerNoClose title =
  header' title Nothing

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

body : List Html -> Html
body =
  div [ class "modal-body" ]

footer : List Html -> Html
footer =
  div [ class "modal-footer" ]

onClickShow : List Html -> Attribute
onClickShow content =
  onClick address (show content)

onClickHide : Attribute
onClickHide =
  onClick address hide

onClickHideThenSend : Address a -> a -> Attribute
onClickHideThenSend addr action =
  onClick address (hideThenSend addr action)

opacity : Dialog -> Float
opacity {open, transition} =
  if open then
    case Transit.getStatus transition of
      Exit -> 0
      Enter -> Transit.getValue transition
      Done -> 1
  else
    case Transit.getStatus transition of
      Exit -> 1 - Transit.getValue transition
      _ -> 0

display : Dialog -> String
display {open, transition} =
  if open || Transit.getStatus transition == Exit then
    "block"
  else
    "none"
