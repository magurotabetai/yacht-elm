module Views.Map exposing (viewMap)

import Html exposing (Html, div, h1, h2, p, text, button, span)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Models.Game exposing (GameState, Run)
import Models.Map exposing (Node, getAvailableNodes)
import Models.Types exposing (NodeType(..))
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (viewButton)

-- マップ画面全体
viewMap : GameState -> Run -> Html Msg
viewMap gameState run =
    div [ class "map-view" ]
        [ viewMapStatus run
        , div [ class "map-container" ]
            [ viewMapVisual run ]
        ]

-- マップ上部のステータス表示
viewMapStatus : Run -> Html Msg
viewMapStatus run =
    div [ class "map-status" ]
        [ h2 [] [ text ("フロア " ++ String.fromInt run.currentFloor) ]
        , div [ class "player-status" ]
            [ viewStatusItem "HP" (String.fromInt run.currentHP ++ "/" ++ String.fromInt run.maxHP) "health"
            , viewStatusItem "ゴールド" (String.fromInt run.gold) "gold"
            , viewStatusItem "勝利数" (String.fromInt run.battlesWon) "battles"
            ]
        ]

-- ステータス項目
viewStatusItem : String -> String -> String -> Html Msg
viewStatusItem label value valueClass =
    div [ class "status-item" ]
        [ div [ class "status-label" ] [ text label ]
        , div [ class ("status-value " ++ valueClass) ] [ text value ]
        ]

-- マップの視覚表現
viewMapVisual : Run -> Html Msg
viewMapVisual run =
    let
        currentFloorLevel = run.currentFloor
        currentNodeId = run.map.currentPosition.nodeId

        currentFloor =
            run.map.floors
                |> List.filter (\floor -> floor.level == currentFloorLevel)
                |> List.head
                |> Maybe.withDefault { level = 0, nodes = [], connections = [] }

        availableNodes = getAvailableNodes run.map
    in
    div [ class "map-visual" ]
        [ viewMapConnections currentFloor.connections currentFloor.nodes currentNodeId availableNodes
        , viewMapNodes currentFloor.nodes currentNodeId availableNodes
        ]

-- マップのノード表示
viewMapNodes : List Node -> String -> List Node -> Html Msg
viewMapNodes nodes currentNodeId availableNodes =
    let
        isAvailable node =
            List.any (\availNode -> availNode.id == node.id) availableNodes

        isCurrentNode node =
            node.id == currentNodeId
    in
    div [ class "map-nodes" ]
        (List.map
            (\node ->
                viewMapNode node (isCurrentNode node) (isAvailable node)
            )
            nodes
        )

-- 個別のマップノード表示
viewMapNode : Node -> Bool -> Bool -> Html Msg
viewMapNode node isCurrent isAvailable =
    let
        nodeTypeClass =
            case node.nodeType of
                Battle _ ->
                    "node-battle"

                EliteBattle _ ->
                    "node-elite"

                Rest ->
                    "node-rest"

                Merchant ->
                    "node-merchant"

                Treasure ->
                    "node-treasure"

                Event _ ->
                    "node-event"

                Boss _ ->
                    "node-boss"

        nodeStatusClass =
            if isCurrent then
                " node-current"
            else if node.visited then
                " node-visited"
            else if isAvailable then
                " node-available"
            else
                ""

        nodeIcon =
            case node.nodeType of
                Battle _ ->
                    "⚔️"

                EliteBattle _ ->
                    "🔥"

                Rest ->
                    "🏕️"

                Merchant ->
                    "💰"

                Treasure ->
                    "💎"

                Event _ ->
                    "❓"

                Boss _ ->
                    "👑"

        nodeLabel =
            case node.nodeType of
                Battle _ ->
                    "戦闘"

                EliteBattle _ ->
                    "エリート"

                Rest ->
                    "休憩"

                Merchant ->
                    "商人"

                Treasure ->
                    "宝箱"

                Event _ ->
                    "イベント"

                Boss _ ->
                    "ボス"

        position =
            { x = node.position.x * 100 |> String.fromFloat
            , y = node.position.y * 100 |> String.fromFloat
            }

        clickEvent =
            if isAvailable then
                onClick (EnterNode node.id)
            else
                onClick NoOp
    in
    div
        [ class ("map-node " ++ nodeTypeClass ++ nodeStatusClass)
        , style "left" (position.x ++ "%")
        , style "top" (position.y ++ "%")
        , clickEvent
        ]
        [ div [ class "node-icon" ] [ text nodeIcon ]
        , div [ class "node-label" ] [ text nodeLabel ]
        ]

-- マップのノード間接続線表示
viewMapConnections : List { from : String, to : String } -> List Node -> String -> List Node -> Html Msg
viewMapConnections connections nodes currentNodeId availableNodes =
    let
        isAvailablePath connection =
            (connection.from == currentNodeId &&
             List.any (\node -> node.id == connection.to) availableNodes)

        isVisitedPath connection =
            List.any (\node -> node.id == connection.from && node.visited) nodes &&
            List.any (\node -> node.id == connection.to && node.visited) nodes

        getNodePosition nodeId =
            nodes
                |> List.filter (\n -> n.id == nodeId)
                |> List.head
                |> Maybe.map .position
                |> Maybe.withDefault { x = 0, y = 0 }
    in
    div [ class "map-connections" ]
        (List.map
            (\connection ->
                let
                    fromPos = getNodePosition connection.from
                    toPos = getNodePosition connection.to

                    -- 線の角度と長さを計算
                    dx = (toPos.x - fromPos.x) * 100
                    dy = (toPos.y - fromPos.y) * 100
                    length = sqrt (dx * dx + dy * dy)
                    angle = atan2 dy dx

                    pathClass =
                        if isVisitedPath connection then
                            "path-traveled"
                        else if isAvailablePath connection then
                            "path-available"
                        else
                            "path-locked"
                in
                div
                    [ class ("map-connection " ++ pathClass)
                    , style "left" (String.fromFloat (fromPos.x * 100) ++ "%")
                    , style "top" (String.fromFloat (fromPos.y * 100) ++ "%")
                    , style "width" (String.fromFloat length ++ "%")
                    , style "transform" ("rotate(" ++ String.fromFloat (angle * 180 / pi) ++ "deg)")
                    , style "transform-origin" "0 0"
                    ]
                    []
            )
            connections
        )
