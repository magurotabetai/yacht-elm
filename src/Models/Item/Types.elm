module Models.Item.Types exposing
    ( Item
    , ItemEffect(..)
    , ItemType(..)
    , Rarity(..)
    )

import Models.Types exposing (ScoreType)



-- Item entity - Value Object in the domain model


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



-- Item rarity - value object for item quality


type Rarity
    = Common
    | Uncommon
    | Rare
    | Epic
    | Legendary



-- Item types - value object for item behavior


type ItemType
    = Passive
    | Active { cooldown : Int, currentCooldown : Int }
    | Consumable
    | DiceModifier



-- Item effects - value object for item functionality


type ItemEffect
    = ModifyDiceValue Int
    | AddReroll Int
    | DoubleScore ScoreType
    | AutoHoldValue Int
    | DamageBonus Int
