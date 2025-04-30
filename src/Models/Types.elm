module Models.Types exposing (..)

import Time

-- ダイス関連の型定義
type DiceType
    = Normal
    | Fire
    | Ice
    | Thunder
    | Cursed
    | Rare

type DiceEffect
    = NoEffect
    | DoubleFace
    | LockValue
    | RerollOnce
    | AddBonus Int

-- スコア関連の型定義
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

-- アイテム関連の型定義
type Rarity
    = Common
    | Uncommon
    | Rare
    | Epic
    | Legendary

type ItemType
    = Passive
    | Active { cooldown : Int, currentCooldown : Int }
    | Consumable
    | DiceModifier

type ItemEffect
    = ModifyDiceValue Int
    | AddReroll Int
    | DoubleScore ScoreType
    | AutoHoldValue Int
    | DamageBonus Int

-- キャラクター関連の型定義
type CharacterAbility
    = ExtraReroll -- 1回多くリロールができる
    | LuckyStart Int -- 指定された数字のダイスが1つ確定で出る
    | ScoreBonus ScoreType Int -- 特定の役のスコアがアップ
    | GoldBonus Int -- ゴールド獲得量増加
    | HealthRegen Int -- 戦闘後に体力回復
    | TreasureHunter -- 宝箱からのアイテム数増加
    | MerchantDiscount Int -- 商人の値引き率

type UnlockCondition
    = StarterCharacter -- 最初から使用可能
    | DefeatBoss String -- 特定のボスを倒す
    | CompleteRunWith String -- 特定のキャラクターでクリア
    | AchieveScore Int -- 特定のスコア到達
    | FindSecretItem String -- 特定のアイテムを発見

-- マップ関連の型定義
type NodeType
    = Battle Enemy
    | EliteBattle Enemy
    | Rest
    | Merchant
    | Treasure
    | Event EventType
    | Boss Boss

type EventType
    = RandomReward
    | MysteryDice
    | HealthOrGold
    | UpgradeItem
    | SpecialEncounter String

type ScoreBonus
    = BonusType ScoreType Int
    | PenaltyType ScoreType Int

-- ゲーム状態関連の型定義
type GamePhase
    = MainMenu
    | CharacterSelection
    | InRun
    | Battle
    | Event
    | GameOver
    | Victory
