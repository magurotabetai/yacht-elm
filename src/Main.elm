module Main exposing (main)

import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)


main : Html msg
main =
    div [ class "elm-app" ]
        [ h1 [] [ text "こんにちは、Elmの世界！" ]
        , div [] [ text "RSpackでElmを使ってみましょう！" ]
        ]
