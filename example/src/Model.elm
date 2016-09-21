module Model exposing (..)

import Foo.Model as Foo
import Bar.Model as Bar


type alias Model =
    { route : Route
    , foo : Foo.Model
    , bar : Bar.Model
    }


type Route
    = Foo
    | Bar


type Msg
    = SetRoute Route
    | FooMsg Foo.Msg
    | BarMsg Bar.Msg


initialModel : Model
initialModel =
    { route = Foo
    , foo = Foo.initial
    , bar = Bar.initial
    }
