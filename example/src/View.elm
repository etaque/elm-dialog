module View exposing (..)

import Html.App as Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Dialog
import Model exposing (..)
import Layout exposing (renderLayout)
import Foo.View as Foo
import Bar.View as Bar


view : Model -> Html Msg
view model =
    case model.route of
        Foo ->
            renderLayout FooMsg (Foo.view model.foo)

        Bar ->
            renderLayout BarMsg (Bar.view model.bar)
