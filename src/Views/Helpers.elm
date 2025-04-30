module Views.Helpers exposing (..)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)
import Update.Messages exposing (Msg)


-- 標準ボタン
viewButton : String -> Msg -> Bool -> Html Msg
viewButton label msg isDisabled =
    button
        [ class (buttonClasses isDisabled)
        , onClick msg
        , disabled isDisabled
        ]
        [ text label ]

-- アイコン付きボタン
viewIconButton : String -> String -> Msg -> Bool -> Html Msg
viewIconButton iconName label msg isDisabled =
    button
        [ class (buttonClasses isDisabled)
        , onClick msg
        , disabled isDisabled
        ]
        [ div [ class "icon" ] [ text iconName ] -- 実際の実装ではSVGなどを使う
        , text label
        ]

-- カード形式のコンテナ
viewCard : String -> List (Html Msg) -> Html Msg
viewCard title content =
    div [ class "card" ]
        [ div [ class "card-header" ] [ text title ]
        , div [ class "card-content" ] content
        ]

-- セクションの区切り
viewSection : String -> List (Html Msg) -> Html Msg
viewSection title content =
    div [ class "section" ]
        [ div [ class "section-header" ] [ text title ]
        , div [ class "section-content" ] content
        ]

-- ボタンのスタイルクラス
buttonClasses : Bool -> String
buttonClasses isDisabled =
    if isDisabled then
        "btn btn-disabled"
    else
        "btn btn-primary"

-- スペーサー
spacer : Int -> Html Msg
spacer size =
    div [ class ("spacer spacer-" ++ String.fromInt size) ] []

-- 情報バッジ
viewBadge : String -> String -> Html Msg
viewBadge badgeType label =
    div [ class ("badge badge-" ++ badgeType) ]
        [ text label ]
