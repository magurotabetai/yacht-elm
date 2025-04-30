module Update.Update exposing (update, init)

import Browser.Dom as Dom
import Models.Character exposing (Character)
import Models.Dice exposing (rollMultipleDice, toggleHold)
import Models.Game exposing (GameState, Run, Battle, initGameState, startNewRun, startBattle)
import Models.Map exposing (moveToNode, getAvailableNodes)
import Models.Score exposing (markScoreUsed, isScoreAvailable, calculateScore)
import Models.Score.DamageCalculator exposing (calculateDamageFromScore)
import Models.Types exposing (GamePhase(..), NodeType(..), ScoreType(..), EnemyData, BossData, AttackData)
import Random
import Task
import Time
import Update.Messages exposing (Msg(..))

-- 初期化関数
init : () -> ( GameState, Cmd Msg )
init _ =
    ( initGameState 0
    , Task.perform Initialize Time.now
    )

-- アプリケーション更新関数
update : Msg -> GameState -> ( GameState, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Initialize time ->
            let
                initialSeed = Time.posixToMillis time
                initializedModel = initGameState initialSeed
            in
            ( initializedModel, Cmd.none )

        TickTime _ ->
            -- 時間経過に関する処理（アニメーションなど）
            ( model, Cmd.none )

        WindowResize _ _ ->
            -- ウィンドウサイズ変更時の処理
            ( model, Cmd.none )

        -- ゲーム進行関連
        StartGame ->
            ( { model | gamePhase = CharacterSelection }, Cmd.none )

        SelectCharacter character ->
            startNewRun character model

        BackToMainMenu ->
            ( { model | gamePhase = MainMenu }, Cmd.none )

        -- マップ関連
        EnterNode nodeId ->
            case model.currentRun of
                Just run ->
                    let
                        -- ノードに移動
                        updatedMap = moveToNode nodeId run.map
                        updatedRun = { run | map = updatedMap }

                        -- ノードの種類に応じた処理
                        ( nextPhase, cmd ) = handleNodeEntry nodeId updatedRun model.seed
                    in
                    ( { model | currentRun = Just updatedRun, gamePhase = nextPhase, seed = Tuple.second cmd }, Tuple.first cmd )

                Nothing ->
                    ( model, Cmd.none )

        MoveToNode node ->
            case model.currentRun of
                Just run ->
                    let
                        updatedMap = moveToNode node.id run.map
                        updatedRun = { run | map = updatedMap }
                    in
                    ( { model | currentRun = Just updatedRun }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        -- バトル関連
        StartBattle ->
            case model.currentRun of
                Just run ->
                    case getCurrentNodeEnemy run of
                        Just ( enemy, boss ) ->
                            let
                                ( updatedRun, cmd ) = startBattle enemy boss run
                            in
                            ( { model | currentRun = Just updatedRun, gamePhase = BattlePhase }, cmd )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        RollDice ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            if battle.remainingRerolls > 0 then
                                let
                                    generator = rollMultipleDice battle.dice
                                    ( newDice, newSeed ) = Random.step generator model.seed

                                    updatedBattle =
                                        { battle
                                        | dice = newDice
                                        , remainingRerolls = battle.remainingRerolls - 1
                                        }

                                    updatedRun =
                                        { run | currentBattle = Just updatedBattle }
                                in
                                ( { model | currentRun = Just updatedRun, seed = newSeed }, Cmd.none )
                            else
                                ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ToggleHoldDice id ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            let
                                updatedDice =
                                    battle.dice
                                        |> List.map
                                            (\dice ->
                                                if dice.id == id then
                                                    toggleHold dice
                                                else
                                                    dice
                                            )

                                updatedBattle =
                                    { battle | dice = updatedDice }

                                updatedRun =
                                    { run | currentBattle = Just updatedBattle }
                            in
                            ( { model | currentRun = Just updatedRun }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        SelectScore scoreType ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            -- スコアが使用可能なときだけ選択できる
                            if isScoreAvailable scoreType battle.scoreHistory then
                                let
                                    -- スコアを選択するだけで確定はしない
                                    updatedBattle =
                                        { battle | selectedScoreType = Just scoreType }

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

        EndTurn ->
            -- ターン終了処理（スコア選択なしでターンを終える場合）
            ( model, Cmd.none )

        UseActiveItem itemId ->
            -- アイテム使用処理（実装予定）
            ( model, Cmd.none )

        FinishBattle isVictory ->
            -- 戦闘終了処理
            case model.currentRun of
                Just run ->
                    let
                        updatedRun =
                            { run
                            | currentBattle = Nothing
                            , battlesWon = if isVictory then run.battlesWon + 1 else run.battlesWon
                            }
                    in
                    ( { model | currentRun = Just updatedRun, gamePhase = InRun }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ConfirmScore ->
            case model.currentRun of
                Just run ->
                    case run.currentBattle of
                        Just battle ->
                            case battle.selectedScoreType of
                                Just scoreType ->
                                    -- スコアが使用可能なときだけ確定できる
                                    if isScoreAvailable scoreType battle.scoreHistory then
                                        let
                                            -- スコア履歴を更新（使用済みに設定）
                                            updatedScoreHistory =
                                                markScoreUsed scoreType battle.scoreHistory

                                            -- 選択したスコアタイプに基づいてダメージを計算
                                            scoreDamage = calculateDamageFromScore scoreType battle.dice

                                            updatedEnemy =
                                                { id = battle.enemy.id
                                                , name = battle.enemy.name
                                                , hp = max 0 (battle.enemy.hp - scoreDamage)
                                                , maxHp = battle.enemy.maxHp
                                                , attacks = battle.enemy.attacks
                                                , scoreBonus = battle.enemy.scoreBonus
                                                , rewards = battle.enemy.rewards
                                                }

                                            -- バトルログを更新
                                            updatedLog =
                                                ("プレイヤーは " ++ String.fromInt scoreDamage ++ " ダメージを与えた！")
                                                    :: battle.battleLog

                                            -- 敵のHPがゼロになった場合は勝利
                                            ( gamePhase, finalLog, finalEnemy ) =
                                                if updatedEnemy.hp <= 0 then
                                                    ( InRun
                                                    , "敵を倒した！勝利！" :: updatedLog
                                                    , { updatedEnemy | hp = 0 }
                                                    )
                                                else
                                                    -- 敵の攻撃を処理
                                                    let
                                                        attackIndex = modBy (List.length battle.enemy.attacks) battle.turn
                                                        attack =
                                                            battle.enemy.attacks
                                                                |> List.drop attackIndex
                                                                |> List.head
                                                                |> Maybe.withDefault { name = "攻撃", damage = 1, description = "" }

                                                        enemyAttackLog = battle.enemy.name ++ "の" ++ attack.name ++ "! " ++ String.fromInt attack.damage ++ "ダメージ！"
                                                    in
                                                    ( BattlePhase, enemyAttackLog :: updatedLog, updatedEnemy )

                                            -- 戦闘情報を更新
                                            updatedBattle =
                                                { battle
                                                | scoreHistory = updatedScoreHistory
                                                , enemy = finalEnemy
                                                , turn = battle.turn + 1
                                                , remainingRerolls = 2  -- リロール回数をリセット
                                                , battleLog = finalLog
                                                , selectedScoreType = Nothing  -- 選択状態をリセット
                                                }

                                            updatedRun =
                                                if gamePhase == InRun then
                                                    -- 戦闘終了の場合
                                                    { run
                                                    | currentBattle = Nothing
                                                    , battlesWon = run.battlesWon + 1
                                                    , gold = run.gold + 10  -- 仮の獲得ゴールド
                                                    }
                                                else
                                                    -- 戦闘継続
                                                    { run | currentBattle = Just updatedBattle }
                                        in
                                        ( { model | currentRun = Just updatedRun, gamePhase = gamePhase }, Cmd.none )
                                    else
                                        -- すでに使用済みのスコアは選択できない
                                        ( model, Cmd.none )

                                Nothing ->
                                    -- スコアが選択されていない場合は何もしない
                                    ( model, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        -- その他のメッセージに対する処理
        _ ->
            ( model, Cmd.none )

-- ヘルパー関数：現在のノードから敵情報を取得
getCurrentNodeEnemy : Run -> Maybe ( EnemyData, Maybe BossData )
getCurrentNodeEnemy run =
    let
        currentFloorLevel = run.map.currentPosition.floorLevel
        currentNodeId = run.map.currentPosition.nodeId

        currentFloor =
            run.map.floors
                |> List.filter (\floor -> floor.level == currentFloorLevel)
                |> List.head

        findNode =
            \nodes ->
                nodes
                    |> List.filter (\node -> node.id == currentNodeId)
                    |> List.head
    in
    case currentFloor of
        Just floor ->
            case findNode floor.nodes of
                Just node ->
                    case node.nodeType of
                        BattleNode enemy ->
                            Just ( enemy, Nothing )

                        EliteBattleNode enemy ->
                            Just ( enemy, Nothing )

                        BossNode boss ->
                            Just ( boss.enemy, Just boss )

                        _ ->
                            Nothing

                Nothing ->
                    Nothing

        Nothing ->
            Nothing

-- ノード進入時の処理
handleNodeEntry : String -> Run -> Random.Seed -> ( GamePhase, ( Cmd Msg, Random.Seed ) )
handleNodeEntry nodeId run seed =
    let
        currentFloorLevel = run.map.currentPosition.floorLevel

        findNode =
            \nodes ->
                nodes
                    |> List.filter (\node -> node.id == nodeId)
                    |> List.head

        currentFloor =
            run.map.floors
                |> List.filter (\floor -> floor.level == currentFloorLevel)
                |> List.head
    in
    case currentFloor of
        Just floor ->
            case findNode floor.nodes of
                Just node ->
                    case node.nodeType of
                        BattleNode enemy ->
                            ( BattlePhase, ( Task.perform (\_ -> StartBattle) (Task.succeed ()), seed ) )

                        EliteBattleNode enemy ->
                            ( BattlePhase, ( Task.perform (\_ -> StartBattle) (Task.succeed ()), seed ) )

                        BossNode boss ->
                            ( BattlePhase, ( Task.perform (\_ -> StartBattle) (Task.succeed ()), seed ) )

                        RestNode ->
                            -- 休憩ポイント：HPを少し回復
                            ( InRun, ( Cmd.none, seed ) )

                        MerchantNode ->
                            -- 商人ノード：アイテム購入画面へ
                            ( InRun, ( Cmd.none, seed ) )

                        TreasureNode ->
                            -- 宝箱ノード：アイテム獲得
                            ( InRun, ( Cmd.none, seed ) )

                        EventNode eventType ->
                            -- イベントノード：各種イベント
                            ( EventPhase, ( Cmd.none, seed ) )

                Nothing ->
                    ( InRun, ( Cmd.none, seed ) )

        Nothing ->
            ( InRun, ( Cmd.none, seed ) )
