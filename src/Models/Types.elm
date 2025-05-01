module Models.Types exposing
    ( DiceEffect(..)
    , DiceType(..)
    , GamePhase(..)
    , ScoreHistory
    , ScoreType(..)
    , initScoreHistory
    )

-- Game phases representing distinct application states


type GamePhase
    = MainMenu
    | CharacterSelection
    | InRun
    | BattlePhase
    | EventPhase
    | GameOver
    | Victory



-- Dice-related types - core value objects


type DiceType
    = Normal
    | FireDice
    | IceDice
    | ThunderDice
    | CursedDice
    | RareDice


type DiceEffect
    = NoEffect
    | DoubleFace
    | LockValue
    | RerollOnce
    | AddBonus Int



-- Score-related types


type ScoreType
    = Aces
    | Twos
    | Threes
    | Fours
    | Fives
    | Sixes
    | Choice
    | FourOfKind
    | FullHouse
    | SmallStraight
    | LargeStraight
    | Yacht
    | Special String



-- Score tracking history (Value Object)


type alias ScoreHistory =
    { aces : Bool
    , twos : Bool
    , threes : Bool
    , fours : Bool
    , fives : Bool
    , sixes : Bool
    , choice : Bool
    , fourOfKind : Bool
    , fullHouse : Bool
    , smallStraight : Bool
    , largeStraight : Bool
    , yacht : Bool
    , specialScores : List String -- 使用済み特殊スコアのID
    }



-- Initialize empty score history


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
