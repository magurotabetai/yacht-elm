module Models.Map exposing (..)

import Models.Types exposing (..)
import Random exposing (Generator)

-- マップ全体の構造
type alias Map =
    { floors : List Floor
    , currentPosition : NodePosition
    }

-- フロア（階層）の構造
type alias Floor =
    { level : Int
    , nodes : List Node
    , connections : List Connection
    }

-- ノードの位置情報
type alias NodePosition =
    { floorLevel : Int
    , nodeId : String
    }

-- ノードの構造
type alias Node =
    { id : String
    , nodeType : NodeType
    , position : Position
    , visited : Bool
    }

-- ノード間の接続情報
type alias Connection =
    { from : String
    , to : String
    }

-- 2D座標
type alias Position =
    { x : Float
    , y : Float
    }

-- 初期マップを生成
initMap : Generator Map
initMap =
    let
        -- 最初のフロアを生成
        firstFloor =
            { level = 1
            , nodes = 
                [ { id = "start", nodeType = Rest, position = { x = 0.5, y = 0.1 }, visited = True }
                , { id = "battle-1", nodeType = Battle (createBasicEnemy "goblin" "ゴブリン"), position = { x = 0.3, y = 0.3 }, visited = False }
                , { id = "battle-2", nodeType = Battle (createBasicEnemy "wolf" "ウルフ"), position = { x = 0.7, y = 0.3 }, visited = False }
                , { id = "event-1", nodeType = Event RandomReward, position = { x = 0.2, y = 0.5 }, visited = False }
                , { id = "merchant", nodeType = Merchant, position = { x = 0.5, y = 0.5 }, visited = False }
                , { id = "battle-3", nodeType = Battle (createBasicEnemy "orc" "オーク"), position = { x = 0.8, y = 0.5 }, visited = False }
                , { id = "elite", nodeType = EliteBattle (createEliteEnemy "troll" "トロール"), position = { x = 0.3, y = 0.7 }, visited = False }
                , { id = "treasure", nodeType = Treasure, position = { x = 0.6, y = 0.7 }, visited = False }
                , { id = "boss", nodeType = Boss (createBoss "dragon" "ドラゴン"), position = { x = 0.5, y = 0.9 }, visited = False }
                ]
            , connections =
                [ { from = "start", to = "battle-1" }
                , { from = "start", to = "battle-2" }
                , { from = "battle-1", to = "event-1" }
                , { from = "battle-1", to = "merchant" }
                , { from = "battle-2", to = "merchant" }
                , { from = "battle-2", to = "battle-3" }
                , { from = "event-1", to = "elite" }
                , { from = "merchant", to = "elite" }
                , { from = "merchant", to = "treasure" }
                , { from = "battle-3", to = "treasure" }
                , { from = "elite", to = "boss" }
                , { from = "treasure", to = "boss" }
                ]
            }

        initialMap =
            { floors = [ firstFloor ]
            , currentPosition = { floorLevel = 1, nodeId = "start" }
            }
    in
    Random.constant initialMap

-- 基本的な敵を作成するヘルパー関数
createBasicEnemy : String -> String -> EnemyData
createBasicEnemy id name =
    { id = id
    , name = name
    , hp = 10
    , maxHp = 10
    , attacks = 
        [ { name = "通常攻撃", damage = 2, description = "基本的な攻撃" }
        ]
    , scoreBonus = []
    , rewards = 
        [ { gold = 5
          , experience = 10
          , items = []
          }
        ]
    }

-- エリート敵を作成するヘルパー関数
createEliteEnemy : String -> String -> EnemyData
createEliteEnemy id name =
    { id = id
    , name = name
    , hp = 20
    , maxHp = 20
    , attacks = 
        [ { name = "強力な一撃", damage = 4, description = "通常より強力な攻撃" }
        , { name = "連続攻撃", damage = 2, description = "2回連続で攻撃" }
        ]
    , scoreBonus = 
        [ BonusType FourOfKind 5 
        ]
    , rewards = 
        [ { gold = 15
          , experience = 30
          , items = [ "random_common" ]
          }
        ]
    }

