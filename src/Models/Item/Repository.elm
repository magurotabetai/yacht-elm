module Models.Item.Repository exposing (getItemById, getAllItems)

import Models.Item.Types exposing (..)
import Models.Types exposing (ScoreType(..))
import Dict exposing (Dict)

-- Item repository - provides access to all game items
itemDatabase : Dict String Item
itemDatabase =
    Dict.fromList
        [ ( "lucky_coin"
          , { id = "lucky_coin"
            , name = "幸運のコイン"
            , description = "毎ターン、一度だけ1つのダイスを任意の目に変えられる"
            , rarity = Common
            , itemType = Active { cooldown = 3, currentCooldown = 0 }
            , effects = [ ModifyDiceValue 0 ]
            , cost = 0
            , unlocked = True
            }
          )
        , ( "tactical_manual"
          , { id = "tactical_manual"
            , name = "戦術マニュアル"
            , description = "毎バトル開始時に、一度だけ全てのダイスを振り直せる"
            , rarity = Common
            , itemType = Passive
            , effects = [ AddReroll 1 ]
            , cost = 0
            , unlocked = True
            }
          )
        , ( "fire_gem"
          , { id = "fire_gem"
            , name = "炎の宝石"
            , description = "ヨットが発生すると追加で5ダメージを与える"
            , rarity = Uncommon
            , itemType = Passive
            , effects = [ DoubleScore Yacht ]
            , cost = 25
            , unlocked = False
            }
          )
        , ( "ice_pendant"
          , { id = "ice_pendant"
            , name = "氷のペンダント"
            , description = "バトル開始時に1つのダイスの目が6で固定される"
            , rarity = Rare
            , itemType = Passive
            , effects = [ AutoHoldValue 6 ] 
            , cost = 45
            , unlocked = False
            }
          )
        ]

-- Get an item by its ID
getItemById : String -> Maybe Item
getItemById id =
    Dict.get id itemDatabase

-- Get all items in the game
getAllItems : List Item
getAllItems =
    Dict.values itemDatabase

-- Get starting items for a character by IDs
getItemsByIds : List String -> List Item
getItemsByIds ids =
    List.filterMap getItemById ids