module Models.Enemy.Types exposing
    ( AttackPattern(..)
    , BossPhase
    , Enemy
    , EnemyAttack
    , EnemyType(..)
    , Reward
    )

import Models.Types exposing (ScoreType)
import Random



-- Enemy entity - Represents a battle opponent


type alias Enemy =
    { id : String
    , name : String
    , description : String
    , maxHP : Int
    , enemyType : EnemyType
    , attacks : List EnemyAttack
    , rewards : Reward
    }



-- Enemy types


type EnemyType
    = Normal
    | Elite
    | MiniBoss
    | Boss { phases : List BossPhase }



-- Enemy attack with damage and effects


type alias EnemyAttack =
    { name : String
    , baseDamage : Int
    , description : String
    , pattern : AttackPattern
    , chance : Float -- Probability of using this attack (0.0-1.0)
    }



-- Attack pattern determines enemy AI behavior


type AttackPattern
    = Regular -- Normal attack every turn
    | Charging Int -- Charges for n turns, then attacks
    | Defensive Int -- Attacks less but reduces damage taken
    | Enraged Int -- Increased damage when below HP threshold
    | Random -- Completely random attack behavior
    | Sequential -- Follows a sequence of attacks
    | AdaptiveTo ScoreType -- Adapts to player's score choices



-- Boss special phase


type alias BossPhase =
    { hpThreshold : Int
    , name : String
    , description : String
    , attackBuff : Float
    , defenseBuff : Float
    , specialEffect : Maybe String
    }



-- Enemy rewards given upon defeat


type alias Reward =
    { gold : Int
    , xp : Int
    , itemChance : Float
    , guaranteedItems : List String
    }
