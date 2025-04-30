module Models.Score.DamageCalculator exposing 
    ( ScoreMultiplier
    , getScoreMultiplier
    , calculateDamageFromScore
    , formatMultiplier
    )

import Models.Types exposing (ScoreType(..))
import Models.Score exposing (ScoreCard)

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
        multiplier = getScoreMultiplier scoreType
    in
    if multiplier > 1.0 then
        "×" ++ String.fromFloat multiplier
    else
        ""

-- スコアからダメージを計算する
calculateDamageFromScore : ScoreType -> ScoreCard -> Int
calculateDamageFromScore scoreType scoreCard =
    let
        -- スコアタイプに応じた値を取得
        scoreValue = 
            case scoreType of
                Aces -> Maybe.withDefault 0 scoreCard.aces
                Twos -> Maybe.withDefault 0 scoreCard.twos
                Threes -> Maybe.withDefault 0 scoreCard.threes
                Fours -> Maybe.withDefault 0 scoreCard.fours
                Fives -> Maybe.withDefault 0 scoreCard.fives
                Sixes -> Maybe.withDefault 0 scoreCard.sixes
                Choice -> Maybe.withDefault 0 scoreCard.choice
                FourOfKind -> Maybe.withDefault 0 scoreCard.fourOfKind
                FullHouse -> Maybe.withDefault 0 scoreCard.fullHouse
                SmallStraight -> Maybe.withDefault 0 scoreCard.smallStraight
                LargeStraight -> Maybe.withDefault 0 scoreCard.largeStraight
                Yacht -> Maybe.withDefault 0 scoreCard.yacht
                Special name -> 
                    -- 特殊スコアは対応する specialScores から取得
                    scoreCard.specialScores
                        |> List.filter (\s -> s.scoreType == name)
                        |> List.head
                        |> Maybe.andThen .value
                        |> Maybe.withDefault 0
        
        -- 倍率を適用したダメージ計算
        finalDamage = round (toFloat scoreValue * getScoreMultiplier scoreType)
    in
    max 1 finalDamage  -- 最低でも1ダメージは保証