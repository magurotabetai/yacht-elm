# ヨットクエスト（YachtQuest）仕様書

**作成日**: 2025年4月30日
**更新日**: 2025年4月30日

## A. 機能仕様

### 1. コアゲームプレイ

#### 1.1 ダイスシステム
- **ダイスの種類**: 基本6面ダイス（1-6の数字）、属性ダイス（火、氷、雷）、特殊ダイス（呪われたダイス、レアダイス）
- **振り直し**: 1ターンにつき最大3回まで特定のダイスを選択して振り直し可能（キャラクターの特殊能力によって変動）
- **ホールド機能**: 維持したいダイスを選択・固定する機能

#### 1.2 スコアリングシステム
| 役名 | 説明 | 得点計算 |
|------|------|----------|
| エース | 1の目の合計 | 出た1の目の合計 |
| デュース | 2の目の合計 | 出た2の目の合計 |
| トリプル | 3の目の合計 | 出た3の目の合計 |
| フォー | 4の目の合計 | 出た4の目の合計 |
| フィフス | 5の目の合計 | 出た5の目の合計 |
| シックス | 6の目の合計 | 出た6の目の合計 |
| チョイス | 任意 | すべての目の合計 |
| フォーオブカインド | 同じ目が4つ以上 | すべての目の合計 |
| フルハウス | 同じ目が3つと2つ | 固定値25点 |
| Sストレート | 連続した数字が4つ | 固定値30点 |
| Lストレート | 連続した数字が5つ | 固定値40点 |
| ヨット | 同じ目が5つ | 固定値50点 |
| 特殊役 | ゲーム内で獲得する特殊役 | 役による |

#### 1.3 ゲームフェーズ
- **メインメニュー**: ゲームの開始画面
- **キャラクター選択**: プレイヤーキャラクターの選択画面
- **マップ探索**: 冒険マップの探索画面
- **バトルフェーズ**: 敵との戦闘画面
- **イベントフェーズ**: 特殊イベント画面
- **ゲームオーバー**: 敗北時の画面
- **ビクトリー**: 勝利時の画面

#### 1.4 プレイヤー進行
- **経験値システム**: バトル勝利やイベントで経験値を獲得し、レベルアップで新しい能力解放
- **永続的アンロック**: ゲームオーバー後も保持される要素（新キャラクター、特殊ダイス、アイテムなど）
- **実績システム**: 特定の条件を達成することでゲーム内報酬を解放

### 2. ローグライト要素

#### 2.1 マップシステム
- **生成アルゴリズム**: シード値に基づいたランダム生成
- **ノード種類**: 戦闘、エリート戦闘、休息所、商人、宝箱、イベント、ボス
- **分岐構造**: 複数の選択肢から進路を選べる分岐構造

#### 2.2 敵システム
- **通常敵**: 基本的な能力と戦術を持つ敵
- **エリート敵**: 強力な特殊能力を持つ強敵
- **ボス敵**: 各エリア最後に登場する固有の攻略が必要なボス敵、特殊フェーズを持つ

#### 2.3 アイテムとアップグレード
- **アイテム取得方法**: 戦闘報酬、商人、宝箱、イベント
- **アイテム種類**: パッシブ効果、アクティブスキル（クールダウンあり）、ダイス修飾、消費アイテム
- **アイテムレアリティ**: Common, Uncommon, Rare, Epic, Legendary

### 3. 実装機能

#### 3.1 セーブ・ロードシステム
- **オートセーブ**: ノード移動時に自動保存（設定で切替可能）
- **マニュアルセーブ**: 任意のタイミングで保存可能
- **マルチプロファイル**: 複数のセーブデータ管理

#### 3.2 設定オプション
- **オーディオ設定**: 音楽・効果音・マスター音量の調整
- **グラフィック設定**: 解像度、フルスクリーン切替、エフェクトクオリティ
- **ゲームプレイ設定**: オートセーブ、難易度、チュートリアル表示

#### 3.3 アクセシビリティ機能
- **色覚サポート**: 色覚異常に配慮したカラーブラインドモード
- **テキストサイズ**: 文字サイズ調整機能
- **コントラスト調整**: 視認性向上のためのハイコントラストモード

## B. デザイン（UI/演出）仕様

### 1. ユーザーインタフェース

#### 1.1 画面レイアウト
- **メイン画面**: ダイス表示エリア、スコアカード、アイテム・能力表示域
- **マップ画面**: ノード接続を視覚的に表示した進行マップ
- **バトル画面**: プレイヤーとエネミーのステータス、ターン表示、アクション選択UI
- **リワード画面**: 報酬選択インタフェース

#### 1.2 UIコンポーネント
- **ダイスビジュアル**: 3Dレンダリングまたは高品質2Dスプライトのダイス
- **スコアカード**: 役と得点を一覧表示するインタラクティブなカード
- **アイテム表示**: 所持アイテムとその効果を表示するアイコン型インタフェース
- **ステータスバー**: HP、経験値、通貨などのリソース表示

#### 1.3 アニメーションと演出
- **ダイス投げ/回転アニメーション**: 物理ベースの自然なダイスの動き
- **得点計算エフェクト**: 点数獲得時の視覚・音響効果
- **特殊役発動エフェクト**: 特殊能力発動時の派手なエフェクト
- **レベルアップ演出**: プレイヤー成長時の祝福的な視覚効果

### 2. アートディレクション

