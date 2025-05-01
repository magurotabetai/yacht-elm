module Models.Game exposing
    ( GameState
    , Player
    , Run
    , initGameState
    , startNewRun
    , startBattle
    )

import Dict exposing (Dict)
import Models.Battle.Logic as BattleLogic
import Models.Battle.Types exposing (Battle, initBattle)
import Models.Character.Characters exposing (availableCharacters)
import Models.Character.Types exposing (Character)
import Models.Dice exposing (standardDiceSet)
import Models.Enemy.Repository as EnemyRepo
import Models.Enemy.Types exposing (Enemy)
import Models.Item.Repository as ItemRepo
import Models.Item.Types exposing (Item)
import Models.Map as Map exposing (Map)
import Models.Types exposing (GamePhase(..))
import Random
import Time

-- TYPES

-- Main application state
type alias GameState =
    { player : Player
    , currentRun : Maybe Run
    , gamePhase : GamePhase
    , seed : Random.Seed
    , settings : Settings
    }

-- Player profile
type alias Player =
    { id : String
    , name : String
    , selectedCharacterId : Maybe String
    , stats : PlayerStats
    }

-- Player statistics
type alias PlayerStats =
    { totalRuns : Int
    , bossesDefeated : List String
    , highScore : Int
    , totalGold : Int
    }

-- A single game run
type alias Run =
    { id : String
    , seed : Int
    , currentFloor : Int
    , map : Map
    , inventory : List String  -- Item IDs
    , equippedItems : List String  -- Equipped item IDs
    , battlesWon : Int
    , currentHP : Int
    , maxHP : Int
    , gold : Int
    , currentBattle : Maybe Battle
    , characterId : String
    }

-- Game settings
type alias Settings =
    { audio : AudioSettings
    , display : DisplaySettings
    , gameplay : GameplaySettings
    }

-- Audio settings
type alias AudioSettings =
    { musicVolume : Float
    , sfxVolume : Float
    , masterVolume : Float
    }

-- Display settings
type alias DisplaySettings =
    { resolution : String
    , fullscreen : Bool
    , effectQuality : String
    }

-- Gameplay settings
type alias GameplaySettings =
    { difficulty : Difficulty
    , tutorialEnabled : Bool
    }

-- Difficulty levels
type Difficulty
    = Easy
    | Normal
    | Hard
    | Nightmare

-- INITIALIZATION

-- Initialize a new game state
initGameState : Int -> GameState
initGameState initialSeed =
    { player =
        { id = "player-" ++ String.fromInt initialSeed
        , name = "プレイヤー"
        , selectedCharacterId = Nothing
        , stats =
            { totalRuns = 0
            , bossesDefeated = []
            , highScore = 0
            , totalGold = 0
            }
        }
    , currentRun = Nothing
    , gamePhase = MainMenu
    , seed = Random.initialSeed initialSeed
    , settings = defaultSettings
    }

-- Default game settings
defaultSettings : Settings
defaultSettings =
    { audio =
        { musicVolume = 0.7
        , sfxVolume = 0.8
        , masterVolume = 0.8
        }
    , display =
        { resolution = "1280x720"
        , fullscreen = False
        , effectQuality = "Medium"
        }
    , gameplay =
        { difficulty = Normal
        , tutorialEnabled = True
        }
    }

-- GAME ACTIONS

-- Start a new run with a selected character
startNewRun : String -> GameState -> (GameState, Cmd msg)
startNewRun characterId gameState =
    let
        selectedCharacter =
            availableCharacters
                |> List.filter (\c -> c.id == characterId)
                |> List.head

        ( randomSeed, nextSeed ) =
            Random.step (Random.int 1 999999) gameState.seed

        ( initialMap, mapSeed ) =
            Map.initMap nextSeed
    in
    case selectedCharacter of
        Just character ->
            let
                -- Get starting items
                startingItems =
                    character.startingItemIds
                
                newRun =
                    { id = "run-" ++ String.fromInt randomSeed
                    , seed = randomSeed
                    , currentFloor = 1
                    , map = initialMap
                    , inventory = startingItems
                    , equippedItems = []
                    , battlesWon = 0
                    , currentHP = character.startingHP
                    , maxHP = character.maxHP
                    , gold = 0
                    , currentBattle = Nothing
                    , characterId = character.id
                    }

                updatedPlayerStats =
                    { totalRuns = gameState.player.stats.totalRuns + 1
                    , bossesDefeated = gameState.player.stats.bossesDefeated
                    , highScore = gameState.player.stats.highScore
                    , totalGold = gameState.player.stats.totalGold
                    }

                updatedPlayer =
                    { id = gameState.player.id
                    , name = gameState.player.name
                    , selectedCharacterId = Just character.id
                    , stats = updatedPlayerStats
                    }

                updatedGameState =
                    { gameState
                        | player = updatedPlayer
                        , currentRun = Just newRun
                        , gamePhase = InRun
                        , seed = mapSeed
                    }
            in
            ( updatedGameState, Cmd.none )

        Nothing ->
            -- Character not found
            ( gameState, Cmd.none )

-- Start a battle with an enemy
startBattle : String -> Run -> Random.Seed -> (Run, Random.Seed)
startBattle enemyId run seed =
    let
        enemyResult = 
            EnemyRepo.getEnemyById enemyId
    in
    case enemyResult of
        Just enemy ->
            -- Determine reroll count (character-specific ability may modify this)
            let
                rerollCount =
                    if run.characterId == "lucky_roller" then
                        3  -- Lucky Roller character gets more rerolls
                    else
                        2  -- Standard reroll count
                
                -- Create a fresh battle ID
                (battleIdRandom, nextSeed) =
                    Random.step (Random.int 10000 99999) seed
                
                battleId =
                    "battle-" ++ String.fromInt battleIdRandom
                    
                -- Initialize the battle
                battle =
                    initBattle 
                        battleId 
                        enemy.id 
                        enemy.name 
                        enemy.maxHP 
                        enemy.maxHP 
                        run.currentHP 
                        run.maxHP 
                        rerollCount
                
                -- Initial dice roll
                (rolledBattle, rollSeed) =
                    BattleLogic.rollDice 
                        { battle | dice = standardDiceSet } 
                        nextSeed
                        
                -- Update the run with the new battle
                updatedRun =
                    { run | currentBattle = Just rolledBattle }
            in
            (updatedRun, rollSeed)
            
        Nothing ->
            -- Enemy not found, return unchanged
            (run, seed)

-- Find an item by ID from a list of inventory items
getInventoryItem : String -> List String -> Maybe Item
getInventoryItem itemId inventory =
    if List.member itemId inventory then
        ItemRepo.getItemById itemId
    else
        Nothing

-- Get character by ID
getCharacterById : String -> Maybe Character
getCharacterById id =
    availableCharacters
        |> List.filter (\c -> c.id == id)
        |> List.head
