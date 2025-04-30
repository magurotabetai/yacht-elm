module Models.Dice exposing (..)

import Models.Types exposing (..)
import Random

type alias Dice =
    { id : String
    , value : Int
    , held : Bool
    , diceType : DiceType
    , effects : List DiceEffect
    }

-- 新しいダイスを作成
initDice : String -> DiceType -> List DiceEffect -> Dice
initDice id diceType effects =
    { id = id
    , value = 1  -- 初期値は1、ゲーム開始時にランダムに振られる
    , held = False
    , diceType = diceType
    , effects = effects
    }

-- ダイスを振る
rollDice : Dice -> Random.Generator Dice
rollDice dice =
    if dice.held then
        Random.constant dice
    else
        Random.map (\newValue -> { dice | value = newValue }) (Random.int 1 6)

-- ダイスの保持状態を切り替える
toggleHold : Dice -> Dice
toggleHold dice =
    { dice | held = not dice.held }

-- 複数のダイスを振る
rollMultipleDice : List Dice -> Random.Generator (List Dice)
rollMultipleDice dice =
    let
        consGenerator : Random.Generator a -> Random.Generator (List a) -> Random.Generator (List a)
        consGenerator itemGen listGen =
            Random.map2 (::) itemGen listGen

        buildGeneratorList : List Dice -> Random.Generator (List Dice)
        buildGeneratorList diceList =
            case diceList of
                [] ->
                    Random.constant []

                d :: rest ->
                    consGenerator (rollDice d) (buildGeneratorList rest)
    in
    buildGeneratorList dice

-- 標準的なダイスセットを作成する (5個の通常ダイス)
standardDiceSet : List Dice
standardDiceSet =
    List.range 1 5
        |> List.map (\i -> initDice ("dice-" ++ String.fromInt i) Normal [NoEffect])

-- ダイスセットに特殊ダイスを追加
addSpecialDice : Dice -> List Dice -> List Dice
addSpecialDice specialDice diceSet =
    -- 既存のセットにダイスが5個以上あれば最後のダイスを削除
    let
        trimmedSet =
            if List.length diceSet >= 5 then
                List.take 4 diceSet
            else
                diceSet
    in
    trimmedSet ++ [specialDice]