#### 2.1 視覚スタイル
- **全体テイスト**: シンプルながらも魅力的なカジュアルスタイル
- **カラーパレット**: 各エリア/テーマに合わせた基調色の設定
- **アイコンデザイン**: 一貫性のある直感的なアイコンシステム

#### 2.2 キャラクターデザイン
- **プレイヤーキャラクター**: 個性的な見た目と特性を持つ複数のキャラクター
- **エネミーデザイン**: エリアテーマに合わせた特徴的な敵キャラクター
- **アニメーション**: キャラクターの状態変化に応じたリアクションアニメーション

### 3. サウンドデザイン

#### 3.1 音楽
- **メインテーマ**: ゲームの世界観を表現する印象的なテーマ曲
- **エリアBGM**: 各エリアの雰囲気に合わせた背景音楽
- **バトルBGM**: テンポの良いバトル曲と緊張感のあるボス戦闘曲

#### 3.2 効果音
- **ダイス効果音**: ダイスの転がり音、衝突音、停止音
- **UI効果音**: ボタン押下、メニュー開閉などの操作音
- **スキル発動音**: 特殊能力使用時の特徴的な効果音
- **環境音**: 各エリアの没入感を高める環境音

## C. データ設計

### 1. コアデータ構造

#### 1.1 ゲーム状態モデル
```elm
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

type GamePhase
    = MainMenu
    | CharacterSelection
    | InRun
    | BattlePhase
    | EventPhase
    | GameOver
    | Victory
```

#### 1.2 ダイスとスコアモデル
```elm
type alias Dice =
    { id : String
    , value : Int
    , held : Bool
    , diceType : DiceType
    , effects : List DiceEffect
    }

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

type alias ScoreCard =
    { aces : Maybe Int
    , twos : Maybe Int
    , threes : Maybe Int
    , fours : Maybe Int
    , fives : Maybe Int
    , sixes : Maybe Int
    , choice : Maybe Int
    , fourOfKind : Maybe Int
    , fullHouse : Maybe Int
    , smallStraight : Maybe Int
    , largeStraight : Maybe Int
    , yacht : Maybe Int
    , specialScores : List SpecialScore
    }

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
```

#### 1.3 アイテムとエフェクトモデル
```elm
type alias Item =
    { id : String
    , name : String
    , description : String
    , rarity : Rarity
    , itemType : ItemType
    , effects : List ItemEffect
    , cost : Int
    , unlocked : Bool
    }

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

type Rarity
    = Common
    | Uncommon
    | Rare
    | Epic
    | Legendary
```

#### 1.4 キャラクターモデル
```elm
type alias Character =
    { id : String
    , name : String
    , description : String
    , portrait : String
    , startingHP : Int
    , maxHP : Int
    , specialAbility : CharacterAbility
    , startingItems : List Item
    , unlockCondition : Maybe UnlockCondition
    }

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
```

### 2. マップと遭遇データ

#### 2.1 マップ生成アルゴリズム
```elm
type alias Map =
    { floors : List Floor
    , currentPosition : NodePosition
    }

type alias Floor =
    { level : Int
    , nodes : List Node
    , connections : List Connection
    }

type alias Node =
    { id : String
    , nodeType : NodeType
    , position : NodePosition
    , visited : Bool
    }

type NodeType
    = BattleNode EnemyData
    | EliteBattleNode EnemyData
    | RestNode
    | MerchantNode
    | TreasureNode
    | EventNode EventType
    | BossNode BossData
```

#### 2.2 敵データ設計
```elm
type alias EnemyData =
    { id : String
    , name : String
    , hp : Int
    , maxHp : Int
    , attacks : List AttackData
    , scoreBonus : List ScoreBonus
    , rewards : List RewardData
    }

type alias AttackData =
    { name : String
    , damage : Int
    , description : String
    }

type alias BossData =
    { enemy : EnemyData
    , specialPhases : List BossPhase
    }

type alias BossPhase =
    { hpThreshold : Int
    , description : String
    , effect : BossEffect
    }

type BossEffect
    = LockDice Int
    | DisableReroll
    | DoubleAttack
    | HealSelf Int
    | SummonMinions

type ScoreBonus
    = BonusType ScoreType Int
    | PenaltyType ScoreType Int
```

### 3. バトルシステム

#### 3.1 バトルの状態管理
```elm
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

type alias Inventory =
    { items : List Item
    , activeItemSlots : List String  -- アクティブアイテムとして装備されているアイテムIDのリスト
    }
```

### 4. 設定データ

```elm
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
```

## 実装優先度と開発ロードマップ

### フェーズ1: 基本機能実装 (MVP) ✓
1. ✓ 基本的なダイスゲーム機能
2. ✓ スコアカード実装
3. ✓ 単一バトルシステム
4. ✓ 基本UI

### フェーズ2: ローグライト要素
1. ✓ マップ生成システム
2. ◎ 敵バリエーション
3. ◎ アイテムシステム
4. ○ 報酬メカニズム

### フェーズ3: 拡張と最適化
1. ○ 特殊ダイスとエフェクト
2. × セーブ・ロードシステム
3. × アニメーションと演出強化
4. × バランス調整

### フェーズ4: ポリッシュと追加コンテンツ
1. × 追加キャラクターとアイテム
2. × 実績システム
3. × デイリーチャレンジモード
4. × 最適化とバグ修正

凡例: ✓ 完了, ◎ 進行中, ○ 部分的に実装, × 未実装
