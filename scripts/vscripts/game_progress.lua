require('player_power')
require('get_contract')
require('get_magic')
require('get_talent')
require('game_init')
require('scene/battlefield')
--发送到前端显示信息
function sendMsgOnScreenToAll(topTips,bottomTips)
    --print("======sendMsgOnScreenToAll======")
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            CustomUI:DynamicHud_Destroy(playerID,"UIBannerMsgBox")
	        CustomUI:DynamicHud_Create(playerID,"UIBannerMsgBox","file://{resources}/layout/custom_game/UI_banner_msg.xml",nil)
            CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "getTimeCountLUATOJS", {
                topTips = topTips,
                bottomTips = bottomTips
            } )
        end
    end
end

--游戏开始
function gameProgress()  
    gameInit()--游戏数据初始化，配置数据
    --游戏轮数
    local gameRound = 1
    prepareStep(gameRound)--开始游戏进程
end


--预备阶段
function prepareStep(gameRound)
    print("onStepLoop1========start"..gameRound)
    local step1 = "预备阶段倒数："
    local interval = 1 --运算间隔
    local loadingTime = 1.5 --延迟时间 
    local prepareTime = 1000 --准备阶段时长
    GameRules.checkWinTeam = nil

    initHeroStatus()
    
    getUpGradeListByRound(gameRound)
    --信息发送到前端
    Timers:CreateTimer(0 ,function ()
        --local gameTime = getNowTime()
        prepareTime = prepareTime - 1
        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step1 .. prepareTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)

        --时间结束则跳出计时循环进行下一阶段
        if prepareTime == 0  then
            --输出准备结束信息
            prepareOverMsgSend()
            --预备阶段结束后启动战斗阶段
            Timers:CreateTimer(loadingTime,function ()
                print("onStepLoop1========over",gameRound)
                --为未学习技能的玩家启动随机学习
                if gameRound ~= 4 and gameRound < 8 then
                    randomLearnMagic(gameRound)
                end
                if gameRound == 4 then 
                    randomLearnContract()
                end
                if gameRound == 8 then
                    closeMagicListTimeUp()
                end
                if gameRound > 8 then
                    randomLearnTalent(gameRound)
                end
                --进入战斗阶段倒计时
                battleStep(gameRound)
                return nil
            end)
            return nil
        end
        return interval
    end)

    
  
end

--战斗阶段
function battleStep(gameRound)
    --print("onStepLoop2========start")
    local step2 = "战斗时间还有："
    --扫描进程
    local interval = 1
    local loadingTime = 2
    local battleTime = 10 --战斗时间
    local battlefieldTimer = 30
    --英雄位置初始化到战斗阶段
    playerPositionTransfer(battlePointsTeam1,playersTeam1)
    playerPositionTransfer(battlePointsTeam2,playersTeam2)
    initHeroStatus()
    Timers:CreateTimer(0,function ()
        --print("onStepLoop2========check")
        --local gameTime = getNowTime()
        battleTime = battleTime - 1

        if battleTime % 30 == 0 then
            --法阵激活,每30秒一次
            battlefieldLaunchTimer()
            
        end

        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step2 .. battleTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)

        
        --此处两队人数判断，死光就结束
        checkWinTeam()
        
        if battleTime == 0 or GameRules.checkWinTeam ~= nil then -- 时间等于0结束
            --print("onStepLoop2========over")
            --时间结束，双方都-1
            if battleTime == 0 then
                GoodStoneHP = GoodStoneHP - 1
                BadStoneHP = BadStoneHP - 1
            end
            if GameRules.checkWinTeam == DOTA_TEAM_GOODGUYS then
                BadStoneHP = BadStoneHP - 1
            end
            if GameRules.checkWinTeam == DOTA_TEAM_BADGUYS then
                GoodStoneHP = GoodStoneHP - 1
            end

            if GoodStoneHP > 0 and BadStoneHP > 0 then  
                --如果双方的时间宝石都未使用完，则跳出循环进行下一轮游戏？？？？？？？？？？？？？
                --结算数据

                --输出回合结束信息
                roundOverMsgSend()
                --所有玩家不能控制
                allPlayerStop()
                
                

                --进行下一轮战斗
                Timers:CreateTimer(loadingTime,function ()
                    GameRules.checkWinTeam = nil
                    gameRound = gameRound + 1
                    --每次轮回初始化地图与数据
                    gameRoundInit()


                    prepareStep(gameRound) 
                    return nil
                end)
                return nil
            else
                --整局游戏结束
                --print("GAME========OVER")
                if GoodStoneHP == 0 then
                    finalWinTeam = DOTA_TEAM_BADGUYS
                end
                if BadStoneHP == 0 then
                    finalWinTeam = DOTA_TEAM_GOODGUYS
                end
                GameRules:SetGameWinner(finalWinTeam)
            end
            return nil
        end
        return interval
    end)
