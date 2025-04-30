module Views.CharacterSelection exposing (viewCharacterSelection)

import Html exposing (Html, div, h1, h2, img, p, text)
import Html.Attributes exposing (class, src, alt)
import Html.Events exposing (onClick)
import Models.Character exposing (Character, characterAbilityToString)
import Models.Game exposing (GameState)
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (viewButton, viewCard, spacer)


viewCharacterSelection : GameState -> Html Msg
viewCharacterSelection gameState =
    div [ class "character-selection" ]
        [ h1 [] [ text "キャラクター選択" ]
        , p [ class "selection-info" ] [ text "冒険に出るキャラクターを選択してください" ]
        , spacer 2
        , div [ class "characters-grid" ]
            (List.map viewCharacterCard gameState.unlockedContent.characters)
        , spacer 3
        , div [ class "navigation-buttons" ]
            [ viewButton "戻る" BackToMainMenu False ]
        ]

-- キャラクターカードの表示
viewCharacterCard : Character -> Html Msg
viewCharacterCard character =
    div
        [ class "character-card"
        , onClick (SelectCharacter character)
        ]
        [ div [ class "character-portrait" ]
            [ img [ src character.portrait, alt character.name ] [] ]
        , div [ class "character-info" ]
            [ h2 [] [ text character.name ]
            , p [ class "character-description" ] [ text character.description ]
            , viewCharacterStats character
            , div [ class "character-ability" ]
                [ p [ class "ability-title" ] [ text "特殊能力" ]
                , p [ class "ability-description" ] [ text (characterAbilityToString character.specialAbility) ]
                ]
            , div [ class "starting-items" ]
                [ p [ class "items-title" ] [ text "初期アイテム" ]
                , div [ class "items-list" ]
                    (List.map
                        (\item -> div [ class "item-name" ] [ text item.name ])
                        character.startingItems
                    )
                ]
            ]
        ]

-- キャラクターのステータス表示
viewCharacterStats : Character -> Html Msg
viewCharacterStats character =
    div [ class "character-stats" ]
        [ div [ class "stat" ]
            [ div [ class "stat-name" ] [ text "HP" ]
            , div [ class "stat-value" ] [ text (String.fromInt character.startingHP) ]
            ]
        ]
