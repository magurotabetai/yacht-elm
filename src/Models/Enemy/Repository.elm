module Models.Enemy.Repository exposing
    ( getBosses
    , getEliteEnemies
    , getEnemyById
    , getNormalEnemies
    , getRandomEnemy
    )

import Dict exposing (Dict)
import Models.Enemy.Types exposing (..)
import Models.Types exposing (ScoreType(..))
import Random



-- Enemy repository - Database of all enemies in the game


enemyDatabase : Dict String Enemy
enemyDatabase =
    Dict.fromList
        [ ( "slime"
          , { id = "slime"
            , name = "スライム"
            , description = "基本的な敵。特に特殊な能力はない。"
            , maxHP = 15
            , enemyType = Normal
            , attacks =
                [ { name = "体当たり"
                  , baseDamage = 2
                  , description = "弱い攻撃"
                  , pattern = Regular
                  , chance = 0.7
                  }
                , { name = "跳ねる"
                  , baseDamage = 1
                  , description = "複数回当たる"
                  , pattern = Regular
                  , chance = 0.3
                  }
                ]
            , rewards =
                { gold = 5
                , xp = 10
                , itemChance = 0.1
                , guaranteedItems = []
                }
            }
          )
        , ( "goblin"
          , { id = "goblin"
            , name = "ゴブリン"
            , description = "小型の妖精。武器を持っている。"
            , maxHP = 20
            , enemyType = Normal
            , attacks =
                [ { name = "ナイフ攻撃"
                  , baseDamage = 3
                  , description = "標準的な攻撃"
                  , pattern = Regular
                  , chance = 0.6
                  }
                , { name = "石投げ"
                  , baseDamage = 2
                  , description = "弱いが当たりやすい"
                  , pattern = Regular
                  , chance = 0.4
                  }
                ]
            , rewards =
                { gold = 8
                , xp = 15
                , itemChance = 0.2
                , guaranteedItems = []
                }
            }
          )
        , ( "fire_elemental"
          , { id = "fire_elemental"
            , name = "ファイアエレメンタル"
            , description = "炎の精霊。強力な火炎攻撃を使う。"
            , maxHP = 35
            , enemyType = Elite
            , attacks =
                [ { name = "火炎放射"
                  , baseDamage = 5
                  , description = "強力な火炎攻撃"
                  , pattern = Regular
                  , chance = 0.5
                  }
                , { name = "炎の渦"
                  , baseDamage = 3
                  , description = "複数回攻撃"
                  , pattern = Sequential
                  , chance = 0.3
                  }
                , { name = "燃え上がる"
                  , baseDamage = 7
                  , description = "チャージして強力な一撃"
                  , pattern = Charging 1
                  , chance = 0.2
                  }
                ]
            , rewards =
                { gold = 25
                , xp = 45
                , itemChance = 0.5
                , guaranteedItems = []
                }
            }
          )
        , ( "dragon_king"
          , { id = "dragon_king"
            , name = "ドラゴンキング"
            , description = "強大なドラゴン。複数の特殊フェーズを持つ。"
            , maxHP = 100
            , enemyType =
                Boss
                    { phases =
                        [ { hpThreshold = 70
                          , name = "怒り"
                          , description = "ドラゴンキングが怒り、攻撃力が上昇する"
                          , attackBuff = 1.5
                          , defenseBuff = 1.0
                          , specialEffect = Just "炎上"
                          }
                        , { hpThreshold = 30
                          , name = "暴走"
                          , description = "ドラゴンキングが暴走し、全ての能力が上昇する"
                          , attackBuff = 2.0
                          , defenseBuff = 1.3
                          , specialEffect = Just "リロール禁止"
                          }
                        ]
                    }
            , attacks =
                [ { name = "炎のブレス"
                  , baseDamage = 10
                  , description = "強力な炎のブレス"
                  , pattern = Regular
                  , chance = 0.4
                  }
                , { name = "爪撃"
                  , baseDamage = 7
                  , description = "鋭い爪による攻撃"
                  , pattern = Regular
                  , chance = 0.3
                  }
                , { name = "竜巻"
                  , baseDamage = 5
                  , description = "翼で巻き起こした竜巻"
                  , pattern = AdaptiveTo FullHouse
                  , chance = 0.2
                  }
                , { name = "メテオ召喚"
                  , baseDamage = 15
                  , description = "隕石を召喚する究極技"
                  , pattern = Charging 2
                  , chance = 0.1
                  }
                ]
            , rewards =
                { gold = 200
                , xp = 500
                , itemChance = 1.0
                , guaranteedItems = [ "dragon_scale" ]
                }
            }
          )
        ]



-- Get an enemy by ID


getEnemyById : String -> Maybe Enemy
getEnemyById id =
    Dict.get id enemyDatabase



-- Get all normal enemies


getNormalEnemies : List Enemy
getNormalEnemies =
    Dict.values enemyDatabase
        |> List.filter
            (\enemy ->
                case enemy.enemyType of
                    Normal ->
                        True

                    _ ->
                        False
            )



-- Get all elite enemies


getEliteEnemies : List Enemy
getEliteEnemies =
    Dict.values enemyDatabase
        |> List.filter
            (\enemy ->
                case enemy.enemyType of
                    Elite ->
                        True

                    _ ->
                        False
            )



-- Get all bosses


getBosses : List Enemy
getBosses =
    Dict.values enemyDatabase
        |> List.filter
            (\enemy ->
                case enemy.enemyType of
                    Boss _ ->
                        True

                    _ ->
                        False
            )



-- Get a random enemy of a specific type


getRandomEnemy : Random.Seed -> ( Maybe Enemy, Random.Seed )
getRandomEnemy seed =
    let
        enemies =
            Dict.values enemyDatabase

        ( index, newSeed ) =
            Random.step (Random.int 0 (List.length enemies - 1)) seed

        selectedEnemy =
            List.drop index enemies |> List.head
    in
    ( selectedEnemy, newSeed )



-- Get a random normal enemy


getRandomNormalEnemy : Random.Seed -> ( Maybe Enemy, Random.Seed )
getRandomNormalEnemy seed =
    let
        normalEnemies =
            getNormalEnemies

        ( index, newSeed ) =
            Random.step (Random.int 0 (List.length normalEnemies - 1)) seed

        selectedEnemy =
            List.drop index normalEnemies |> List.head
    in
    ( selectedEnemy, newSeed )
