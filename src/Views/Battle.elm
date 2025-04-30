module Views.Battle exposing (viewBattle)

import Html exposing (Html, div, h1, h2, h3, p, text, button, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Models.Game exposing (GameState, Run, Battle)
import Models.Types exposing (ScoreType(..), EnemyData, BossData)
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (viewButton, spacer, viewBadge)

-- バトル画面の表示
viewBattle : GameState -> Run -> Battle -> Html Msg
viewBattle gameState run battle =
    div [ class "battle-screen" ]
        [ viewBattleHeader battle.enemy battle.boss
        , div [ class "battle-main" ]
            [ viewBattleLeft battle
            , viewBattleRight battle
            ]
        , viewBattleFooter battle.battleLog
        ]

-- バトルヘッダー（敵情報と自分の情報）
viewBattleHeader : EnemyData -> Maybe BossData -> Html Msg
viewBattleHeader enemy boss =
    div [ class "battle-header" ]
        [ viewEnemyInfo enemy boss
        , viewPlayerInfo
        ]

-- 敵の情報表示
viewEnemyInfo : EnemyData -> Maybe BossData -> Html Msg
viewEnemyInfo enemy boss =
    div [ class "enemy-info" ]
        [ div [ class "enemy-header" ]
            [ h2 []
                [ text enemy.name
                , if boss /= Nothing then viewBadge "boss" "ボス" else text ""
                ]
            ]
        , div [ class "health-bar" ]
            [ div
                [ class "health-fill"
                , style "width" (String.fromFloat (toFloat enemy.hp / toFloat enemy.maxHp * 100) ++ "%")
                ]
                []
            ]
        , div [ class "health-text" ]
            [ text (String.fromInt enemy.hp ++ " / " ++ String.fromInt enemy.maxHp) ]
        , div [ class "enemy-attacks" ]
            (List.map viewEnemyAttack enemy.attacks)
        ]

-- 敵の攻撃情報表示
viewEnemyAttack : { name : String, damage : Int, description : String } -> Html Msg
viewEnemyAttack attack =
    div [ class "attack-info" ]
        [ span [ class "attack-name" ] [ text attack.name ]
        , span [] [ text (String.fromInt attack.damage ++ "ダメージ") ]
        ]

-- プレイヤー情報表示
viewPlayerInfo : Html Msg
viewPlayerInfo =
    div [ class "player-info" ]
        [ div [ class "gold-info" ]
            [ span [ class "gold-icon" ] [ text "💰" ]
            , span [] [ text "100" ]
            ]
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
                [ text ("残りリロール: " ++ String.fromInt battle.remainingRerolls ++ " / 2") ]
            ]
        , div [ class "action-buttons" ]
            [ viewButton "振り直す" RollDice (battle.remainingRerolls <= 0)
            , viewButton "スコア決定" NoOp False
            ]
        ]

-- ダイス表示
viewDice : { id : String, value : Int, held : Bool, diceType : a, effects : b } -> Html Msg
viewDice dice =
    div
        [ class ("dice dice-normal" ++ if dice.held then " dice-held" else "")
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
            [ div [ class "card-header" ] [ text "アイテム" ]
            , div [ class "card-content" ]
                [ text "実装予定" ]
            ]
        ]

-- スコアカード表示
viewScoreCard : Battle -> Html Msg
viewScoreCard battle =
    div [ class "score-sections" ]
        [ div [ class "score-section" ]
            [ h3 [] [ text "上の部" ]
            , viewScoreRow "エース (1)" (Maybe.map String.fromInt battle.scoreCard.aces |> Maybe.withDefault "-") Aces
            , viewScoreRow "デュース (2)" (Maybe.map String.fromInt battle.scoreCard.twos |> Maybe.withDefault "-") Twos
            , viewScoreRow "トリプル (3)" (Maybe.map String.fromInt battle.scoreCard.threes |> Maybe.withDefault "-") Threes
            , viewScoreRow "フォー (4)" (Maybe.map String.fromInt battle.scoreCard.fours |> Maybe.withDefault "-") Fours
            , viewScoreRow "フィフス (5)" (Maybe.map String.fromInt battle.scoreCard.fives |> Maybe.withDefault "-") Fives
            , viewScoreRow "シックス (6)" (Maybe.map String.fromInt battle.scoreCard.sixes |> Maybe.withDefault "-") Sixes
            ]
        , div [ class "score-section" ]
            [ h3 [] [ text "下の部" ]
            , viewScoreRow "チョイス" (Maybe.map String.fromInt battle.scoreCard.choice |> Maybe.withDefault "-") Choice
            , viewScoreRow "フォーカインド" (Maybe.map String.fromInt battle.scoreCard.fourOfKind |> Maybe.withDefault "-") FourOfKind
            , viewScoreRow "フルハウス" (Maybe.map String.fromInt battle.scoreCard.fullHouse |> Maybe.withDefault "-") FullHouse
            , viewScoreRow "Sストレート" (Maybe.map String.fromInt battle.scoreCard.smallStraight |> Maybe.withDefault "-") SmallStraight
            , viewScoreRow "Lストレート" (Maybe.map String.fromInt battle.scoreCard.largeStraight |> Maybe.withDefault "-") LargeStraight
            , viewScoreRow "ヨット" (Maybe.map String.fromInt battle.scoreCard.yacht |> Maybe.withDefault "-") Yacht
            ]
        ]

-- スコア行表示
viewScoreRow : String -> String -> ScoreType -> Html Msg
viewScoreRow label value scoreType =
    div [ class "score-row", onClick (SelectScore scoreType) ]
        [ div [ class "score-label" ] [ text label ]
        , div [ class "score-value" ] [ text value ]
        ]

-- バトルフッター（バトルログエリア）
viewBattleFooter : List String -> Html Msg
viewBattleFooter logs =
    div [ class "battle-footer" ]
        [ div [ class "battle-log" ]
            [ h3 [] [ text "バトルログ" ]
            , div [ class "log-entries" ]
                (List.map viewLogEntry (List.take 5 logs))
            ]
        ]

-- ログエントリー表示
viewLogEntry : String -> Html Msg
viewLogEntry log =
    div [ class "log-entry" ] [ text log ]