end

--初始化英雄状态

function initHeroStatus()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            if not hHero:IsAlive() then
                hHero:RespawnUnit()
            end
            hHero:GetAbilityByIndex(0):EndCooldown()
            hHero:GetAbilityByIndex(1):EndCooldown()
            hHero:GetAbilityByIndex(2):EndCooldown()
            hHero:GetAbilityByIndex(3):EndCooldown()
            hHero:GetAbilityByIndex(4):EndCooldown()
            hHero:GetAbilityByIndex(5):EndCooldown()
            hHero:GetAbilityByIndex(6):EndCooldown()
            hHero:GetAbilityByIndex(7):EndCooldown()
            hHero:GetAbilityByIndex(8):EndCooldown()
        end
    end
end

--预备阶段执行学习项目
function getUpGradeListByRound(gameRound)
  
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            if gameRound == 1 then
                openMagicListPreC(playerID)
            end
            if gameRound == 2 then
                openMagicListPreB(playerID)
            end
            if gameRound == 3 then
                openMagicListPreA(playerID)
            end
            if gameRound == 4 then
               openRandomContractList(playerID)
            end
            if gameRound == 5 then
                openMagicListC(playerID)
            end
            if gameRound == 6 then
                openMagicListB(playerID)
            end
            if gameRound == 7 then
                openMagicListA(playerID)
            end
            if gameRound == 8 then
                openRebuildMagicList(playerID)
            end
            if gameRound == 9 then
                openRandomTalentCList(playerID)
            end
            if gameRound == 10 then
                openRandomTalentBList(playerID)
            end
            if gameRound == 11 then
                openRandomTalentAList(playerID)
            end

        end
    end
   
       
end

--判断回合胜利方
function checkWinTeam()
    local goodAlive = 0
    local badAlive = 0
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hHero:IsAlive() then
                local heroTeam = hHero:GetTeam()
                if heroTeam == DOTA_TEAM_GOODGUYS then
                    goodAlive = goodAlive + 1
                end
                if heroTeam == DOTA_TEAM_BADDGUYS then
                    badAlive = badAlive + 1
                end
            end
        end
    end
    if goodAlive == 0 and GameRules.checkWinTeam == nil then
        GameRules.checkWinTeam = DOTA_TEAM_BADDGUYS
    end
    if badAlive == 0 and GameRules.checkWinTeam == nil then--调试关闭,最终需要打开
        --GameRules.checkWinTeam = DOTA_TEAM_GOODGUYS
    end

    if not GameRules.goodMagicStone:IsAlive() then
        GameRules.checkWinTeam = DOTA_TEAM_BADGUYS
    end

    if not GameRules.badMagicStone:IsAlive() then
        GameRules.checkWinTeam = DOTA_TEAM_GOODGUYS
    end

end




--每次轮回地图与玩家数据初始化
function gameRoundInit()
    print("===================================gameRoundInit===================================")
    
    initPlayerHero()--初始化所有玩家
    initMagicStone()--初始化魔法石
    initBattlefield()--初始化法阵

    --英雄位置初始化到预备阶段
    playerPositionTransfer(preparePointsTeam1,playersTeam1)
    playerPositionTransfer(preparePointsTeam2,playersTeam2)
     
