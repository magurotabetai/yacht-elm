module Models.Game exposing (..)

import Models.Character exposing (Character, Item, availableCharacters)
import Models.Dice exposing (Dice, standardDiceSet)
import Models.Map exposing (Map)
import Models.Score exposing (ScoreCard, initScoreCard)
import Models.Types exposing (..)
import Random
import Time

type alias GameState =
    { player : Player
    , currentRun : Maybe Run
    , unlockedContent : UnlockedContent
    , settings : Settings
    , gamePhase : GamePhase
    , seed : Random.Seed
    }

type alias Player =
    { id : String
    , name : String
    , selectedCharacter : Maybe Character
    , stats : PlayerStats
    }

type alias PlayerStats =
    { totalRuns : Int
    , bossesDefeated : List String
    , highScore : Int
    , totalGold : Int
    }

type alias Run =
    { id : String
    , seed : Int
    , currentFloor : Int
    , map : Map
    , inventory : Inventory
    , battlesWon : Int
    , currentHP : Int
    , maxHP : Int
    , gold : Int
    , currentBattle : Maybe Battle
    , characterId : String
    }

type alias Inventory =
    { items : List Item
    , activeItemSlots : List String  -- アクティブアイテムとして装備されているアイテムIDのリスト
    }

type alias Battle =
    { enemy : EnemyData
    , boss : Maybe BossData
    , turn : Int
    , dice : List Dice
    , remainingRerolls : Int
    , scoreCard : ScoreCard
    , playerDamageDealt : Int
    , enemyDamageDealt : Int
    , battleLog : List String
    }

type alias UnlockedContent =
    { characters : List Character
    , items : List String
    , specialDice : List String
    , achievements : List String
    }

type alias Settings =
    { audio : AudioSettings
    , graphics : GraphicsSettings
    , gameplay : GameplaySettings
    , accessibility : AccessibilitySettings
    }

type alias AudioSettings =
    { musicVolume : Float
    , sfxVolume : Float
    , masterVolume : Float
    }

type alias GraphicsSettings =
    { resolution : String
    , fullscreen : Bool
    , effectQuality : String
    }

type alias GameplaySettings =
    { autosave : Bool
    , difficultyLevel : String
    , tutorialEnabled : Bool
    }

type alias AccessibilitySettings =
    { colorblindMode : Bool
    , textSize : String
    , highContrast : Bool
    }

-- 初期ゲーム状態を生成
initGameState : Int -> GameState
initGameState initialSeed =
    { player =
        { id = "player-" ++ String.fromInt initialSeed
        , name = "プレイヤー"
        , selectedCharacter = Nothing
        , stats =
            { totalRuns = 0
            , bossesDefeated = []
            , highScore = 0
            , totalGold = 0
            }
        }
    , currentRun = Nothing
    , unlockedContent =
        { characters = availableCharacters
        , items = []
        , specialDice = []
        , achievements = []
        }
    , settings = defaultSettings
    , gamePhase = MainMenu
    , seed = Random.initialSeed initialSeed
    }

-- 新しいランを開始
startNewRun : Character -> GameState -> ( GameState, Cmd msg )
startNewRun character gameState =
    let
        ( randomSeed, nextSeed ) =
            Random.step (Random.int 1 999999) gameState.seed

        ( initialMap, newSeed ) =
            Models.Map.initMap nextSeed

        newRun =
            { id = "run-" ++ String.fromInt randomSeed
            , seed = randomSeed
            , currentFloor = 1
            , map = initialMap
            , inventory =
                { items = character.startingItems
                , activeItemSlots = []
                }
            , battlesWon = 0
            , currentHP = character.startingHP
            , maxHP = character.maxHP
            , gold = 0
            , currentBattle = Nothing
            , characterId = character.id
            }

        updatedPlayer =
            { id = gameState.player.id
            , name = gameState.player.name
            , selectedCharacter = Just character
            , stats =
                { totalRuns = gameState.player.stats.totalRuns + 1
                , bossesDefeated = gameState.player.stats.bossesDefeated
                , highScore = gameState.player.stats.highScore
                , totalGold = gameState.player.stats.totalGold
                }
            }

        updatedGameState =
            { gameState
            | player = updatedPlayer
            , currentRun = Just newRun
            , gamePhase = InRun
            , seed = newSeed
            }
    in
    ( updatedGameState, Cmd.none )

-- バトルを開始
startBattle : EnemyData -> Maybe BossData -> Run -> ( Run, Cmd msg )
startBattle enemy boss run =
    let
        -- キャラクターに基づいてリロール回数を決定（デフォルトは2回）
        rerollCount = 2

        initialBattle =
            { enemy = enemy
            , boss = boss
            , turn = 1
            , dice = standardDiceSet
            , remainingRerolls = rerollCount
            , scoreCard = initScoreCard
            , playerDamageDealt = 0
            , enemyDamageDealt = 0
            , battleLog = [ enemy.name ++ "が現れた！" ]
            }

        -- ダイスロールのジェネレーターを作成
        diceRollGenerator = Models.Dice.rollMultipleDice initialBattle.dice
        -- 乱数シードを使ってダイスを振る
        (rolledDice, newSeed) = Random.step diceRollGenerator (Random.initialSeed run.seed)

        -- 振ったダイスで初期バトル状態を更新
        battleWithRolledDice = { initialBattle | dice = rolledDice }

        updatedRun =
            { run | currentBattle = Just battleWithRolledDice }
    in
    ( updatedRun, Cmd.none )

-- デフォルト設定
defaultSettings : Settings
defaultSettings =
    { audio =
        { musicVolume = 0.7
        , sfxVolume = 0.8
        , masterVolume = 0.8
        }
    , graphics =
        { resolution = "1280x720"
        , fullscreen = False
        , effectQuality = "Medium"
        }
    , gameplay =
        { autosave = True
        , difficultyLevel = "Normal"
        , tutorialEnabled = True
        }
    , accessibility =
        { colorblindMode = False
        , textSize = "Medium"
        , highContrast = False
        }
    }
