module Update.Messages exposing (..)

import Models.Character exposing (Character)
import Models.Dice exposing (Dice)
import Models.Map exposing (Node)
import Models.Score exposing (ScoreCard)
import Models.Types exposing (ScoreType)
import Time


type Msg
    -- システムと初期化
    = NoOp
    | Initialize Time.Posix
    | TickTime Time.Posix
    | WindowResize Int Int

    -- ゲーム進行
    | StartGame
    | SelectCharacter Character
    | BackToMainMenu
    | MoveToNode Node

    -- バトル関連
    | StartBattle
    | RollDice
    | ToggleHoldDice String  -- ダイスのIDを指定
    | SelectScore ScoreType   -- スコアを選択（表示のみ）
    | ConfirmScore            -- 選択したスコアを確定して攻撃
    | EndTurn
    | UseActiveItem String  -- アイテムIDを指定
    | FinishBattle Bool  -- 勝利したかどうか

    -- マップ関係
    | EnterNode String  -- ノードID
    | ChoosePathOption Int  -- 選択肢の番号

    -- アイテム関連
    | SelectItem String  -- アイテムID
    | BuyItem String  -- アイテムID
    | SellItem String  -- アイテムID
    | EquipActiveItem String  -- アイテムID
    | UnequipActiveItem String  -- アイテムID

    -- 設定関連
    | OpenSettings
    | UpdateAudioSettings { musicVolume : Maybe Float, sfxVolume : Maybe Float, masterVolume : Maybe Float }
    | UpdateGraphicsSettings { resolution : Maybe String, fullscreen : Maybe Bool, effectQuality : Maybe String }
    | UpdateGameplaySettings { autosave : Maybe Bool, difficultyLevel : Maybe String, tutorialEnabled : Maybe Bool }
    | UpdateAccessibilitySettings { colorblindMode : Maybe Bool, textSize : Maybe String, highContrast : Maybe Bool }
    | CloseSettings

    -- セーブ/ロード
    | SaveGame
    | LoadGame
