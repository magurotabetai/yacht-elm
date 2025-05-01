module Views.Router exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Models.Game exposing (GameState)
import Models.Types exposing (GamePhase(..))
import Update.Messages exposing (Msg)
import Views.Battle
import Views.CharacterSelection
import Views.MainMenu
import Views.Map



-- Router component that renders the appropriate view based on game phase


view : GameState -> Html Msg
view gameState =
    div [ class "game-container" ]
        [ case gameState.gamePhase of
            MainMenu ->
                Views.MainMenu.viewMainMenu gameState

            CharacterSelection ->
                Views.CharacterSelection.view gameState

            InRun ->
                case gameState.currentRun of
                    Just run ->
                        Views.Map.viewMap gameState run

                    Nothing ->
                        div [ class "error" ] [ text "Run data missing" ]

            BattlePhase ->
                case gameState.currentRun of
                    Just run ->
                        case run.currentBattle of
                            Just battle ->
                                Views.Battle.viewBattle gameState run battle

                            Nothing ->
                                -- Fallback if battle data is missing
                                div [ class "error" ] [ text "Battle data missing" ]

                    Nothing ->
                        -- Fallback if run data is missing
                        div [ class "error" ] [ text "Run data missing" ]

            EventPhase ->
                -- TODO: Implement event view
                div [] [ text "Event screen - To be implemented" ]

            GameOver ->
                -- TODO: Implement game over view
                div [ class "game-over" ] [ text "Game Over" ]

            Victory ->
                -- TODO: Implement victory view
                div [ class "victory" ] [ text "Victory!" ]
        ]
