module Views.Map exposing (viewMap)

import Html exposing (Html, div, h1, h2, p, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Models.Game exposing (GameState, Run)
import Models.Map exposing (Node, getAvailableNodes)
import Models.Types exposing (NodeType(..))
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (viewButton, spacer, viewBadge)


viewMap : GameState -> Run -> Html Msg
viewMap gameState run =
    div [ class "map-view" ]
        [ h1 [] [ text ("第" ++ String.fromInt run.currentFloor ++ "階層") ]
        , div [ class "map-status" ]
            [ viewPlayerStatus run ]
        , spacer 2
        , div [ class "map-container" ]
            [ viewMapNodes run ]
        ]

-- プレイヤーステータス表示
viewPlayerStatus : Run -> Html Msg
viewPlayerStatus run =
    div [ class "player-status" ]
        [ div [ class "status-item" ]
            [ div [ class "status-label" ] [ text "HP" ]
            , div [ class "health-bar" ]
                [ div
                    [ class "health-fill"
                    , style "width" (String.fromFloat (toFloat run.currentHP / toFloat run.maxHP * 100) ++ "%")
                    ] []
                ]
            , div [ class "health-text" ]
                [ text (String.fromInt run.currentHP ++ " / " ++ String.fromInt run.maxHP) ]
            ]
        , div [ class "status-item" ]
            [ div [ class "status-label" ] [ text "ゴールド" ]
            , div [ class "status-value gold" ] [ text (String.fromInt run.gold) ]
            ]
        , div [ class "status-item" ]
            [ div [ class "status-label" ] [ text "勝利数" ]
            , div [ class "status-value" ] [ text (String.fromInt run.battlesWon) ]
            ]
        ]

-- マップノード表示
viewMapNodes : Run -> Html Msg
viewMapNodes run =
    let
        -- 現在のフロアのノードを取得
        currentFloor =
            run.map.floors
                |> List.filter (\floor -> floor.level == run.currentFloor)
                |> List.head
                |> Maybe.withDefault { level = 0, nodes = [], connections = [] }

        -- 利用可能な（移動できる）ノードを取得
        availableNodes = getAvailableNodes run.map

        -- 特定のノードが利用可能かどうかをチェック
        isNodeAvailable nodeId =
            availableNodes
                |> List.any (\node -> node.id == nodeId)

        -- ノードとその接続を表示
        mapElements =
            [ div [ class "map-nodes" ]
                (List.map (viewNode isNodeAvailable) currentFloor.nodes)
            , div [ class "map-connections" ]
                (List.map (viewConnection currentFloor.nodes) currentFloor.connections)
            ]
    in
    div [ class "map-visual" ] mapElements

-- 個別のノード表示
viewNode : (String -> Bool) -> Node -> Html Msg
viewNode isAvailable node =
    let
        nodeTypeClass =
            case node.nodeType of
                Battle _ -> "node-battle"
                EliteBattle _ -> "node-elite"
                Rest -> "node-rest"
                Merchant -> "node-merchant"
                Treasure -> "node-treasure"
                Event _ -> "node-event"
                Boss _ -> "node-boss"

        nodeLabel =
            case node.nodeType of
                Battle _ -> "戦闘"
                EliteBattle _ -> "強敵"
                Rest -> "休憩"
                Merchant -> "商人"
                Treasure -> "宝箱"
                Event _ -> "イベント"
                Boss _ -> "ボス"
    in
    div
        [ class ("map-node " ++ nodeTypeClass)
        , class (if node.visited then "node-visited" else "")
        , class (if isAvailable node.id && not node.visited then "node-available" else "")
        , style "left" (String.fromFloat (node.position.x * 100) ++ "%")
        , style "top" (String.fromFloat (node.position.y * 100) ++ "%")
        , onClick (if isAvailable node.id && not node.visited then EnterNode node.id else NoOp)
        ]
        [ div [ class "node-icon" ] [ text (getNodeIcon node.nodeType) ]
        , div [ class "node-label" ] [ text nodeLabel ]
        ]

-- ノード間の接続線表示
viewConnection : List Node -> { from : String, to : String } -> Html Msg
viewConnection nodes connection =
    let
        fromNode = findNodeById connection.from nodes
        toNode = findNodeById connection.to nodes
    in
    case (fromNode, toNode) of
        (Just from, Just to) ->
            let
                -- 接続線のスタイル計算（簡易的な直線）
                x1 = from.position.x
                y1 = from.position.y
                x2 = to.position.x
                y2 = to.position.y

                -- CSSの変数を使って接続線の位置と角度を設定
                lineLength = sqrt ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) * 100
                angle = atan2 (y2 - y1) (x2 - x1) * 180 / pi

                lineStyle =
                    [ style "width" (String.fromFloat lineLength ++ "px")
                    , style "left" (String.fromFloat (x1 * 100) ++ "%")
                    , style "top" (String.fromFloat (y1 * 100) ++ "%")
                    , style "transform" ("rotate(" ++ String.fromFloat angle ++ "deg)")
                    , style "transform-origin" "0 0"
                    ]

                -- ノードの状態に基づいて線のクラスを変更
                pathClass =
                    if from.visited && to.visited then
                        "path-traveled"
                    else if from.visited then
                        "path-available"
                    else
                        "path-locked"
            in
            div
                (class ("map-connection " ++ pathClass) :: lineStyle)
                []

        _ ->
            text "" -- ノードが見つからない場合は何も表示しない

-- ヘルパー関数: ノードIDからノードを検索
findNodeById : String -> List Node -> Maybe Node
findNodeById id nodes =
    nodes
        |> List.filter (\node -> node.id == id)
        |> List.head

-- ノードタイプに応じたアイコン文字を返す
getNodeIcon : NodeType -> String
getNodeIcon nodeType =
    case nodeType of
        Battle _ -> "⚔️"
        EliteBattle _ -> "🔥"
        Rest -> "🏕️"
        Merchant -> "💰"
        Treasure -> "🎁"
        Event _ -> "❓"
        Boss _ -> "👑"
