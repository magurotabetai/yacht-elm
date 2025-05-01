module Models.Map exposing
    ( Floor
    , Map
    , Node
    , NodeType(..)
    , Position
    , getAvailableNodes
    , initMap
    , isMapCompleted
    , moveToNode
    )

import Models.Enemy.Types exposing (Enemy)
import Random



-- TYPES
-- Map - Aggregate root for the map domain


type alias Map =
    { floors : List Floor
    , currentPosition : NodePosition
    }



-- Floor - Value object representing a level in the game


type alias Floor =
    { level : Int
    , nodes : List Node
    , connections : List Connection
    }



-- Node - Value object representing a location on the map


type alias Node =
    { id : String
    , nodeType : NodeType
    , position : Position
    , visited : Bool
    }



-- Node types - Value objects for different location types


type NodeType
    = BattleNode String -- Enemy ID
    | EliteBattleNode String -- Elite Enemy ID
    | RestNode
    | MerchantNode
    | TreasureNode
    | EventNode EventType
    | BossNode String -- Boss ID



-- Event types - Value objects for different event scenarios


type EventType
    = RandomReward
    | MysteryDice
    | HealthOrGold
    | UpgradeItem
    | SpecialEncounter String



-- Connection - Value object representing paths between nodes


type alias Connection =
    { from : String
    , to : String
    }



-- Position - Value object for spatial placement


type alias Position =
    { x : Float
    , y : Float
    }



-- Current position tracking - Value object


type alias NodePosition =
    { floorLevel : Int
    , nodeId : String
    }



-- INITIALIZATION
-- Initialize a new map


initMap : Random.Seed -> ( Map, Random.Seed )
initMap seed =
    let
        initialFloors =
            [ createFirstFloor ]

        initialPosition =
            { floorLevel = 1, nodeId = "start" }
    in
    ( { floors = initialFloors
      , currentPosition = initialPosition
      }
    , seed
    )



-- Create the first floor with a predefined layout


createFirstFloor : Floor
createFirstFloor =
    let
        nodes =
            [ { id = "start"
              , nodeType = BattleNode "rat"
              , position = { x = 0.1, y = 0.5 }
              , visited = True
              }
            , { id = "node1"
              , nodeType = RestNode
              , position = { x = 0.3, y = 0.3 }
              , visited = False
              }
            , { id = "node2"
              , nodeType = BattleNode "slime"
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
              , nodeType = EliteBattleNode "goblin"
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
              , nodeType = BossNode "dragon_king"
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



-- MAP OPERATIONS
-- Move to a new node on the map


moveToNode : String -> Map -> Map
moveToNode nodeId map =
    let
        currentFloorLevel =
            map.currentPosition.floorLevel

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

        updatedFloors =
            List.map updateFloor map.floors

        updatedPosition =
            { floorLevel = currentFloorLevel, nodeId = nodeId }
    in
    { map | floors = updatedFloors, currentPosition = updatedPosition }



-- Get nodes that can be visited from the current position


getAvailableNodes : Map -> List Node
getAvailableNodes map =
    let
        currentPosition =
            map.currentPosition

        -- Find all connected node IDs
        connectedIds =
            map.floors
                |> List.filter (\floor -> floor.level == currentPosition.floorLevel)
                |> List.concatMap .connections
                |> List.filter (\conn -> conn.from == currentPosition.nodeId)
                |> List.map .to

        -- Get the actual nodes that are connected and not visited
        availableNodes =
            map.floors
                |> List.filter (\floor -> floor.level == currentPosition.floorLevel)
                |> List.concatMap .nodes
                |> List.filter (\node -> List.member node.id connectedIds && not node.visited)
    in
    availableNodes



-- Check if the map is completed (boss node visited)


isMapCompleted : Map -> Bool
isMapCompleted map =
    let
        isBossNode node =
            case node.nodeType of
                BossNode _ ->
                    True

                _ ->
                    False

        isBossVisited =
            map.floors
                |> List.concatMap .nodes
                |> List.filter isBossNode
                |> List.any .visited
    in
    isBossVisited