end    

function initPlayerHero()
    
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            --初始化是否学习技能
            playerRoundLearn[playerID] = 0
            --初始化所有临时BUFF（未做好）（player_power）
            initTempPlayerPower()
            --复活英雄

        end
    end
end




--指定玩家传送到指定地点
function playerPositionTransfer(points,playersID)
    print("playerPositionTransfer")
    for i = 1, #playersID do
        local point = points[i]
        local position = point:GetAbsOrigin()
        local playerID = playersID[i]
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)

        --传送到指定地点
        FindClearSpaceForUnit( hero, position, false )
        --过滤之前移动操作
        hero:MoveToPosition(position)
        --移除玩家不能控制
        allPlayerStopRemove()
        --镜头跟随英雄
        PlayerResource:SetCameraTarget(playerID,hero)           
        Timers:CreateTimer(0.1,function ()
            PlayerResource:SetCameraTarget(playerID,nil)
            return nil
        end)
    end
end

--定身
function allPlayerStop()
    local playersID = playersAll
    for i = 1, #playersID do
        local playerID = playersID[i]
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then 
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            hero:AddAbility("ability_init_stop"):SetLevel(1)
        end
    end
end
--移除定身
function allPlayerStopRemove()
    local playersID = playersAll
    for i = 1, #playersID do
        local playerID = playersID[i]
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            local hero = PlayerResource:GetSelectedHeroEntity(playerID)
            --解除不可控制状态
            if (hero:HasAbility("ability_init_stop")) then
                hero:RemoveAbility("ability_init_stop")
            end
            if(hero:HasModifier("modifier_init_stop")) then
                hero:RemoveModifierByName("modifier_init_stop")
            end
        end
    end
end


function prepareOverMsgSend()
    local topTips = "准备阶段结束"
    local bottomTips = "战斗即将开始" 
    sendMsgOnScreenToAll(topTips,bottomTips)
end

function roundOverMsgSend()
    --print(GameRules.checkWinTeam)
    local winTeamStr
    if GameRules.checkWinTeam == DOTA_TEAM_GOODGUYS then
        winTeamStr =  "天辉胜利！"
    end
    if GameRules.checkWinTeam == DOTA_TEAM_BADGUYS then
        winTeamStr =  "夜魇胜利！"
    end
    print("比分："..GoodStoneHP..":"..BadStoneHP)
    local topTips = winTeamStr
    local bottomTips = "此轮战斗结束，时间宝石启动，新的战斗即将开始"
    sendMsgOnScreenToAll(topTips,bottomTips)
end


function getNowTime()
    local time = GameRules:GetGameTime() - GameRules.prepareTime
    time = math.floor(time)
    local min =  math.floor(time / 60)
    local sec =  time % 60
    if min < 10 then
        min = "0"..min
    end
    if sec < 10 then
        sec = "0"..sec
    end
    local timeStr = min .. ":" .. sec
    return timeStr
end




