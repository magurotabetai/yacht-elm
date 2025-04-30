module Models.Score exposing
    ( sumOfFace
    , sumAllDice
    , calculateFourOfKind
    , calculateFullHouse
    , calculateSmallStraight
    , calculateLargeStraight
    , calculateYacht
    , calculateScore
    , countValues
    , ScoreCard
    , SpecialScore
    , initScoreCard
    , initScoreHistory
    , calculatePossibleScores
    , markScoreUsed
    , isScoreAvailable
    , scoreCardToHistory
    )

import Models.Dice exposing (Dice)
import Models.Types exposing (..)

-- スコア履歴初期化
initScoreHistory : ScoreHistory
initScoreHistory =
    { aces = False
    , twos = False
    , threes = False
    , fours = False
    , fives = False
    , sixes = False
    , choice = False
    , fourOfKind = False
    , fullHouse = False
    , smallStraight = False
    , largeStraight = False
    , yacht = False
    , specialScores = []
    }

-- スコア使用を記録
markScoreUsed : ScoreType -> ScoreHistory -> ScoreHistory
markScoreUsed scoreType history =
    case scoreType of
        Aces -> { history | aces = True }
        Twos -> { history | twos = True }
        Threes -> { history | threes = True }
        Fours -> { history | fours = True }
        Fives -> { history | fives = True }
        Sixes -> { history | sixes = True }
        Choice -> { history | choice = True }
        FourOfKind -> { history | fourOfKind = True }
        FullHouse -> { history | fullHouse = True }
        SmallStraight -> { history | smallStraight = True }
        LargeStraight -> { history | largeStraight = True }
        Yacht -> { history | yacht = True }
        Special id -> { history | specialScores = id :: history.specialScores }

-- スコアが使用可能かチェック
isScoreAvailable : ScoreType -> ScoreHistory -> Bool
isScoreAvailable scoreType history =
    case scoreType of
        Aces -> not history.aces
        Twos -> not history.twos
        Threes -> not history.threes
        Fours -> not history.fours
        Fives -> not history.fives
        Sixes -> not history.sixes
        Choice -> not history.choice
        FourOfKind -> not history.fourOfKind
        FullHouse -> not history.fullHouse
        SmallStraight -> not history.smallStraight
        LargeStraight -> not history.largeStraight
        Yacht -> not history.yacht
        Special id -> not (List.member id history.specialScores)

-- 特定の目の合計を計算
sumOfFace : Int -> List Dice -> Int
sumOfFace face dice =
    dice
        |> List.filter (\d -> d.value == face)
        |> List.map .value
        |> List.sum

-- すべてのダイスの合計値を計算
sumAllDice : List Dice -> Int
sumAllDice dice =
    dice
        |> List.map .value
        |> List.sum

-- 各役の計算ロジック
calculateFourOfKind : List Dice -> Int
calculateFourOfKind dice =
    let
        valueCounts = countValues dice
    in
    if List.any (\(_, count) -> count >= 4) valueCounts then
        sumAllDice dice
    else
        0

calculateFullHouse : List Dice -> Int
calculateFullHouse dice =
    let
        valueCounts = countValues dice
        has3OfKind = List.any (\(_, count) -> count == 3) valueCounts
        has2OfKind = List.any (\(_, count) -> count == 2) valueCounts
    in
    if has3OfKind && has2OfKind then
        25
    else
        0

calculateSmallStraight : List Dice -> Int
calculateSmallStraight dice =
    let
        uniqueValues = dice
            |> List.map .value
            |> List.sort
            |> List.foldr
                (\x acc ->
                    if List.isEmpty acc || x /= Maybe.withDefault 0 (List.head acc) then
                        x :: acc
                    else
                        acc
                )
                []
            |> List.reverse

        containsSequence values sequence =
            let
                containsAll xs ys =
                    List.all (\y -> List.member y xs) ys
            in
            containsAll values sequence
    in
    if containsSequence uniqueValues [1, 2, 3, 4] ||
       containsSequence uniqueValues [2, 3, 4, 5] ||
       containsSequence uniqueValues [3, 4, 5, 6] then
        30
    else
        0

calculateLargeStraight : List Dice -> Int
calculateLargeStraight dice =
    let
        sortedValues = dice
            |> List.map .value
            |> List.sort
            |> List.foldr
                (\x acc ->
                    if List.isEmpty acc || x /= Maybe.withDefault 0 (List.head acc) then
                        x :: acc
                    else
                        acc
                )
                []
            |> List.reverse
    in
    if sortedValues == [1, 2, 3, 4, 5] || sortedValues == [2, 3, 4, 5, 6] then
        40
    else
        0

calculateYacht : List Dice -> Int
calculateYacht dice =
    let
        valueCounts = countValues dice
    in
    if List.any (\(_, count) -> count >= 5) valueCounts then
        50
    else
        0

-- 特定のスコアタイプに基づいたスコアを計算
calculateScore : ScoreType -> List Dice -> Int
calculateScore scoreType dice =
    case scoreType of
        Aces -> sumOfFace 1 dice
        Twos -> sumOfFace 2 dice
        Threes -> sumOfFace 3 dice
        Fours -> sumOfFace 4 dice
        Fives -> sumOfFace 5 dice
        Sixes -> sumOfFace 6 dice
        Choice -> sumAllDice dice
        FourOfKind -> calculateFourOfKind dice
        FullHouse -> calculateFullHouse dice
        SmallStraight -> calculateSmallStraight dice
        LargeStraight -> calculateLargeStraight dice
        Yacht -> calculateYacht dice
        Special _ -> 0  -- 特殊スコアの計算はゲームルールによって異なる

