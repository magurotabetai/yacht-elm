module Models.Types exposing (..)

import Time

-- ダイス関連の型定義
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

-- スコア履歴管理のための型定義
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
    = BattleNode EnemyData
    | EliteBattleNode EnemyData
    | RestNode
    | MerchantNode
    | TreasureNode
    | EventNode EventType
    | BossNode BossData

-- 敵の基本データ型
type alias EnemyData =
    { id : String
    , name : String
    , hp : Int
    , maxHp : Int
    , attacks : List AttackData
    , scoreBonus : List ScoreBonus
    , rewards : List RewardData
    }

-- ボスの基本データ型
type alias BossData =
    { enemy : EnemyData
    , specialPhases : List BossPhase
    }

-- 攻撃データ型
type alias AttackData =
    { name : String
    , damage : Int
    , description : String
    }

-- 報酬データ型
type alias RewardData =
    { gold : Int
    , experience : Int
    , items : List String
    }

-- ボスの特殊フェーズ
type alias BossPhase =
    { hpThreshold : Int
    , description : String
    , effect : BossEffect
    }

-- ボスの特殊効果
type BossEffect
    = LockDice Int
    | DisableReroll
    | DoubleAttack
    | HealSelf Int
    | SummonMinions

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
    | BattlePhase
    | EventPhase
    | GameOver
    | Victory
