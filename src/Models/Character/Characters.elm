module Models.Character.Characters exposing (availableCharacters)

import Models.Character.Types exposing (Character, CharacterAbility(..), UnlockCondition(..))
import Models.Types exposing (ScoreType(..))



-- Collection of all available characters in the game


availableCharacters : List Character
availableCharacters =
    [ luckyRoller, strategist ]



-- Character: Lucky Roller


luckyRoller : Character
luckyRoller =
    { id = "lucky_roller"
    , name = "ラッキーローラー"
    , description = "元ギャンブラーで運に恵まれた冒険者。追加のリロールチャンスを持ち、幸運な一投で勝負を決める。"
    , portrait = "assets/characters/lucky_roller.png"
    , startingHP = 20
    , maxHP = 20
    , specialAbility = ExtraReroll
    , startingItemIds = [ "lucky_coin" ]
    , unlockCondition = Just StarterCharacter
    }



-- Character: Strategist


strategist : Character
strategist =
    { id = "strategist"
    , name = "ストラテジスト"
    , description = "計算高い戦術家。ストレートの役でボーナス点を獲得し、長期的な戦略が得意。"
    , portrait = "assets/characters/strategist.png"
    , startingHP = 18
    , maxHP = 18
    , specialAbility = ScoreBonus SmallStraight 5
    , startingItemIds = [ "tactical_manual" ]
    , unlockCondition = Just StarterCharacter
    }