-- ヘルパー：ダイスの各値の出現回数をカウント
countValues : List Dice -> List (Int, Int)
countValues dice =
    dice
        |> List.map .value
        |> List.foldr
            (\val acc ->
                let
                    updateCount v counts =
                        case counts of
                            [] -> [(v, 1)]
                            (cv, cc) :: rest ->
                                if cv == v then
                                    (cv, cc + 1) :: rest
                                else
                                    (cv, cc) :: updateCount v rest
                in
                updateCount val acc
            )
            []

-- スコア履歴から合計点を計算
calculateTotalScoreFromHistory : ScoreHistory -> List Dice -> Int
calculateTotalScoreFromHistory history dice =
    let
        upperSectionScore =
            (if history.aces then calculateScore Aces dice else 0) +
            (if history.twos then calculateScore Twos dice else 0) +
            (if history.threes then calculateScore Threes dice else 0) +
            (if history.fours then calculateScore Fours dice else 0) +
            (if history.fives then calculateScore Fives dice else 0) +
            (if history.sixes then calculateScore Sixes dice else 0)

        -- 上段セクションが63点以上でボーナス35点
        upperBonus =
            if upperSectionScore >= 63 then 35 else 0

        lowerSectionScore =
            (if history.choice then calculateScore Choice dice else 0) +
            (if history.fourOfKind then calculateScore FourOfKind dice else 0) +
            (if history.fullHouse then calculateScore FullHouse dice else 0) +
            (if history.smallStraight then calculateScore SmallStraight dice else 0) +
            (if history.largeStraight then calculateScore LargeStraight dice else 0) +
            (if history.yacht then calculateScore Yacht dice else 0)

        -- 特殊スコア計算は割愛（プレイヤーの特殊スコア情報に基づいて計算）
        specialScore = 0
    in
    upperSectionScore + upperBonus + lowerSectionScore + specialScore

-- スコア履歴が全て埋まっているか確認
isScoreHistoryComplete : ScoreHistory -> Bool
isScoreHistoryComplete history =
    history.aces &&
    history.twos &&
    history.threes &&
    history.fours &&
    history.fives &&
    history.sixes &&
    history.choice &&
    history.fourOfKind &&
    history.fullHouse &&
    history.smallStraight &&
    history.largeStraight &&
    history.yacht
    
-- レガシーサポート用関数 (後方互換性のため)
type alias ScoreCard =
    { aces : Maybe Int
    , twos : Maybe Int
    , threes : Maybe Int
    , fours : Maybe Int
    , fives : Maybe Int
    , sixes : Maybe Int
    , choice : Maybe Int
    , fourOfKind : Maybe Int
    , fullHouse : Maybe Int
    , smallStraight : Maybe Int
    , largeStraight : Maybe Int
    , yacht : Maybe Int
    , specialScores : List SpecialScore
    }

type alias SpecialScore =
    { scoreType : String
    , value : Maybe Int
    , description : String
    }

initScoreCard : ScoreCard
initScoreCard =
    { aces = Nothing
    , twos = Nothing
    , threes = Nothing
    , fours = Nothing
    , fives = Nothing
    , sixes = Nothing
    , choice = Nothing
    , fourOfKind = Nothing
    , fullHouse = Nothing
    , smallStraight = Nothing
    , largeStraight = Nothing
    , yacht = Nothing
    , specialScores = []
    }

calculatePossibleScores : List Dice -> ScoreCard -> ScoreCard
calculatePossibleScores dice scoreCard =
    { scoreCard
        | aces = if scoreCard.aces == Nothing then Just (sumOfFace 1 dice) else scoreCard.aces
        , twos = if scoreCard.twos == Nothing then Just (sumOfFace 2 dice) else scoreCard.twos
        , threes = if scoreCard.threes == Nothing then Just (sumOfFace 3 dice) else scoreCard.threes
        , fours = if scoreCard.fours == Nothing then Just (sumOfFace 4 dice) else scoreCard.fours
        , fives = if scoreCard.fives == Nothing then Just (sumOfFace 5 dice) else scoreCard.fives
        , sixes = if scoreCard.sixes == Nothing then Just (sumOfFace 6 dice) else scoreCard.sixes
        , choice = if scoreCard.choice == Nothing then Just (sumAllDice dice) else scoreCard.choice
        , fourOfKind = if scoreCard.fourOfKind == Nothing then Just (calculateFourOfKind dice) else scoreCard.fourOfKind
        , fullHouse = if scoreCard.fullHouse == Nothing then Just (calculateFullHouse dice) else scoreCard.fullHouse
        , smallStraight = if scoreCard.smallStraight == Nothing then Just (calculateSmallStraight dice) else scoreCard.smallStraight
        , largeStraight = if scoreCard.largeStraight == Nothing then Just (calculateLargeStraight dice) else scoreCard.largeStraight
        , yacht = if scoreCard.yacht == Nothing then Just (calculateYacht dice) else scoreCard.yacht
    }

-- ScoreHistoryへの変換
scoreCardToHistory : ScoreCard -> ScoreHistory
scoreCardToHistory card =
    { aces = card.aces /= Nothing
    , twos = card.twos /= Nothing
    , threes = card.threes /= Nothing
    , fours = card.fours /= Nothing
    , fives = card.fives /= Nothing
    , sixes = card.sixes /= Nothing
    , choice = card.choice /= Nothing
    , fourOfKind = card.fourOfKind /= Nothing
    , fullHouse = card.fullHouse /= Nothing
    , smallStraight = card.smallStraight /= Nothing
    , largeStraight = card.largeStraight /= Nothing
    , yacht = card.yacht /= Nothing
    , specialScores = List.filterMap 
        (\special -> 
            if special.value /= Nothing then Just special.scoreType else Nothing
        ) card.specialScores
    }
