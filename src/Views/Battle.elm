module Views.Battle exposing (viewBattle)

import Html exposing (Html, div, h1, h2, h3, p, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Models.Dice exposing (Dice)
import Models.Game exposing (GameState, Run, Battle)
import Models.Score exposing (ScoreCard)
import Models.Types exposing (ScoreType(..))
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (viewButton, viewCard, viewBadge, spacer)


viewBattle : GameState -> Run -> Battle -> Html Msg
viewBattle gameState run battle =
    div [ class "battle-screen" ]
        [ div [ class "battle-header" ]
            [ viewEnemyInfo battle
            , viewPlayerInfo run
            ]
        , div [ class "battle-main" ]
            [ div [ class "battle-left" ]
                [ viewDiceArea battle
                , viewActionButtons battle
                ]
            , div [ class "battle-right" ]
                [ viewScoreCard battle
                ]
            ]
        , div [ class "battle-footer" ]
            [ viewBattleLog battle
            ]
        ]

-- 敵情報の表示
viewEnemyInfo : Battle -> Html Msg
viewEnemyInfo battle =
    let
        enemy = battle.enemy
        isBossBattle = battle.boss /= Nothing
    in
    div [ class "enemy-info" ]
        [ div [ class "enemy-header" ]
            [ h2 [] [ text enemy.name ]
            , if isBossBattle then
                viewBadge "boss" "ボス"
              else
                text ""
            ]
        , div [ class "enemy-health" ]
            [ div [ class "health-bar" ]
                [ div
                    [ class "health-fill"
                    , Html.Attributes.style "width" (String.fromFloat (toFloat enemy.hp / toFloat enemy.maxHp * 100) ++ "%")
                    ]
                    []
                ]
            , div [ class "health-text" ]
                [ text (String.fromInt enemy.hp ++ " / " ++ String.fromInt enemy.maxHp) ]
            ]
        , div [ class "enemy-attacks" ]
            (List.map
                (\attack ->
                    div [ class "attack-info" ]
                        [ span [ class "attack-name" ] [ text attack.name ]
                        , span [ class "attack-damage" ] [ text ("攻撃力: " ++ String.fromInt attack.damage) ]
                        ]
                )
                enemy.attacks
            )
        ]

-- プレイヤー情報の表示
viewPlayerInfo : Run -> Html Msg
viewPlayerInfo run =
    div [ class "player-info" ]
        [ div [ class "player-health" ]
            [ div [ class "health-bar" ]
                [ div
                    [ class "health-fill"
                    , Html.Attributes.style "width" (String.fromFloat (toFloat run.currentHP / toFloat run.maxHP * 100) ++ "%")
                    ]
                    []
                ]
            , div [ class "health-text" ]
                [ text (String.fromInt run.currentHP ++ " / " ++ String.fromInt run.maxHP) ]
            ]
        , div [ class "player-stats" ]
            [ div [ class "gold-info" ]
                [ span [ class "gold-icon" ] [ text "💰" ]
                , text (String.fromInt run.gold)
                ]
            ]
        ]

-- ダイスエリアの表示
viewDiceArea : Battle -> Html Msg
viewDiceArea battle =
    div [ class "dice-area" ]
        [ h3 [] [ text "ダイス" ]
        , div [ class "dice-container" ]
            (List.map viewDice battle.dice)
        , div [ class "rerolls-info" ]
            [ text ("残りリロール回数: " ++ String.fromInt battle.remainingRerolls) ]
        ]

-- ダイスの表示
viewDice : Dice -> Html Msg
viewDice dice =
    let
        diceClass =
            case dice.diceType of
                Models.Types.Normal -> "dice-normal"
                Models.Types.Fire -> "dice-fire"
                Models.Types.Ice -> "dice-ice"
                Models.Types.Thunder -> "dice-thunder"
                Models.Types.Cursed -> "dice-cursed"
                Models.Types.Rare -> "dice-rare"
    in
    div
        [ classList
            [ ("dice", True)
            , (diceClass, True)
            , ("dice-held", dice.held)
            ]
        , onClick (ToggleHoldDice dice.id)
        ]
        [ div [ class "dice-value" ] [ text (String.fromInt dice.value) ]
        ]

-- アクションボタンの表示
viewActionButtons : Battle -> Html Msg
viewActionButtons battle =
    div [ class "action-buttons" ]
        [ viewButton "ダイスを振る" RollDice (battle.remainingRerolls <= 0)
        , viewButton "ターン終了" EndTurn False
        ]

-- スコアカードの表示
viewScoreCard : Battle -> Html Msg
viewScoreCard battle =
    let
        scoreCard = battle.scoreCard
    in
    viewCard "スコアカード"
        [ div [ class "score-sections" ]
            [ div [ class "score-section upper" ]
                [ h3 [] [ text "上段" ]
                , viewScoreRow "エース (1)" Aces scoreCard.aces
                , viewScoreRow "デュース (2)" Twos scoreCard.twos
                , viewScoreRow "トリプル (3)" Threes scoreCard.threes
                , viewScoreRow "フォー (4)" Fours scoreCard.fours
                , viewScoreRow "フィフス (5)" Fives scoreCard.fives
                , viewScoreRow "シックス (6)" Sixes scoreCard.sixes
                ]
            , div [ class "score-section lower" ]
                [ h3 [] [ text "下段" ]
                , viewScoreRow "チョイス" Choice scoreCard.choice
                , viewScoreRow "フォーカインド" FourOfKind scoreCard.fourOfKind
                , viewScoreRow "フルハウス" FullHouse scoreCard.fullHouse
                , viewScoreRow "Sストレート" SmallStraight scoreCard.smallStraight
                , viewScoreRow "Lストレート" LargeStraight scoreCard.largeStraight
                , viewScoreRow "ヨット" Yacht scoreCard.yacht
                ]
            ]
        ]

-- スコア行の表示
viewScoreRow : String -> ScoreType -> Maybe Int -> Html Msg
viewScoreRow label scoreType maybeScore =
    div
        [ class "score-row"
        , onClick (SelectScore scoreType)
        ]
        [ div [ class "score-label" ] [ text label ]
        , div [ class "score-value" ]
            [ text
                (case maybeScore of
                    Just score -> String.fromInt score
                    Nothing -> "-"
                )
            ]
        ]

-- バトルログの表示
viewBattleLog : Battle -> Html Msg
viewBattleLog battle =
    div [ class "battle-log" ]
        [ h3 [] [ text "バトルログ" ]
        , div [ class "log-entries" ]
            (List.map
                (\entry -> div [ class "log-entry" ] [ text entry ])
                (List.reverse battle.battleLog)
            )
        ]