-- ボスを作成するヘルパー関数
createBoss : String -> String -> BossData
createBoss id name =
    { enemy = 
        { id = id
        , name = name
        , hp = 50
        , maxHp = 50
        , attacks = 
            [ { name = "火炎ブレス", damage = 6, description = "広範囲に及ぶ強力な攻撃" }
            , { name = "鋭い爪", damage = 3, description = "素早い連続攻撃" }
            , { name = "尻尾薙ぎ払い", damage = 4, description = "広範囲に中程度のダメージ" }
            ]
        , scoreBonus = 
            [ BonusType Yacht 10
            , BonusType LargeStraight 5
            ]
        , rewards = 
            [ { gold = 50
              , experience = 100
              , items = [ "rare_item", "next_floor_key" ]
              }
            ]
        }
    , specialPhases = 
        [ { hpThreshold = 25
          , description = "ドラゴンが怒りに震え、炎が激しく燃え上がる！"
          , effect = DoubleAttack
          }
        ]
    }

-- 次に進むことができるノードを取得
getAvailableNodes : Map -> List Node
getAvailableNodes map =
    let
        currentFloorLevel = map.currentPosition.floorLevel
        currentNodeId = map.currentPosition.nodeId
        
        currentFloor = 
            map.floors
                |> List.filter (\floor -> floor.level == currentFloorLevel)
                |> List.head
                |> Maybe.withDefault { level = 0, nodes = [], connections = [] }
                
        connectedNodeIds =
            currentFloor.connections
                |> List.filter (\conn -> conn.from == currentNodeId)
                |> List.map .to
                
        connectedNodes =
            currentFloor.nodes
                |> List.filter (\node -> List.member node.id connectedNodeIds && not node.visited)
    in
    connectedNodes

-- ノードに移動
moveToNode : String -> Map -> Map
moveToNode nodeId map =
    let
        currentFloorLevel = map.currentPosition.floorLevel
        
        updatedFloors =
            map.floors
                |> List.map 
                    (\floor -> 
                        if floor.level == currentFloorLevel then
                            { floor | 
                                nodes = 
                                    floor.nodes
                                        |> List.map 
                                            (\node -> 
                                                if node.id == nodeId then
                                                    { node | visited = True }
                                                else
                                                    node
                                            )
                            }
                        else
                            floor
                    )
    in
    { map 
    | floors = updatedFloors
    , currentPosition = { floorLevel = currentFloorLevel, nodeId = nodeId }
    }

-- 次のフロアにマップを拡張
addNextFloor : Map -> Generator Map
addNextFloor map =
    let
        nextLevel = 
            map.floors
                |> List.map .level
                |> List.maximum
                |> Maybe.withDefault 0
                |> (+) 1
                
        -- 次のフロアのノード数を決定
        nodeCount = nextLevel * 3 + 5
    in
    Random.map
        (\nextFloor ->
            { map | floors = map.floors ++ [ nextFloor ] }
        )
        (generateFloor nextLevel nodeCount)

-- ランダムなフロアを生成するジェネレータ
generateFloor : Int -> Int -> Generator Floor
generateFloor level nodeCount =
    -- この関数はランダムなマップ生成アルゴリズムを実装する
    -- 簡潔にするため、現時点では固定パターンを返す
    Random.constant
        { level = level
        , nodes = 
            [ { id = "start-" ++ String.fromInt level, nodeType = Rest, position = { x = 0.5, y = 0.1 }, visited = True }
            , { id = "boss-" ++ String.fromInt level, nodeType = Boss (createBoss ("boss-" ++ String.fromInt level) ("レベル" ++ String.fromInt level ++ "ボス")), position = { x = 0.5, y = 0.9 }, visited = False }
            ]
        , connections = []
        }
