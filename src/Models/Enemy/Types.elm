module Models.Enemy.Types exposing
    ( Enemy
    , EnemyAttack
    , EnemyType(..)
    , BossPhase
    , AttackPattern(..)
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
    , chance : Float  -- Probability of using this attack (0.0-1.0)
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

-- Determine which attack the enemy will use
selectAttack : List EnemyAttack -> Random.Seed -> (EnemyAttack, Random.Seed)
selectAttack attacks seed =
    case attacks of
        [] ->
            -- Default attack if none available
            ( { name = "攻撃"
              , baseDamage = 1
              , description = "弱い攻撃"
              , pattern = Regular
              , chance = 1.0
              }
            , seed
            )
            
        [singleAttack] ->
            (singleAttack, seed)
            
        multipleAttacks ->
            -- Calculate total probability
            let
                totalChance = 
                    List.foldl (\attack sum -> sum + attack.chance) 0 multipleAttacks
                
                -- Generate random value between 0 and total probability
                (randomValue, nextSeed) =
                    Random.step (Random.float 0 totalChance) seed
                
                -- Find attack based on random value
                (selectedAttack, _) =
                    List.foldl 
                        (\attack (current, remainingChance) ->
                            if remainingChance <= attack.chance then
                                (Just attack, 0)
                            else
                                (current, remainingChance - attack.chance)
                        )
                        (Nothing, randomValue)
                        multipleAttacks
            in
            case selectedAttack of
                Just attack ->
                    (attack, nextSeed)
                    
                Nothing ->
                    -- Fallback to first attack (shouldn't happen with proper probabilities)
                    (List.head multipleAttacks |> Maybe.withDefault (Tuple.first (selectAttack [] seed)), nextSeed)