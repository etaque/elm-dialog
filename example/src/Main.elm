module Main exposing (..)

import Html.App as Html
import Update exposing (init, update, subscriptions)
import View exposing (view)


main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
