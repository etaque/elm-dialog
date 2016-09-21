module Update exposing (..)

import Foo.Update as Foo
import Bar.Update as Bar
import Model exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map FooMsg (Foo.subscriptions model.foo)
        , Sub.map BarMsg (Bar.subscriptions model.bar)
        ]


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute route ->
            ( { model | route = route }, Cmd.none )

        FooMsg fooMsg ->
            let
                ( newFoo, fooCmd ) =
                    Foo.update fooMsg model.foo
            in
                ( { model | foo = newFoo }, Cmd.map FooMsg fooCmd )

        BarMsg barMsg ->
            let
                ( newBar, barCmd ) =
                    Bar.update barMsg model.bar
            in
                ( { model | bar = newBar }, Cmd.map BarMsg barCmd )
