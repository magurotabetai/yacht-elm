module Main exposing (main)

-- Domain models
-- Update logic
-- View components

import Browser
import Browser.Events exposing (onResize)
import Html exposing (Html)
import Models.Game exposing (GameState)
import Models.Types exposing (GamePhase(..))
import Time
import Update.Messages as Msg exposing (Msg)
import Update.Update exposing (init, update)
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
        , Time.every 1000 Msg.TickTime -- 時間ベースの更新（1秒ごと）
        ]
