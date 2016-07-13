module Main exposing (..)

import Html.App as App
import Components.App exposing (..)


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (\_ -> Sub.none)
        }
