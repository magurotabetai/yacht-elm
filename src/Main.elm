module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (class)
import Browser.Events exposing (onResize)
import Time

-- Domain models
import Models.Game as Game exposing (GameState)
import Models.Types exposing (GamePhase(..))

-- Update logic
import Update.Messages as Msg exposing (Msg)
import Update.Update as Update exposing (init, update)

-- View components
import Views.Router as Router


-- APPLICATION

main : Program () GameState Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


-- VIEW

view : GameState -> Html Msg
view =
    Router.view


-- SUBSCRIPTIONS

subscriptions : GameState -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onResize Msg.WindowResize
        , Time.every 1000 Msg.TickTime  -- 時間ベースの更新（1秒ごと）
        ]
