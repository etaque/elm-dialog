# Elm Dialog

    elm package install etaque/elm-dialog

A modal component for [Elm](http://elm-lang.org/). Not named `elm-modal` because it would be type-error-prone with the `model` we have everywhere in our apps!

## Features

* Plug it once, use it from anywhere in your app (by sending a message),
* Simple view/style provided ([screenshot](https://raw.githubusercontent.com/etaque/elm-dialog/master/screenshot.png)) but can work with any css framework,
* Animation-ready: built on top of [elm-transit](http://package.elm-lang.org/packages/etaque/elm-transit/latest), so you can add open/close effects and wait until animation is ended before seing your actions triggered.


## Usage

Don't forged to `import Dialog` in every impacted module. See [example/](./example/) for a fully working usage example.

### Model

Add the dialog instance to your model:

```elm
type alias Model = WithDialog { ... }

-- or without record extension:
type alias Model = 
  { dialog : Dialog
  , ...
  }
```

See `getContent`, `getOptions`, `getTransition`, `isOpen` and `isVisible` for model querying. Initialize it with `dialog = Dialog.initial`.

Add a type case for the dialog actions:

```elm
type Action
  = NoOp
  | ...
  | DialogAction Dialog.Action
```

### Update

* Add the case match for the dialog actions. If you've chosen the record extension, then you can use the `wrappedUpdate`, otherwise you should use the regular `update` function.

```elm
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    DialogAction dialogAction ->
      Dialog.wrappedUpdate DialogAction dialogAction model
```

* Plug dialog signal as input into your app. With StartApp, that would be:

```elm
StartApp.Start 
  { ...
  , inputs = [ Signal.map DialogAction Dialog.actions ]
  }
```

### View

This package provides a simple theme under `Dialog.Simple`, [here](./example/styles/simple.css)
is a default stylesheet (you can roll out your own theme if you need it).

* Plug `Simple.view` at the bottom of your top-level view. It's only a shell, hidden by default.
  It will be in charge of showing up the dialog content and backdrop according to state.
 
```elm
view : Address Action -> Model -> Html
view addr model =
  div
    [ ]
    [ ... -- your app view
    , Dialog.Simple.view model.dialog
    ]
``` 

* Open the dialog with `openOnClick` (or `openWithOptionsOnClick` if you need more control):
 
```elm
-- Somewhere in your views, where you need to open a dialog
somePartOfYourView addr =
  button
    [ Dialog.openOnClick (dialog addr) ]
    [ text "..." ]
    
dialog : Address Action -> Dialog.Options -> List Html
dialog addr options =
  [ Dialog.header options "Are you sure?"
  , Dialog.body
      [ p [] [ text "Please give it a second thought." ] ]
  , Dialog.footer
      [ a
          [ class "btn btn-default"
          , Dialog.onClickHide
          ]
          [ text "You make me doubt" ]
      , a
          [ class "btn btn-primary"
          , Dialog.onClickHideThenSend addr SomeAction
          ]
          [ text "FFS, go on!" ]
      ]
  ]

```
Here we're using:

* `header` as the title decorator, taking `options` as parameter: if `options.onClose` is non empty, it will display a close button
* `body` for the message of the modal
* `footer` for the actions.

Options are:
* `duration` for the fade animation, in ms
* `onClose` for the task to run when closing the modal. Set to `Nothing` to prevent closing.


### Actions

The package provide two levels to control dialog:

* The basis is `address : Address Dialog.Action` in combination with those action builders: 
  * `open`, `openWithOptions` to open the modal with the provided content,
  * `updateContent` to update content without touching opened state
  * `close`, `closeThenSend`, `closeThenDo` to close the modal and send a message/run a task.
  
  That makes it controllable from everywhere in your app, not only views.

* Some `onClick` shortcuts are available for the views, they produce an HTML attribute:
  * `openOnClick` and `openWithOptionsOnClick`
  * `closeOnClick` and `closeThenSendOnClick`

## Credits

* [tg-modal](https://github.com/thorgate/tg-modal) for the simple stylesheet
