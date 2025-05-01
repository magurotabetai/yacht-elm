module Views.Battle exposing (viewBattle)

import Html exposing (Html, button, div, h1, h2, h3, p, span, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Models.Battle.Types exposing (Battle, BattleState(..))
import Models.Game exposing (GameState, Run)
import Models.Score exposing (calculateScoreValue, isScoreAvailable)
import Models.Score.DamageCalculator exposing (formatMultiplier)
import Models.Types exposing (ScoreType(..))
import Time
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (spacer, viewBadge, viewButton)



-- バトル画面の表示


viewBattle : GameState -> Run -> Battle -> Html Msg
viewBattle gameState run battle =
    div [ class "battle-screen" ]
        [ viewBattleHeader battle
        , div [ class "battle-main" ]
            [ viewBattleLeft battle
            , viewBattleRight battle
            ]
        , viewBattleFooter battle.log.entries
        ]



-- バトルヘッダー（敵情報と自分の情報）


viewBattleHeader : Battle -> Html Msg
viewBattleHeader battle =
    div [ class "battle-header" ]
        [ viewEnemyInfo battle
        , viewPlayerInfo battle
        ]



-- 敵の情報表示


viewEnemyInfo : Battle -> Html Msg
viewEnemyInfo battle =
    let
        isEnemyBoss =
            String.contains "boss" battle.enemyId || String.contains "dragon" battle.enemyId
    in
    div [ class "enemy-info" ]
        [ div [ class "enemy-header" ]
            [ h2 []
                [ text battle.enemyName
                , if isEnemyBoss then
                    viewBadge "boss" "ボス"

                  else
                    text ""
                ]
            ]
        , div [ class "health-bar" ]
            [ div
                [ class "health-fill"
                , style "width" (String.fromFloat (toFloat battle.enemyCurrentHP / toFloat battle.enemyMaxHP * 100) ++ "%")
                ]
                []
            ]
        , div [ class "health-text" ]
            [ text (String.fromInt battle.enemyCurrentHP ++ " / " ++ String.fromInt battle.enemyMaxHP) ]
        ]



-- プレイヤー情報表示


viewPlayerInfo : Battle -> Html Msg
viewPlayerInfo battle =
    div [ class "player-info" ]
        [ div [ class "player-health" ]
            [ text ("HP: " ++ String.fromInt battle.playerCurrentHP ++ " / " ++ String.fromInt battle.playerMaxHP) ]
        , div [ class "turn-info" ]
            [ text ("ターン: " ++ String.fromInt battle.turn) ]
        ]



-- バトルの左側エリア（ダイス、アクションエリア）


viewBattleLeft : Battle -> Html Msg
viewBattleLeft battle =
    div [ class "battle-left" ]
        [ div [ class "dice-area" ]
            [ h3 [] [ text "ダイス" ]
            , div [ class "dice-container" ]
                (List.map viewDice battle.dice)
            , div [ class "rerolls-info" ]
                [ text
                    ("残りリロール: "
                        ++ String.fromInt battle.remainingRerolls
                        ++ " / "
                        ++ String.fromInt battle.maxRerolls
                    )
                ]
            ]
        , div [ class "action-buttons" ]
            [ viewButton "振り直す" RollDice (battle.remainingRerolls <= 0 || battle.state /= Rolling)
            , viewButton "スコア決定" ConfirmScore (battle.selectedScoreType == Nothing)
            ]
        ]



-- ダイス表示


viewDice : { id : String, value : Int, held : Bool, diceType : a, effects : b } -> Html Msg
viewDice dice =
    div
        [ class
            ("dice dice-normal"
                ++ (if dice.held then
                        " dice-held"

                    else
                        ""
                   )
            )
        , onClick (ToggleHoldDice dice.id)
        ]
        [ text (String.fromInt dice.value) ]



-- バトルの右側エリア（スコアカード、アイテムエリア）


viewBattleRight : Battle -> Html Msg
viewBattleRight battle =
    div [ class "battle-right" ]
        [ div [ class "card" ]
            [ div [ class "card-header" ] [ text "スコアカード" ]
            , div [ class "card-content" ]
                [ viewScoreCard battle ]
            ]
        , spacer 3
        , div [ class "card" ]
            [ div [ class "card-header" ] [ text "バトル状態" ]
            , div [ class "card-content" ]
                [ viewBattleState battle.state ]
            ]
        ]



-- バトル状態の表示


viewBattleState : BattleState -> Html Msg
viewBattleState state =
    let
        ( stateText, stateClass ) =
            case state of
                Rolling ->
                    ( "ダイスロール中", "state-rolling" )

                Selecting ->
                    ( "スコア選択中", "state-selecting" )

                EnemyTurn ->
                    ( "敵のターン", "state-enemy-turn" )

                BattleOver ->
                    ( "バトル終了", "state-battle-over" )
    in
    div [ class ("battle-state " ++ stateClass) ]
        [ text stateText ]



-- スコアカード表示


viewScoreCard : Battle -> Html Msg
viewScoreCard battle =
    div [ class "score-sections" ]
        [ div [ class "score-section" ]
            [ h3 [] [ text "上の部" ]
            , viewScoreRow battle "エース (1)" (viewScoreValue battle Aces) Aces
            , viewScoreRow battle "デュース (2)" (viewScoreValue battle Twos) Twos
            , viewScoreRow battle "トリプル (3)" (viewScoreValue battle Threes) Threes
            , viewScoreRow battle "フォー (4)" (viewScoreValue battle Fours) Fours
            , viewScoreRow battle "フィフス (5)" (viewScoreValue battle Fives) Fives
            , viewScoreRow battle "シックス (6)" (viewScoreValue battle Sixes) Sixes
            ]
        , div [ class "score-section" ]
            [ h3 [] [ text "下の部" ]
            , viewScoreRow battle "チョイス" (viewScoreValue battle Choice) Choice
            , viewScoreRow battle "フォーカインド" (viewScoreValue battle FourOfKind) FourOfKind
            , viewScoreRow battle "フルハウス" (viewScoreValue battle FullHouse) FullHouse
            , viewScoreRow battle "Sストレート" (viewScoreValue battle SmallStraight) SmallStraight
            , viewScoreRow battle "Lストレート" (viewScoreValue battle LargeStraight) LargeStraight
            , viewScoreRow battle "ヨット" (viewScoreValue battle Yacht) Yacht
            ]
        ]



-- スコア値の表示形式を決定


viewScoreValue : Battle -> ScoreType -> String
viewScoreValue battle scoreType =
    if isScoreAvailable scoreType battle.scoreHistory then
        String.fromInt (calculateScoreValue scoreType battle.dice)

    else
        "✓"



-- 使用済みの場合はチェックマーク表示
-- スコア行表示


viewScoreRow : Battle -> String -> String -> ScoreType -> Html Msg
viewScoreRow battle label value scoreType =
    let
        isAvailable =
            isScoreAvailable scoreType battle.scoreHistory

        rowClass =
            "score-row"
                ++ (if battle.selectedScoreType == Just scoreType then
                        " selected-score"

                    else
                        ""
                   )
                ++ (if not isAvailable then
                        " used-score"

                    else
                        ""
                   )
    in
    div
        [ class rowClass
        , if isAvailable then
            onClick (SelectScore scoreType)

          else
            class ""
        ]
        [ div [ class "score-label" ]
            [ text label
            , span [ class "multiplier-text" ] [ text (formatMultiplier scoreType) ]
            ]
        , div [ class "score-value" ] [ text value ]
        ]



-- バトルフッター（バトルログエリア）


viewBattleFooter : List { message : String, timestamp : Time.Posix } -> Html Msg
viewBattleFooter logEntries =
    div [ class "battle-footer" ]
        [ div [ class "battle-log" ]
            [ h3 [] [ text "バトルログ" ]
            , div [ class "log-entries" ]
                (List.map viewLogEntry (List.take 5 logEntries))
            ]
        ]



-- ログエントリー表示


viewLogEntry : { message : String, timestamp : Time.Posix } -> Html Msg
viewLogEntry logEntry =
    div [ class "log-entry" ] [ text logEntry.message ]
