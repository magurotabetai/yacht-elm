module Views.MainMenu exposing (viewMainMenu)

import Html exposing (Html, div, h1, h2, p, text)
import Html.Attributes exposing (class)
import Models.Game exposing (GameState)
import Update.Messages exposing (Msg(..))
import Views.Helpers exposing (spacer, viewButton)


viewMainMenu : GameState -> Html Msg
viewMainMenu _ =
    div [ class "main-menu" ]
        [ div [ class "game-title" ]
            [ h1 [] [ text "ヨットクエスト" ]
            , h2 [] [ text "YachtQuest" ]
            ]
        , spacer 4
        , div [ class "menu-options" ]
            [ viewButton "冒険を始める" StartGame False
            , spacer 2
            , viewButton "続きから" LoadGame False
            , spacer 2
            , viewButton "設定" OpenSettings False
            ]
        , div [ class "game-version" ]
            [ p [] [ text "Version 1.0.0" ]
            ]
        ]
