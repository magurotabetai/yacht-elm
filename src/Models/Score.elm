module Models.Score exposing (..)

import Models.Dice exposing (Dice)
import Models.Types exposing (..)

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

-- 初期スコアカードを作成
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

-- ダイスの値に基づいて可能なスコアを計算
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

-- スコアカードの合計点を計算
calculateTotalScore : ScoreCard -> Int
calculateTotalScore scoreCard =
    let
        upperSectionScore =
            (Maybe.withDefault 0 scoreCard.aces) +
            (Maybe.withDefault 0 scoreCard.twos) +
            (Maybe.withDefault 0 scoreCard.threes) +
            (Maybe.withDefault 0 scoreCard.fours) +
            (Maybe.withDefault 0 scoreCard.fives) +
            (Maybe.withDefault 0 scoreCard.sixes)

        -- 上段セクションが63点以上でボーナス35点
        upperBonus =
            if upperSectionScore >= 63 then 35 else 0

        lowerSectionScore =
            (Maybe.withDefault 0 scoreCard.choice) +
            (Maybe.withDefault 0 scoreCard.fourOfKind) +
            (Maybe.withDefault 0 scoreCard.fullHouse) +
            (Maybe.withDefault 0 scoreCard.smallStraight) +
            (Maybe.withDefault 0 scoreCard.largeStraight) +
            (Maybe.withDefault 0 scoreCard.yacht)

        specialScore =
            scoreCard.specialScores
                |> List.map (.value >> Maybe.withDefault 0)
                |> List.sum
    in
    upperSectionScore + upperBonus + lowerSectionScore + specialScore

-- スコアカードが全て埋まっているか確認
isScoreCardComplete : ScoreCard -> Bool
isScoreCardComplete scoreCard =
    List.all (\scoreMaybe -> scoreMaybe /= Nothing)
        [ scoreCard.aces
        , scoreCard.twos
        , scoreCard.threes
        , scoreCard.fours
        , scoreCard.fives
        , scoreCard.sixes
        , scoreCard.choice
        , scoreCard.fourOfKind
        , scoreCard.fullHouse
        , scoreCard.smallStraight
        , scoreCard.largeStraight
        , scoreCard.yacht
        ]
