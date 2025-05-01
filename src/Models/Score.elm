module Models.Score exposing
    ( calculateScoreValue
    , isScoreAvailable
    , markScoreUsed
    , calculateAllPossibleScores
    , ScoreResult
    , sumOfFace
    , sumAllDice
    , calculateFourOfKind
    , calculateFullHouse
    , calculateSmallStraight
    , calculateLargeStraight
    , calculateYacht
    )

import Models.Dice exposing (Dice)
import Models.Types exposing (ScoreType(..), ScoreHistory, initScoreHistory)
import Dict exposing (Dict)

-- Score result - Value Object representing a calculated score with metadata
type alias ScoreResult =
    { scoreType : ScoreType
    , value : Int
    , available : Bool
    }

-- Calculate a score value for a specific score type
calculateScoreValue : ScoreType -> List Dice -> Int
calculateScoreValue scoreType dice =
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

-- Calculate all possible scores for a set of dice and mark their availability
calculateAllPossibleScores : List Dice -> ScoreHistory -> List ScoreResult
calculateAllPossibleScores dice history =
    let
        standardScoreTypes = 
            [ Aces, Twos, Threes, Fours, Fives, Sixes, 
              Choice, FourOfKind, FullHouse, 
              SmallStraight, LargeStraight, Yacht ]
    in
    List.map 
        (\scoreType -> 
            { scoreType = scoreType
            , value = calculateScoreValue scoreType dice
            , available = isScoreAvailable scoreType history
            }
        )
        standardScoreTypes

-- Check if a score type is available to be used
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

-- Mark a score as used in the history
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

-- Sum dice with a specific value
sumOfFace : Int -> List Dice -> Int
sumOfFace face dice =
    dice
        |> List.filter (\d -> d.value == face)
        |> List.map .value
        |> List.sum

-- Sum all dice values
sumAllDice : List Dice -> Int
sumAllDice dice =
    dice
        |> List.map .value
        |> List.sum

-- Calculate Four of a Kind score
calculateFourOfKind : List Dice -> Int
calculateFourOfKind dice =
    let
        valueCounts = countValues dice
    in
    if List.any (\(_, count) -> count >= 4) valueCounts then
        sumAllDice dice
    else
        0

-- Calculate Full House score
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

-- Calculate Small Straight score
calculateSmallStraight : List Dice -> Int
calculateSmallStraight dice =
    let
        uniqueValues = dice
            |> List.map .value
            |> List.sort
            |> unique
    in
    if hasSubsequence uniqueValues [1, 2, 3, 4] ||
       hasSubsequence uniqueValues [2, 3, 4, 5] ||
       hasSubsequence uniqueValues [3, 4, 5, 6] then
        30
    else
        0

-- Calculate Large Straight score
calculateLargeStraight : List Dice -> Int
calculateLargeStraight dice =
    let
        sortedValues = dice
            |> List.map .value
            |> List.sort
            |> unique
    in
    if hasSubsequence sortedValues [1, 2, 3, 4, 5] || 
       hasSubsequence sortedValues [2, 3, 4, 5, 6] then
        40
    else
        0

-- Calculate Yacht score (five of a kind)
calculateYacht : List Dice -> Int
calculateYacht dice =
    let
        valueCounts = countValues dice
    in
    if List.any (\(_, count) -> count >= 5) valueCounts then
        50
    else
        0

-- Helper: Count frequency of each dice value
countValues : List Dice -> List (Int, Int)
countValues dice =
    dice
        |> List.map .value
        |> List.foldr
            (\val acc ->
                Dict.update val 
                    (\maybeCount -> 
                        case maybeCount of
                            Nothing -> Just 1
                            Just count -> Just (count + 1)
                    )
                    acc
            )
            Dict.empty
        |> Dict.toList

-- Helper: Get unique values from a list
unique : List Int -> List Int
unique =
    List.foldr
        (\x acc ->
            if List.member x acc then
                acc
            else
                x :: acc
        )
        []
        >> List.sort

-- Helper: Check if one list contains a specific sequence
hasSubsequence : List Int -> List Int -> Bool
hasSubsequence haystack needle =
    List.all (\item -> List.member item haystack) needle
