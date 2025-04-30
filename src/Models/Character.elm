module Models.Character exposing (..)

import Models.Types exposing (..)

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

-- 初期キャラクター: ラッキーローラー
luckyRoller : Character
luckyRoller =
    { id = "lucky_roller"
    , name = "ラッキーローラー"
    , description = "元ギャンブラーで運に恵まれた冒険者。追加のリロールチャンスを持ち、幸運な一投で勝負を決める。"
    , portrait = "assets/characters/lucky_roller.png"
    , startingHP = 20
    , maxHP = 20
    , specialAbility = ExtraReroll
    , startingItems =
        [ { id = "lucky_coin"
          , name = "幸運のコイン"
          , description = "毎ターン、一度だけ1つのダイスを任意の目に変えられる"
          , rarity = Common
          , itemType = Active { cooldown = 3, currentCooldown = 0 }
          , effects = [ ModifyDiceValue 0 ]
          , cost = 0
          , unlocked = True
          }
        ]
    , unlockCondition = Just StarterCharacter
    }

-- 初期キャラクター: ストラテジスト
strategist : Character
strategist =
    { id = "strategist"
    , name = "ストラテジスト"
    , description = "計算高い戦術家。ストレートの役でボーナス点を獲得し、長期的な戦略が得意。"
    , portrait = "assets/characters/strategist.png"
    , startingHP = 18
    , maxHP = 18
    , specialAbility = ScoreBonus SmallStraight 5
    , startingItems =
        [ { id = "tactical_manual"
          , name = "戦術マニュアル"
          , description = "毎バトル開始時に、一度だけ全てのダイスを振り直せる"
          , rarity = Common
          , itemType = Passive
          , effects = [ AddReroll 1 ]
          , cost = 0
          , unlocked = True
          }
        ]
    , unlockCondition = Just StarterCharacter
    }

-- 利用可能なキャラクター一覧を取得
availableCharacters : List Character
availableCharacters =
    [ luckyRoller, strategist ]

-- キャラクターのスペシャルアビリティを文字列化
characterAbilityToString : CharacterAbility -> String
characterAbilityToString ability =
    case ability of
        ExtraReroll ->
            "追加リロール：通常より1回多くダイスを振り直せます"

        LuckyStart value ->
            "ラッキースタート：バトル開始時に " ++ String.fromInt value ++ " の目のダイスが1つ確定で出ます"

        ScoreBonus scoreType bonus ->
            "スコアボーナス：" ++ scoreTypeToString scoreType ++ " で " ++ String.fromInt bonus ++ " 点のボーナスを獲得します"

        GoldBonus bonus ->
            "ゴールドボーナス：獲得ゴールドが " ++ String.fromInt bonus ++ "% 増加します"

        HealthRegen amount ->
            "体力回復：バトル後に " ++ String.fromInt amount ++ " HP回復します"

        TreasureHunter ->
            "トレジャーハンター：宝箱から得られるアイテムが増加します"

        MerchantDiscount amount ->
            "値引き交渉：商人の価格が " ++ String.fromInt amount ++ "% 割引されます"

-- スコアタイプを文字列化
scoreTypeToString : ScoreType -> String
scoreTypeToString scoreType =
    case scoreType of
        Aces -> "エース（1の目）"
        Twos -> "デュース（2の目）"
        Threes -> "トリプル（3の目）"
        Fours -> "フォー（4の目）"
        Fives -> "フィフス（5の目）"
        Sixes -> "シックス（6の目）"
        Choice -> "チョイス"
        FourOfKind -> "フォーカインド"
        FullHouse -> "フルハウス"
        SmallStraight -> "Sストレート"
        LargeStraight -> "Lストレート"
        Yacht -> "ヨット"
        Special name -> name
