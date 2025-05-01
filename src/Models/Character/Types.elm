module Models.Character.Types exposing
    ( Character
    , CharacterAbility(..)
    , UnlockCondition(..)
    , characterAbilityToString
    )

import Models.Types exposing (ScoreType(..))



-- Character entity - core domain model


type alias Character =
    { id : String
    , name : String
    , description : String
    , portrait : String
    , startingHP : Int
    , maxHP : Int
    , specialAbility : CharacterAbility
    , startingItemIds : List String -- Reference item IDs instead of including full items
    , unlockCondition : Maybe UnlockCondition
    }



-- Character special abilities - value object representing character powers


type CharacterAbility
    = ExtraReroll -- 1回多くリロールができる
    | LuckyStart Int -- 指定された数字のダイスが1つ確定で出る
    | ScoreBonus ScoreType Int -- 特定の役のスコアがアップ
    | GoldBonus Int -- ゴールド獲得量増加
    | HealthRegen Int -- 戦闘後に体力回復
    | TreasureHunter -- 宝箱からのアイテム数増加
    | MerchantDiscount Int -- 商人の値引き率



-- Unlock condition for characters - value object


type UnlockCondition
    = StarterCharacter -- 最初から使用可能
    | DefeatBoss String -- 特定のボスを倒す
    | CompleteRunWith String -- 特定のキャラクターでクリア
    | AchieveScore Int -- 特定のスコア到達
    | FindSecretItem String -- 特定のアイテムを発見



-- Helper function to convert ability to human-readable text


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



-- Helper function to convert score type to string


scoreTypeToString : ScoreType -> String
scoreTypeToString scoreType =
    case scoreType of
        Aces ->
            "エース（1の目）"

        Twos ->
            "デュース（2の目）"

        Threes ->
            "トリプル（3の目）"

        Fours ->
            "フォー（4の目）"

        Fives ->
            "フィフス（5の目）"

        Sixes ->
            "シックス（6の目）"

        Choice ->
            "チョイス"

        FourOfKind ->
            "フォーカインド"

        FullHouse ->
            "フルハウス"

        SmallStraight ->
            "Sストレート"

        LargeStraight ->
            "Lストレート"

        Yacht ->
            "ヨット"

        Special name ->
            name
