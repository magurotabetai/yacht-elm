module Models.Score.DamageCalculator exposing
    ( ScoreMultiplier
    , calculateDamageFromScore
    , formatMultiplier
    , getScoreMultiplier
    )

import Models.Dice exposing (Dice)
import Models.Score exposing (calculateScoreValue)
import Models.Types exposing (ScoreType(..))



-- スコア倍率を表す型


type alias ScoreMultiplier =
    { scoreType : ScoreType
    , multiplier : Float
    , description : String
    }



-- 全ての役に対する倍率定義


scoreMultipliers : List ScoreMultiplier
scoreMultipliers =
    [ { scoreType = Aces, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = Twos, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = Threes, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = Fours, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = Fives, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = Sixes, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = Choice, multiplier = 1.0, description = "基本ダメージ" }
    , { scoreType = FourOfKind, multiplier = 1.4, description = "中程度ボーナス" }
    , { scoreType = FullHouse, multiplier = 1.6, description = "大きめボーナス" }
    , { scoreType = SmallStraight, multiplier = 1.2, description = "小ボーナス" }
    , { scoreType = LargeStraight, multiplier = 1.8, description = "大きなボーナス" }
    , { scoreType = Yacht, multiplier = 2.0, description = "最大ボーナス" }
    ]



-- 特定のスコアタイプの倍率を取得する


getScoreMultiplier : ScoreType -> Float
getScoreMultiplier scoreType =
    case scoreType of
        Special _ ->
            1.0

        _ ->
            scoreMultipliers
                |> List.filter (\m -> m.scoreType == scoreType)
                |> List.head
                |> Maybe.map .multiplier
                |> Maybe.withDefault 1.0



-- 倍率を文字列にフォーマットする


formatMultiplier : ScoreType -> String
formatMultiplier scoreType =
    let
        multiplier =
            getScoreMultiplier scoreType
    in
    if multiplier > 1.0 then
        "×" ++ String.fromFloat multiplier

    else
        ""



-- スコアからダメージを計算する


calculateDamageFromScore : ScoreType -> List Dice -> Int
calculateDamageFromScore scoreType dice =
    let
        -- ダイスの出目から直接スコアを計算
        scoreValue =
            calculateScoreValue scoreType dice

        -- 倍率を適用したダメージ計算
        finalDamage =
            round (toFloat scoreValue * getScoreMultiplier scoreType)
    in
    max 1 finalDamage



-- 最低でも1ダメージは保証
