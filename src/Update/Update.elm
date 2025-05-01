module Update.Update exposing (init, update)

import Browser
import Models.Battle.Logic as BattleLogic
import Models.Battle.Types exposing (BattleState(..))
import Models.Character.Characters exposing (availableCharacters)
import Models.Game as Game exposing (GameState)
import Models.Score as Score
import Models.Types exposing (GamePhase(..))
import Process
import Random
import Task
import Time
import Update.Messages exposing (Msg(..))



-- INITIALIZATION


init : () -> ( GameState, Cmd Msg )
init _ =
    -- Initialize with current timestamp as seed
    ( Game.initGameState 0
    , Task.perform Initialize Time.now
    )



-- UPDATE


update : Msg -> GameState -> ( GameState, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        -- System messages
        Initialize time ->
            -- Use current time to seed the random number generator
            let
                seed =
                    time |> Time.posixToMillis |> Random.initialSeed

                newModel =
                    { model | seed = seed }
            in
            ( newModel, Cmd.none )

        TickTime newTime ->
            -- Update time in the model, could be used for animations, etc.
            ( model, Cmd.none )

        WindowResize width height ->
            -- Handle window resize events
            ( model, Cmd.none )

        -- Game flow messages
        StartGame ->
            -- Move to character selection screen
            ( { model | gamePhase = CharacterSelection }, Cmd.none )

        SelectCharacter character ->
            -- Start a new run with the selected character
            Game.startNewRun character.id model

        BackToMainMenu ->
            -- Return to main menu
            ( { model | gamePhase = MainMenu }, Cmd.none )

        -- Battle actions
        StartBattle ->
            case model.currentRun of
                Just run ->
                    case model.gamePhase of
                        InRun ->
                            -- For now we'll just start a battle with a random enemy (slime)
                            let
                                ( updatedRun, newSeed ) =
                                    Game.startBattle "slime" run model.seed
                            in
                            ( { model
                                | currentRun = Just updatedRun
                                , gamePhase = BattlePhase
                                , seed = newSeed
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        RollDice ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            if battle.state == Rolling then
                                let
                                    ( updatedBattle, newSeed ) =
                                        BattleLogic.rerollDice battle model.seed

                                    updatedRun =
                                        { run | currentBattle = Just updatedBattle }
                                in
                                ( { model
                                    | currentRun = Just updatedRun
                                    , seed = newSeed
                                  }
                                , Cmd.none
                                )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ToggleHoldDice diceId ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            if battle.state == Rolling then
                                let
                                    updatedBattle =
                                        BattleLogic.toggleHoldDice diceId battle

                                    updatedRun =
                                        { run | currentBattle = Just updatedBattle }
                                in
                                ( { model | currentRun = Just updatedRun }, Cmd.none )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        SelectScore scoreType ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            if battle.state == Selecting || battle.state == Rolling then
                                if Score.isScoreAvailable scoreType battle.scoreHistory then
                                    let
                                        updatedBattle =
                                            BattleLogic.selectScore scoreType battle

                                        updatedRun =
                                            { run | currentBattle = Just updatedBattle }
                                    in
                                    ( { model | currentRun = Just updatedRun }, Cmd.none )

                                else
                                    ( model, Cmd.none )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ConfirmScore ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            case battle.selectedScoreType of
                                Just _ ->
                                    -- Get current time for the battle log
                                    ( model, Task.perform (\time -> ConfirmScoreWithTime time) Time.now )

                                Nothing ->
                                    ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ConfirmScoreWithTime time ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            let
                                updatedBattle =
                                    BattleLogic.confirmScore battle time

                                isBattleOver =
                                    BattleLogic.isBattleOver updatedBattle

                                updatedRun =
                                    { run | currentBattle = Just updatedBattle }

                                updatedModel =
                                    { model | currentRun = Just updatedRun }
                            in
                            if isBattleOver then
                                -- Battle is over, check result
                                case BattleLogic.getBattleResult updatedBattle of
                                    Just True ->
                                        -- Player won
                                        let
                                            runWithBattleWon =
                                                { updatedRun
                                                    | battlesWon = updatedRun.battlesWon + 1
                                                    , currentHP = updatedBattle.playerCurrentHP
                                                    , currentBattle = Nothing
                                                }
                                        in
                                        ( { updatedModel
                                            | currentRun = Just runWithBattleWon
                                            , gamePhase = InRun
                                          }
                                        , Cmd.none
                                        )

                                    Just False ->
                                        -- Player lost
                                        ( { updatedModel | gamePhase = GameOver }, Cmd.none )

                                    Nothing ->
                                        -- Battle continues
                                        ( updatedModel, Cmd.none )

                            else
                                -- Battle continues, enemy's turn
                                -- Normally we'd calculate the enemy's attack, for now use a fixed value
                                let
                                    -- Delay the enemy's attack for better UX
                                    enemyAttackCmd =
                                        Process.sleep 1000
                                            |> Task.andThen (\_ -> Task.succeed (EnemyAttack 3))
                                            |> Task.perform identity
                                in
                                ( updatedModel, enemyAttackCmd )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EndTurn ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            if battle.state == EnemyTurn then
                                let
                                    updatedBattle =
                                        BattleLogic.endTurn battle

                                    updatedRun =
                                        { run | currentBattle = Just updatedBattle }

                                    -- Roll dice for the new turn
                                    ( battleWithRolledDice, newSeed ) =
                                        BattleLogic.rollDice updatedBattle model.seed

                                    finalRun =
                                        { updatedRun | currentBattle = Just battleWithRolledDice }
                                in
                                ( { model
                                    | currentRun = Just finalRun
                                    , seed = newSeed
                                  }
                                , Cmd.none
                                )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EnemyAttack damage ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            if battle.state == EnemyTurn then
                                -- Get current time for the battle log
                                ( model, Task.perform (\time -> EnemyAttackWithTime damage time) Time.now )

                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        EnemyAttackWithTime damage time ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            let
                                updatedBattle =
                                    BattleLogic.applyEnemyAction battle damage time

                                isBattleOver =
                                    BattleLogic.isBattleOver updatedBattle

                                updatedRun =
                                    { run | currentBattle = Just updatedBattle }
                            in
                            if isBattleOver then
                                -- Player lost
                                ( { model
                                    | currentRun = Just updatedRun
                                    , gamePhase = GameOver
                                  }
                                , Cmd.none
                                )

                            else
                                -- Battle continues, player's turn
                                ( { model | currentRun = Just updatedRun }
                                , Task.perform (\_ -> EndTurn) (Process.sleep 500)
                                )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        -- Other messages
        _ ->
            -- For now, handle other messages as no-op
            ( model, Cmd.none )
