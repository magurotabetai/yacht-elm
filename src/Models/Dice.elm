module Models.Dice exposing
    ( Dice
    , addSpecialDice
    , initDice
    , rollDice
    , rollMultipleDice
    , standardDiceSet
    , toggleHold
    )

import Models.Types exposing (DiceEffect(..), DiceType(..))
import Random



-- Dice Value Object - immutable representation of a game dice


type alias Dice =
    { id : String
    , value : Int
    , held : Bool
    , diceType : DiceType
    , effects : List DiceEffect
    }



-- Create a new dice with specified properties


initDice : String -> DiceType -> List DiceEffect -> Dice
initDice id diceType effects =
    { id = id
    , value = 1 -- Default value, will be randomized on game start
    , held = False
    , diceType = diceType
    , effects = effects
    }



-- Pure function to generate a dice roll


rollDice : Dice -> Random.Generator Dice
rollDice dice =
    if dice.held then
        -- Held dice maintain their value
        Random.constant dice

    else
        -- Create a generator that produces a new dice with randomized value
        Random.map
            (\newValue -> { dice | value = newValue })
            (Random.int 1 6)



-- Pure function to toggle the held state of a dice


toggleHold : Dice -> Dice
toggleHold dice =
    { dice | held = not dice.held }



-- Pure function to generate rolls for multiple dice


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



-- Standard set of 5 normal dice (factory function)


standardDiceSet : List Dice
standardDiceSet =
    List.range 1 5
        |> List.map (\i -> initDice ("dice-" ++ String.fromInt i) Normal [ NoEffect ])



-- Pure function to add a special dice to a set, maintaining the 5 dice limit


addSpecialDice : Dice -> List Dice -> List Dice
addSpecialDice specialDice diceSet =
    -- Take up to 4 dice from the existing set to make room for the special dice
    let
        trimmedSet =
            List.take (min 4 (List.length diceSet)) diceSet
    in
    trimmedSet ++ [ specialDice ]