--游戏数据初始化
function gameInit()   
    --用于传送的位置标记实体
    --预备地点
    preparePointsTeam1 = {}
    --战斗地点
    battlePointsTeam1 = {}

    local preparePointTeam1_1 = Entities:FindByName(nil,"goodP1") --找到实体
    local preparePointTeam1_2 = Entities:FindByName(nil,"goodP2")--找到实体
    local preparePointTeam1_3 = Entities:FindByName(nil,"goodP3") 
    local preparePointTeam1_4 = Entities:FindByName(nil,"goodP4") 
    local preparePointTeam1_5 = Entities:FindByName(nil,"goodP5")   
    table.insert(preparePointsTeam1,preparePointTeam1_1)
    table.insert(preparePointsTeam1,preparePointTeam1_2)
    table.insert(preparePointsTeam1,preparePointTeam1_3)
    table.insert(preparePointsTeam1,preparePointTeam1_4)
    table.insert(preparePointsTeam1,preparePointTeam1_5)

    
    local battlePointTeam1_1 = Entities:FindByName(nil,"goodB1") --找到实体
    local battlePointTeam1_2 = Entities:FindByName(nil,"goodB2")--找到实体
    local battlePointTeam1_3 = Entities:FindByName(nil,"goodB3") 
    local battlePointTeam1_4 = Entities:FindByName(nil,"goodB4") 
    local battlePointTeam1_5 = Entities:FindByName(nil,"goodB5")   
    table.insert(battlePointsTeam1,battlePointTeam1_1)
    table.insert(battlePointsTeam1,battlePointTeam1_2)
    table.insert(battlePointsTeam1,battlePointTeam1_3)
    table.insert(battlePointsTeam1,battlePointTeam1_4)
    table.insert(battlePointsTeam1,battlePointTeam1_5)

    
    preparePointsTeam2 = {}
    battlePointsTeam2 = {}
    local preparePointTeam2_1 = Entities:FindByName(nil,"badP1") --找到实体
    local preparePointTeam2_2 = Entities:FindByName(nil,"badP2")--找到实体
    local preparePointTeam2_3 = Entities:FindByName(nil,"badP3") 
    local preparePointTeam2_4 = Entities:FindByName(nil,"badP4") 
    local preparePointTeam2_5 = Entities:FindByName(nil,"badP5")   
    table.insert(preparePointsTeam2,preparePointTeam2_1)
    table.insert(preparePointsTeam2,preparePointTeam2_2)
    table.insert(preparePointsTeam2,preparePointTeam2_3)
    table.insert(preparePointsTeam2,preparePointTeam2_4)
    table.insert(preparePointsTeam2,preparePointTeam2_5)

    
    local battlePointTeam2_1 = Entities:FindByName(nil,"badB1") --找到实体
    local battlePointTeam2_2 = Entities:FindByName(nil,"badB2")--找到实体
    local battlePointTeam2_3 = Entities:FindByName(nil,"badB3") 
    local battlePointTeam2_4 = Entities:FindByName(nil,"badB4") 
    local battlePointTeam2_5 = Entities:FindByName(nil,"badB5")   
    table.insert(battlePointsTeam2,battlePointTeam2_1)
    table.insert(battlePointsTeam2,battlePointTeam2_2)
    table.insert(battlePointsTeam2,battlePointTeam2_3)
    table.insert(battlePointsTeam2,battlePointTeam2_4)
    table.insert(battlePointsTeam2,battlePointTeam2_5)

    
    
    playersTeam1 ={}
    playersTeam2 ={}
    playersAll = {}
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        --local initPoint = initPoints[1] --数组从1开始
        -- local initPos = initPoint:GetAbsOrigin()
        -- local player = PlayerResource:GetPlayer(playerID)
        -- local hero = player:GetAssignedHero() --PlayerResource:GetSelectedHeroEntity(playerID)
        --local heros = HeroList:GetAllHeroes() --获取所有英雄--暂时没用

        local heroTeam = PlayerResource:GetTeam(playerID)--hero:GetTeam() --print("heroTeam:".. heroTeam ) -- GOOD=2, BAD=3-- print("goodguys:" .. DOTA_GC_TEAM_GOOD_GUYS)-- =0 -- print("badguys:" .. DOTA_GC_TEAM_BAD_GUYS)-- =1

        if heroTeam == DOTA_TEAM_GOODGUYS then --GOOD天辉
            table.insert(playersTeam1,playerID)
        end

        if heroTeam == DOTA_TEAM_BADGUYS then --BAD夜魇
            table.insert(playersTeam2,playerID)
        end
        table.insert(playersAll,playerID)
    end

    finalWinTeam = DOTA_TEAM_GOODGUYS
    GoodStoneHP = 11
    BadStoneHP = 11
    NumberStr ={"一","二","三","四","五","六","七","八","九","十","十一","十二","十三"} 
    GameRules.checkWinTeam = nil
end