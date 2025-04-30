module Models.Map exposing (..)

import Models.Types exposing (NodeType(..), EnemyData, BossData, AttackData, RewardData, EventType(..), ScoreBonus(..))
import Random

-- マップ全体の型定義
type alias Map =
    { floors : List Floor
    , currentPosition : NodePosition
    }

-- フロア（階層）の型定義
type alias Floor =
    { level : Int
    , nodes : List Node
    , connections : List Connection
    }

-- ノードの型定義
type alias Node =
    { id : String
    , nodeType : NodeType
    , position : Position
    , visited : Bool
    }

-- 接続情報の型定義
type alias Connection =
    { from : String
    , to : String
    }

-- 位置情報
type alias Position =
    { x : Float
    , y : Float
    }

-- 現在位置情報
type alias NodePosition =
    { floorLevel : Int
    , nodeId : String
    }

-- 初期マップの生成
initMap : Random.Seed -> ( Map, Random.Seed )
initMap seed =
    let
        initialFloors = [ createFirstFloor ]
        initialPosition = { floorLevel = 1, nodeId = "start" }
    in
    ( { floors = initialFloors
      , currentPosition = initialPosition
      }
    , seed
    )

-- 最初のフロア（テスト用の固定マップ）
createFirstFloor : Floor
createFirstFloor =
    let
        nodes =
            [ { id = "start"
              , nodeType = BattleNode (createBasicEnemy "rat" "ラット")
              , position = { x = 0.1, y = 0.5 }
              , visited = True
              }
            , { id = "node1"
              , nodeType = RestNode
              , position = { x = 0.3, y = 0.3 }
              , visited = False
              }
            , { id = "node2"
              , nodeType = BattleNode (createBasicEnemy "slime" "スライム")
              , position = { x = 0.3, y = 0.7 }
              , visited = False
              }
            , { id = "node3"
              , nodeType = MerchantNode
              , position = { x = 0.5, y = 0.2 }
              , visited = False
              }
            , { id = "node4"
              , nodeType = TreasureNode
              , position = { x = 0.5, y = 0.5 }
              , visited = False
              }
            , { id = "node5"
              , nodeType = EliteBattleNode (createEliteEnemy "goblin" "ゴブリン")
              , position = { x = 0.5, y = 0.8 }
              , visited = False
              }
            , { id = "node6"
              , nodeType = EventNode RandomReward
              , position = { x = 0.7, y = 0.4 }
              , visited = False
              }
            , { id = "node7"
              , nodeType = EventNode MysteryDice
              , position = { x = 0.7, y = 0.6 }
              , visited = False
              }
            , { id = "boss"
              , nodeType = BossNode (createBoss "minotaur" "ミノタウロス")
              , position = { x = 0.9, y = 0.5 }
              , visited = False
              }
            ]

        connections =
            [ { from = "start", to = "node1" }
            , { from = "start", to = "node2" }
            , { from = "node1", to = "node3" }
            , { from = "node1", to = "node4" }
            , { from = "node2", to = "node4" }
            , { from = "node2", to = "node5" }
            , { from = "node3", to = "node6" }
            , { from = "node4", to = "node6" }
            , { from = "node4", to = "node7" }
            , { from = "node5", to = "node7" }
            , { from = "node6", to = "boss" }
            , { from = "node7", to = "boss" }
            ]
    in
    { level = 1
    , nodes = nodes
    , connections = connections
    }

-- 基本的な敵の生成
createBasicEnemy : String -> String -> EnemyData
createBasicEnemy id name =
    { id = id
    , name = name
    , hp = 10
    , maxHp = 10
    , attacks =
        [ { name = "通常攻撃", damage = 1, description = "弱い攻撃" }
        , { name = "威嚇", damage = 0, description = "何も起こらない" }
        ]
    , scoreBonus = [ BonusType Models.Types.Choice 2 ]
    , rewards = [ { gold = 5, experience = 10, items = [] } ]
    }

-- エリート敵の生成
createEliteEnemy : String -> String -> EnemyData
createEliteEnemy id name =
    { id = id
    , name = name ++ " (エリート)"
    , hp = 20
    , maxHp = 20
    , attacks =
        [ { name = "強打", damage = 2, description = "強い攻撃" }
        , { name = "連撃", damage = 1, description = "2回攻撃する" }
        , { name = "特殊能力", damage = 3, description = "強力な特殊攻撃" }
        ]
    , scoreBonus = [ BonusType Models.Types.FourOfKind 5, PenaltyType Models.Types.Yacht 10 ]
    , rewards = [ { gold = 15, experience = 25, items = [ "common_item" ] } ]
    }

-- ボスの生成
createBoss : String -> String -> BossData
createBoss id name =
    { enemy =
        { id = id
        , name = name ++ " (ボス)"
        , hp = 40
        , maxHp = 40
        , attacks =
            [ { name = "激突", damage = 3, description = "強力な一撃" }
            , { name = "暴走", damage = 2, description = "連続攻撃" }
            , { name = "怒りの咆哮", damage = 4, description = "強力な範囲攻撃" }
            , { name = "地響き", damage = 1, description = "全体に弱いダメージ" }
            ]
        , scoreBonus = [ BonusType Models.Types.LargeStraight 10 ]
        , rewards = [ { gold = 50, experience = 100, items = [ "rare_item" ] } ]
        }
    , specialPhases =
        [ { hpThreshold = 20
          , description = "ボスが怒り状態になった！"
          , effect = Models.Types.DoubleAttack
          }
        ]
    }

-- マップでの移動処理
moveToNode : String -> Map -> Map
moveToNode nodeId map =
    let
        currentFloorLevel = map.currentPosition.floorLevel

        updateNode node =
            if node.id == nodeId then
                { node | visited = True }
            else
                node

        updateFloor floor =
            if floor.level == currentFloorLevel then
                { floor | nodes = List.map updateNode floor.nodes }
            else
                floor

        updatedFloors = List.map updateFloor map.floors
        updatedPosition = { floorLevel = currentFloorLevel, nodeId = nodeId }
    in
    { map | floors = updatedFloors, currentPosition = updatedPosition }

-- 利用可能なノードの取得
getAvailableNodes : Map -> List Node
getAvailableNodes map =
    let
        currentPosition = map.currentPosition

        getConnectedNodeIds floorLevel nodeId =
            map.floors
                |> List.filter (\floor -> floor.level == floorLevel)
                |> List.concatMap .connections
                |> List.filter (\conn -> conn.from == nodeId)
                |> List.map .to

        connectedIds = getConnectedNodeIds currentPosition.floorLevel currentPosition.nodeId

        getNodes floorLevel =
            map.floors
                |> List.filter (\floor -> floor.level == floorLevel)
                |> List.concatMap .nodes
                |> List.filter (\node -> List.member node.id connectedIds && not node.visited)
    in
    getNodes currentPosition.floorLevel
