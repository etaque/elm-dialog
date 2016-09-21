module Dialog exposing (Msg, Model, WithDialog, initial, Options, defaultOptions, taggedOpen, open, taggedUpdate, update, closeUpdate, subscriptions, Content, emptyContent, View, view, title, subtitle)

{-|
A modal component for Elm. See README for usage instructions.

# Types
@docs Model, WithDialog, Msg, Options, defaultOptions

# Init & udpate
@docs subscriptions, initial, taggedOpen, open, taggedUpdate, update, closeUpdate

# View
@docs View, view, Content, emptyContent, title, subtitle
-}


import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Transit exposing (Step(..), getValue, getStep)
import Keyboard


{-| Message -}
type Msg
  = NoOp
  | Close
  | KeyDown Int
  | TransitMsg (Transit.Msg Msg)


{-| Model -}
type alias Model =
  Transit.WithTransition
    { open : Bool
    , options : Options
    }


{-| Model extension -}
type alias WithDialog a =
  { a | dialog : Model }


{-| initial model: closed, default options. -}
initial : Model
initial =
  { transition = Transit.empty
  , open = False
  , options = defaultOptions
  }


{-| Options:

* `duration`: of animation in ms
* `closeOnEscape`: should a keypress on ESC close the dialog
* `onClose`: which message should be sent when closing the dialog
 -}
type alias Options =
  { duration : Float
  , closeOnEscape : Bool
  , onClose : Maybe Msg
  }


{-| Default options: 50ms, close on escape, no message sent. -}
defaultOptions : Options
defaultOptions =
  { duration = 50
  , closeOnEscape = True
  , onClose = Nothing
  }


{-| Open the dialog (shortcut when using model extension) -}
taggedOpen : (Msg -> msg) -> WithDialog model -> ( WithDialog model, Cmd msg )
taggedOpen tagger model =
  let
    ( newDialog, cmd ) =
      open model.dialog
  in
    ( { model | dialog = newDialog }, Cmd.map tagger cmd )


{-| Open the dialog -}
open : Model -> ( Model, Cmd Msg )
open model =
  Transit.start TransitMsg NoOp (0, model.options.duration) { model | open = True }


{-| Update the dialog -}
taggedUpdate : (Msg -> msg) -> Msg -> WithDialog model -> ( WithDialog model, Cmd msg )
taggedUpdate tagger msg model =
  let
    ( newDialog, cmd ) =
      update msg model.dialog
  in
    ( { model | dialog = newDialog }, Cmd.map tagger cmd )


{-| Update the dialog (shortcut when using model extension) -}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )

    KeyDown code ->
      if model.options.closeOnEscape && code == 27 && model.open then
        closeUpdate model
      else
        ( model, Cmd.none )

    Close ->
      closeUpdate model

    TransitMsg transitMsg ->
      Transit.tick TransitMsg transitMsg model


{-| Close the dialog -}
closeUpdate : Model -> ( Model, Cmd Msg )
closeUpdate model =
  Transit.start TransitMsg NoOp (model.options.duration, 0) { model | open = False }


{-| Subscriptions: keyboard presses (for ESC) and animation ticks -}
subscriptions : Transit.WithTransition model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Keyboard.downs KeyDown
    , Transit.subscriptions TransitMsg model
    ]



{-| A dialog is composed of a header, a body and a footer. -}
type alias Content msg =
  { header : List (Html msg)
  , body : List (Html msg)
  , footer : List (Html msg)
  }


{-| The empty content -}
emptyContent : Content msg
emptyContent =
  Content [] [] []


{-| The view record: dialog box and backdrop (so they can be placed separately in the DOM tree) -}
type alias View msg =
  { box : Html msg
  , backdrop : Html msg
  }


{-| Dialog view, with inputs:

* messages tagger
* dialog model, for display and animation state
* content of the dialog to be rendered

Returns both content and backdrop in `View` record.
 -}
view : (Msg -> msg) -> Model -> Content msg -> View msg
view tagger model layout =
  { box =
      div
        [ class "dialog-wrapper"
        , style
            [ ( "display", display model )
            , ( "opacity", toString (opacity model) )
            ]
        , onClick (tagger Close)
        ]
        [ div
            [ class "dialog-sheet" ]
            [ if List.isEmpty layout.header then
                text ""
              else
                div
                  [ class "dialog-header" ]
                  ((Html.map tagger closeButton) :: layout.header)
            , div
                [ class "dialog-body" ]
                layout.body
            , if List.isEmpty layout.footer then
                text ""
              else
                div
                  [ class "dialog-footer" ]
                  layout.footer
            ]
        ]
  , backdrop = Html.map tagger <|
      div [ class "dialog-backdrop" ] []
  }


{-| View helper for close button -}
closeButton : Html Msg
closeButton =
  span
    [ class "dialog-close"
    , onClick Close
    ]
    [ closeIcon ]


{-| View helper for close icon (SVG) -}
closeIcon : Html msg
closeIcon =
  node "svg"
    [ attribute "width" "24"
    , attribute "height" "24"
    ]
    [ node "path"
        [ attribute "d" "M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z" ]
        []
    ]


{-| View helper for title -}
title : String -> Html msg
title s =
  div [ class "dialog-title" ] [ text s ]


{-| View helper for subtitle -}
subtitle : String -> Html msg
subtitle s =
  div [ class "dialog-subtitle" ] [ text s ]


{-| Dialog visibility (true if open or closing) -}
isVisible : Model -> Bool
isVisible { open, transition } =
  open || Transit.getStep transition == Exit


{-| Dialog opacity (0 -> 1 on opening, 1 -> 0 on closing) -}
opacity : Model -> Float
opacity { open, transition } =
  if open then
    case Transit.getStep transition of
      Exit ->
        0

      Enter ->
        Transit.getValue transition

      Done ->
        1
  else
    case Transit.getStep transition of
      Exit ->
        Transit.getValue transition

      _ ->
        0


{-| Helper for `display` property (CSS) -}
display : Model -> String
display model =
  if isVisible model then
    "block"
  else
    "none"
