module Update.Messages exposing (..)

import Models.Character.Types exposing (Character)
import Models.Types exposing (ScoreType)
import Time


type
    Msg
    -- システム関連
    = NoOp
    | Initialize Time.Posix
    | TickTime Time.Posix
    | WindowResize Int Int
      -- ゲーム進行
    | StartGame
    | SelectCharacter Character
    | BackToMainMenu
    | MoveToNode String -- ノードID
      -- バトル関連
    | StartBattle
    | RollDice
    | ToggleHoldDice String -- ダイスID
    | SelectScore ScoreType -- スコアタイプを選択
    | ConfirmScore -- 選択したスコアを確定
    | ConfirmScoreWithTime Time.Posix -- 内部メッセージ
    | EnemyAttack Int -- 敵の攻撃（ダメージ量）
    | EnemyAttackWithTime Int Time.Posix -- 内部メッセージ
    | EndTurn -- ターン終了
    | UseActiveItem String -- アイテムID
    | EndBattle Bool -- 勝利したかどうか
      -- アイテム関連
    | SelectItem String -- アイテムID
    | BuyItem String -- アイテムID
    | SellItem String -- アイテムID
    | EquipItem String -- アイテムID
    | UnequipItem String -- アイテムID
      -- 設定関連
    | OpenSettings
    | UpdateAudioSettings { musicVolume : Maybe Float, sfxVolume : Maybe Float, masterVolume : Maybe Float }
    | UpdateDisplaySettings { resolution : Maybe String, fullscreen : Maybe Bool, effectQuality : Maybe String }
    | UpdateGameplaySettings { difficulty : Maybe String, tutorialEnabled : Maybe Bool }
    | CloseSettings
      -- セーブ/ロード
    | SaveGame
    | LoadGame
