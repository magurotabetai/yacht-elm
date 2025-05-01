module Models.Battle.Types exposing
    ( Battle
    , BattleLog
    , BattleState(..)
    , LogEntry
    , initBattle
    )

import Models.Character.Types exposing (Character)
import Models.Dice exposing (Dice)
import Models.Types exposing (ScoreHistory, ScoreType, initScoreHistory)
import Time



-- Battle - Aggregate Root for battle domain


type alias Battle =
    { id : String
    , enemyId : String
    , enemyName : String
    , enemyCurrentHP : Int
    , enemyMaxHP : Int
    , playerCurrentHP : Int
    , playerMaxHP : Int
    , turn : Int
    , dice : List Dice
    , remainingRerolls : Int
    , maxRerolls : Int
    , scoreHistory : ScoreHistory
    , selectedScoreType : Maybe ScoreType
    , state : BattleState
    , log : BattleLog
    , timestamp : Time.Posix
    }



-- Battle state - Value Object representing the current battle phase


type BattleState
    = Rolling -- Player is rolling/rerolling dice
    | Selecting -- Player is selecting a score to use
    | EnemyTurn -- Enemy is performing their action
    | BattleOver -- Battle has concluded (victory or defeat)



-- Battle log - Records of battle events


type alias BattleLog =
    { entries : List LogEntry
    }



-- Individual log entry


type alias LogEntry =
    { message : String
    , timestamp : Time.Posix
    }



-- Initialize a new battle


initBattle : String -> String -> String -> Int -> Int -> Int -> Int -> Int -> Battle
initBattle id enemyId enemyName enemyHP enemyMaxHP playerHP playerMaxHP rerollCount =
    { id = id
    , enemyId = enemyId
    , enemyName = enemyName
    , enemyCurrentHP = enemyHP
    , enemyMaxHP = enemyMaxHP
    , playerCurrentHP = playerHP
    , playerMaxHP = playerMaxHP
    , turn = 1
    , dice = [] -- Will be populated with Models.Dice.standardDiceSet
    , remainingRerolls = rerollCount
    , maxRerolls = rerollCount
    , scoreHistory = initScoreHistory
    , selectedScoreType = Nothing
    , state = Rolling
    , log = { entries = [ { message = enemyName ++ "が現れた！", timestamp = Time.millisToPosix 0 } ] }
    , timestamp = Time.millisToPosix 0
    }
