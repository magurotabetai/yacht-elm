module Models.Battle.Logic exposing
    ( applyEnemyAction
    , confirmScore
    , endTurn
    , getBattleResult
    , isBattleOver
    , rerollDice
    , rollDice
    , selectScore
    , toggleHoldDice
    )

import Models.Battle.Types exposing (Battle, BattleState(..))
import Models.Dice as Dice
import Models.Score as Score
import Models.Types exposing (ScoreType)
import Random
import Time



-- BATTLE ACTIONS (Pure functions that transform battle state)
-- Roll dice at the start of a turn


rollDice : Battle -> Random.Seed -> ( Battle, Random.Seed )
rollDice battle seed =
    let
        initialDice =
            if List.isEmpty battle.dice then
                Dice.standardDiceSet

            else
                battle.dice |> List.map (\d -> { d | held = False })

        ( rolledDice, newSeed ) =
            Random.step (Dice.rollMultipleDice initialDice) seed

        updatedBattle =
            { battle
                | dice = rolledDice
                , remainingRerolls = battle.maxRerolls
                , state = Rolling
            }
    in
    ( updatedBattle, newSeed )



-- Reroll selected dice


rerollDice : Battle -> Random.Seed -> ( Battle, Random.Seed )
rerollDice battle seed =
    -- Only allow reroll if in Rolling state and has remaining rerolls
    if battle.state /= Rolling || battle.remainingRerolls <= 0 then
        ( battle, seed )

    else
        let
            ( rolledDice, newSeed ) =
                Random.step (Dice.rollMultipleDice battle.dice) seed

            updatedBattle =
                { battle
                    | dice = rolledDice
                    , remainingRerolls = battle.remainingRerolls - 1
                    , state =
                        if battle.remainingRerolls <= 1 then
                            Selecting

                        else
                            Rolling
                }
        in
        ( updatedBattle, newSeed )



-- Toggle the held state of a specific dice


toggleHoldDice : String -> Battle -> Battle
toggleHoldDice diceId battle =
    if battle.state /= Rolling then
        battle

    else
        let
            updatedDice =
                List.map
                    (\dice ->
                        if dice.id == diceId then
                            Dice.toggleHold dice

                        else
                            dice
                    )
                    battle.dice
        in
        { battle | dice = updatedDice }



-- Select a score type (without confirming)


selectScore : ScoreType -> Battle -> Battle
selectScore scoreType battle =
    if battle.state /= Selecting && battle.state /= Rolling then
        battle

    else
    -- Check if this score is available
    if
        Score.isScoreAvailable scoreType battle.scoreHistory
    then
        { battle
            | selectedScoreType = Just scoreType
            , state = Selecting
        }

    else
        battle



-- Confirm selected score and apply damage


confirmScore : Battle -> Time.Posix -> Battle
confirmScore battle currentTime =
    case battle.selectedScoreType of
        Nothing ->
            battle

        Just scoreType ->
            if not (Score.isScoreAvailable scoreType battle.scoreHistory) then
                battle

            else
                let
                    -- Calculate the score value
                    scoreValue =
                        Score.calculateScoreValue scoreType battle.dice

                    -- Apply the score value as damage to the enemy
                    newEnemyHP =
                        max 0 (battle.enemyCurrentHP - scoreValue)

                    -- Update score history to mark this score as used
                    updatedScoreHistory =
                        Score.markScoreUsed scoreType battle.scoreHistory

                    -- Add log entry
                    logEntry =
                        { message = scoreTypeToString scoreType ++ "で" ++ String.fromInt scoreValue ++ "ダメージ！"
                        , timestamp = currentTime
                        }

                    updatedLog =
                        logEntry :: battle.log

                    -- Update battle state
                    updatedBattle =
                        { battle
                            | enemyCurrentHP = newEnemyHP
                            , scoreHistory = updatedScoreHistory
                            , selectedScoreType = Nothing
                            , log = updatedLog
                            , state =
                                if newEnemyHP <= 0 then
                                    BattleOver

                                else
                                    EnemyTurn
                        }
                in
                updatedBattle



-- End the player's turn and start the enemy's turn


endTurn : Battle -> Battle
endTurn battle =
    if battle.state /= EnemyTurn then
        battle

    else
        { battle
            | turn = battle.turn + 1
            , state = Rolling
        }



-- Apply enemy's action during their turn


applyEnemyAction : Battle -> Int -> Time.Posix -> Battle
applyEnemyAction battle damage currentTime =
    if battle.state /= EnemyTurn then
        battle

    else
        let
            -- Apply damage to player
            newPlayerHP =
                max 0 (battle.playerCurrentHP - damage)

            -- Add log entry
            logEntry =
                { message = battle.enemyName ++ "の攻撃！ " ++ String.fromInt damage ++ "ダメージを受けた！"
                , timestamp = currentTime
                }

            updatedLog =
                logEntry :: battle.log

            -- Update battle state
            updatedBattle =
                { battle
                    | playerCurrentHP = newPlayerHP
                    , log = updatedLog
                    , state =
                        if newPlayerHP <= 0 then
                            BattleOver

                        else
                            Rolling
                }
        in
        updatedBattle



-- Check if the battle is over


isBattleOver : Battle -> Bool
isBattleOver battle =
    battle.state == BattleOver || battle.enemyCurrentHP <= 0 || battle.playerCurrentHP <= 0



-- Get the result of the battle (if it's over)


getBattleResult : Battle -> Maybe Bool
getBattleResult battle =
    if not (isBattleOver battle) then
        Nothing

    else
        Just (battle.enemyCurrentHP <= 0)



-- HELPER FUNCTIONS
-- Convert score type to string for display


scoreTypeToString : ScoreType -> String
scoreTypeToString scoreType =
    case scoreType of
        Models.Types.Aces ->
            "エース"

        Models.Types.Twos ->
            "ツー"

        Models.Types.Threes ->
            "スリー"

        Models.Types.Fours ->
            "フォー"

        Models.Types.Fives ->
            "ファイブ"

        Models.Types.Sixes ->
            "シックス"

        Models.Types.Choice ->
            "チョイス"

        Models.Types.FourOfKind ->
            "フォーカインド"

        Models.Types.FullHouse ->
            "フルハウス"

        Models.Types.SmallStraight ->
            "Sストレート"

        Models.Types.LargeStraight ->
            "Lストレート"

        Models.Types.Yacht ->
            "ヨット"

        Models.Types.Special name ->
            name
