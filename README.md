# Elm Dialog

    elm package install etaque/elm-dialog

A modal component for [Elm](http://elm-lang.org/). Not named `elm-modal` because it would be type-error-prone with the `model` we have everywhere in our apps!


## Features

* Plug it once, use it from anywhere in your app
* Simple view/style provided but can work with any css framework
* Animation-ready: built on top of [elm-transit](http://package.elm-lang.org/packages/etaque/elm-transit/latest), you can add open/close effects and wait until animation is ended to trigger your own actions.


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

Initialize it with `dialog = Dialog.initial`. Prepare a case for the dialog actions:

```elm
type Action
  = NoOp
  | ...
  | DialogAction Dialog.Action
```

### Update

* Add the case match for the dialog actions. If you've chosen the record extension, then you can use the `wrappedUpdate`.
  The first parameter (`150`) is the duration of the animation, in milliseconds.


```elm
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ...

    DialogAction dialogAction ->
      Dialog.wrappedUpdate 150 DialogAction dialogAction model
    
    -- without record extension:
    DialogAction dialogAction ->
      let
        (newDialog, dialogFx) = Dialog.update 150 dialogAction model.dialog
      in
        ({ model | dialog = newDialog }, Effects.map DialogAction dialogFx)
```

* Add dialog actions signal as an input to your app. With StartApp, that would be:

```elm
StartApp.Start 
  { ...
  , inputs = [ Signal.map DialogAction Dialog.actions ]
  }
```

### View

You can find *[here](./example/styles/simple.css)* a default stylesheet for the dialog. On Elm side, it's a two-steps process:

* Plug the Dialog view at the root of your view. It's only a shell, hidden by default.
  It will be in charge of showing up the dialog content and backdrop according to state.
 
```elm
view : Address Action -> Model -> Html
view addr model =
  div
    [ ]
    [ ... -- your app view
    , Dialog.view model.dialog
    ]
``` 


* Trigger the modal by sending it's content:
 
```elm
-- Somewhere in your views, where you need to trigger a modal
somePartOfYourView addr =
  button
    [ Dialog.onClickShow (dialog addr) ]
    [ text "..." ]
    
dialog : Address Action -> List Html
dialog addr =
  [ Dialog.header "Are you sure?"
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

Those are the **Simple** modal style decorators provided with the package. You can totally build your own modal renderer! Just copy & paste the source code in your app and adapt it to your needs. To sum up, here we have:

* `view` as the modal decorator, in charge of display/hide control and animations,
* `header` as the title decorator (see also `headerNoClose` and `headerCustomClose` in package doc),
* `body` for the message of the modal,
* `footer` for the actions.

Note also the `opacity` and `display` helpers for fading and visibity control.


### Controlling the dialog

The package provide two levels to control dialog:

* The basis is `address : Address Dialog.Action` in combination with those action builders: 
  * `show : List Html -> Dialog.Action` shows up the modal with the provided content,
  * `hide : Dialog.Action` hides the modal,
  * `hideThenSend : Address a -> a -> Dialog.Action` hides the modal then send the given action to the supplied address when hide animation is done.
  
  That makes it controllable from everywhere in your app, not only views.

* Some `onClick` shortcuts for those action builders:
  * `onClickShow : List Html -> Attribute`
  * `onClickHide : Attribute`
  * `onClickHideThenSend : Address a -> a -> Attribute`


## What's next

* We could add decorators for the main CSS frameworks, something like `Dialog.Bootstrap`

PRs welcome!
