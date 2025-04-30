module Main exposing (main)

import Browser
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Models.Game exposing (GameState)
import Models.Types exposing (GamePhase(..))
import Update.Messages exposing (Msg)
import Update.Update exposing (init, update)
import Views.Battle exposing (viewBattle)
import Views.CharacterSelection exposing (viewCharacterSelection)
import Views.MainMenu exposing (viewMainMenu)
import Views.Map exposing (viewMap)
import Browser.Events exposing (onResize)
import Time


main : Program () GameState Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


-- メインビュー関数
view : GameState -> Html Msg
view model =
    div [ class "game-container" ]
        [ div [ class "game-content" ]
            [ viewCurrentScreen model
            ]
        ]


-- 現在のゲーム状態に基づいて適切な画面を表示
viewCurrentScreen : GameState -> Html Msg
viewCurrentScreen model =
    case model.gamePhase of
        MainMenu ->
            viewMainMenu model

        CharacterSelection ->
            viewCharacterSelection model

        InRun ->
            case model.currentRun of
                Just run ->
                    viewMap model run

                Nothing ->
                    div [ class "error-message" ] [ Html.text "ゲームデータが見つかりません" ]

        BattlePhase ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            viewBattle model run battle

                        Nothing ->
                            div [ class "error-message" ] [ Html.text "戦闘データが見つかりません" ]

                Nothing ->
                    div [ class "error-message" ] [ Html.text "ゲームデータが見つかりません" ]

        EventPhase ->
            div [ class "temp-message" ] [ Html.text "イベント画面は開発中です" ]

        GameOver ->
            div [ class "temp-message" ] [ Html.text "ゲームオーバー画面は開発中です" ]

        Victory ->
            div [ class "temp-message" ] [ Html.text "勝利画面は開発中です" ]


-- サブスクリプション
subscriptions : GameState -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 1000 Update.Messages.TickTime  -- 1秒ごとに時間更新
        , onResize Update.Messages.WindowResize  -- ウィンドウサイズ変更検知
        ]
