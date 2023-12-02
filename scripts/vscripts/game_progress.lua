require('player_power')
require('get_contract')
require('get_magic')
require('get_talent')
require('game_init')
require('scene/battlefield')
require('button')
require('scene/power_up_vpcf')
--发送到前端显示信息
function sendMsgOnScreenToAll(topTips,bottomTips)
    --print("======sendMsgOnScreenToAll======")
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
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
    studyStep(gameRound)--开始游戏进程
end

--学习阶段
function studyStep(gameRound)
    print("onStepLoopStudy========start"..gameRound)
    --每次轮回初始化地图与数据
    gameRoundInit(gameRound)
    
    local step0 = "魔法学习阶段倒数："
    local studyTime = GameRules.studyTime
    local interval = 1 --运算间隔
    local loadingTime = 2 --延迟时间 
    

    initHeroStatus()   
    roundPowerUp(gameRound)
    refreshShopList(true,gameRound)
    getUpGradeListByRound(gameRound)

    Timers:CreateTimer(0 ,function ()
        studyTime = studyTime -1
        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step0 .. studyTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)
        if studyTime <= 3 then
            for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
                    if playerRoundLearn[playerID] ~= 1 then
                        EmitAnnouncerSoundForPlayer("scene_voice_round_study_counter",playerID)
                    end
                end
            end
        end
        if studyTime < 1 then
            --为未学习技能的玩家启动随机学习
            if gameRound ~= 4 and gameRound < 8 then
                randomLearnMagic(gameRound)
            end
            if gameRound == 4 then 
                randomLearnContract()
            end
            if gameRound == 8 then
                closeMagicListTimeUp()
                for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                    if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
                        heroStudyFinish(playerID)
                    end
                end
            end
            if gameRound > 8 then
                randomLearnTalent(gameRound)
            end
            prepareStep(gameRound)
            return nil
        end
        return interval
    end)
end

--策略阶段
function prepareStep(gameRound)
    print("onStepLoopPrepare========start"..gameRound)
    local step1 = "策略阶段倒数："
    local interval = 1 --运算间隔
    local loadingTime = 3 --延迟时间 
    local prepareTime = GameRules.prepareTime --策略阶段时长 
 
    --信息发送到前端
    Timers:CreateTimer(0 ,function ()
        --local gameTime = getNowTime()
        prepareTime = prepareTime - 1
        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step1 .. prepareTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)
        if prepareTime <= 3 then
            timeUpCounterSound()
        end
        --时间结束则跳出计时循环进行下一阶段
        if prepareTime < 1  then
            --输出准备结束信息
            prepareOverMsgSend()
            --轮回石清理
            samsaraStoneClear()
             --所有玩家不能控制
            allPlayerStop()
            --预备阶段结束后启动战斗阶段
            --英雄位置初始化到战斗阶段
            playerPositionTransfer(battlePointsTeam1,playersTeam1,loadingTime)
            playerPositionTransfer(battlePointsTeam2,playersTeam2,loadingTime)
            Timers:CreateTimer(loadingTime,function ()
                print("onStepLoop1========over",gameRound)
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
    local loadingTime = 3.5
    local battleTime = GameRules.battleTime --战斗时间
    local battlefieldTimer = GameRules.battlefieldTimer --法阵刷新激活
    local freeTime = GameRules.freeTime --自由活动时间
    local decisiveBattleTime = GameRules.decisiveBattleTime --剩余时间决战阶段
    EmitAnnouncerSound("scene_voice_round_battle_start")
    initHeroStatus()
    initTreasureBox()--宝箱创建
    Timers:CreateTimer(0,function ()
        --print("onStepLoop2========check")
        battleTime = battleTime - 1
        if battleTime % battlefieldTimer == 0 and battleTime / battlefieldTimer > 0 then
            --法阵激活,每30秒一次
            battlefieldLaunchTimer()
        end
        if battleTime == decisiveBattleTime then
            decisiveBattlePowerUp()
        end
        if battleTime <= 5 then 
            timeUpCounterSound()
        end
        local topTips = "第"..NumberStr[gameRound].."轮战斗"
        local bottomTips = step2 .. battleTime .. "秒"
        sendMsgOnScreenToAll(topTips,bottomTips)
        --此处两队人数判断，死光就结束
        checkWinTeam()
        if battleTime == 0 or GameRules.checkWinTeam ~= nil then -- 时间等于0结束
            --print("===checkWin===:"..GameRules.checkWinTeam)
            --print("onStepLoop2========over")
            --时间结束，双方都-1
           
            local delayTime = 0 --如果时间用完不需要5秒捡东西
            local winWay = false
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
            if GameRules.checkWinTeam ~= nil then
                delayTime = freeTime --战斗决胜负后准备跳转空余时间
                winWay = true
            end
            winRewardFunc(GameRules.checkWinTeam) --胜方奖励
            loseRewardFunc(GameRules.checkWinTeam, delayTime+loadingTime)--败方奖励
            if GoodStoneHP > 0 and BadStoneHP > 0 then  
                --如果双方的时间宝石都未使用完，则跳出循环进行下一轮游戏
                --结算数据
                --输出回合结束信息
                roundOverMsgSend(winWay)
                Timers:CreateTimer(delayTime,function ()
                    --所有玩家不能控制
                    allPlayerStop()
                    --进行下一轮战斗
                    --英雄位置初始化到预备阶段
                    playerPositionTransfer(preparePointsTeam1,playersTeam1,loadingTime)
                    playerPositionTransfer(preparePointsTeam2,playersTeam2,loadingTime)
                    --传送时间间隔
                    Timers:CreateTimer(loadingTime,function ()
                        gameRound = gameRound + 1
                        studyStep(gameRound) 
                        return nil
                    end)
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
    print("============initHeroStatus================")
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            if not hHero:IsAlive() then
                --hHero:RespawnUnit()
                hHero:RespawnHero(false,false) --自然复活，解决死亡回放问题
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

            local abilityNameC = hHero:GetAbilityByIndex(6):GetAbilityName()
            local abilityNameB = hHero:GetAbilityByIndex(7):GetAbilityName()
            local abilityNameA = hHero:GetAbilityByIndex(8):GetAbilityName()
            local modifierNameC = "modifier_"..abilityNameC.."_buff"
            local modifierNameB = "modifier_"..abilityNameB.."_buff"
            local modifierNameA = "modifier_"..abilityNameA.."_buff"

            if hHero:HasModifier(modifierNameC) then
                hHero:RemoveModifierByName(modifierNameC)
            end
            if hHero:HasModifier(modifierNameB) then
                hHero:RemoveModifierByName(modifierNameB)
            end
            if hHero:HasModifier(modifierNameA) then
                hHero:RemoveModifierByName(modifierNameA)
            end

            --初始化决战阶段buff
            if hHero:HasAbility("decisive_battle_buff_datadriven") then
                hHero:RemoveAbility("decisive_battle_buff_datadriven")
            end
            if hHero:HasModifier("modifier_decisive_battle_buff_datadriven") then
                hHero:RemoveModifierByName("modifier_decisive_battle_buff_datadriven")
            end

            --充能补满
            local abilityArry = {0,1,2,3,6,7,8} --技能位置
            for i = 1 , #abilityArry, 1 do
                local abilityTemp = hHero:GetAbilityByIndex(abilityArry[i])
                abilityTemp:SetCurrentAbilityCharges(abilityTemp:GetMaxAbilityCharges(1))
            end

        end
    end
end

--败方奖励兑现
function loseRewardFunc(winTeam, reversalTime)
    local loseTeam
    local samsaraStone
    local delayTime = 5
    local stoneCamTime = reversalTime - 5
    --print("loseReward:"..winTeam)
    if winTeam == DOTA_TEAM_GOODGUYS then
        loseTeam = DOTA_TEAM_BADGUYS
        samsaraStone = badSamsaraStone
    end
    if winTeam == DOTA_TEAM_BADGUYS then
        loseTeam = DOTA_TEAM_GOODGUYS
        samsaraStone = goodSamsaraStone
    end
    Timers:CreateTimer(delayTime,function()
        if loseTeam ~= nil then
            loseRewardOperation(samsaraStone,loseTeam,stoneCamTime)
        else
            loseRewardOperation(goodSamsaraStone,DOTA_TEAM_GOODGUYS,stoneCamTime)
            loseRewardOperation(badSamsaraStone,DOTA_TEAM_BADGUYS,stoneCamTime)
        end
    end)
end

function loseRewardOperation(samsaraStone,loseTeam,stoneCamTime)
    local ability = samsaraStone:GetAbilityByIndex(0)
    local position = samsaraStone:GetAbsOrigin()
    local readyTime = 0.5
    local holdTime = 1
    local duration = stoneCamTime - holdTime - readyTime
    local loseSamsaraStoneHP = samsaraStone:GetHealth() - 1
    local unitModel
    if loseTeam == DOTA_TEAM_GOODGUYS then
        unitModel = "samsaraStoneDropUnitGood"
    end
    if loseTeam == DOTA_TEAM_BADGUYS then
        unitModel = "samsaraStoneDropUnitBad"
    end

    Timers:CreateTimer(readyTime,function()
        EmitSoundOn("scene_voice_samsara_stone_running", samsaraStone)
        ability:ApplyDataDrivenModifier(samsaraStone, samsaraStone, "modifier_samsara_stone_ability_datadriven", {Duration = duration}) 
    end)
    
    Timers:CreateTimer(duration,function()
        samsaraStone:SetHealth(loseSamsaraStoneHP) 
        local samsaraStoneDorpUnit = CreateUnitByName(unitModel, position, true, nil, nil, loseTeam)
        samsaraStoneDorpUnit.name = unitModel
        samsaraStoneDorpUnit:GetAbilityByIndex(0):SetLevel(1)
        samsaraStonePiece(samsaraStoneDorpUnit)
        samsaraStone.rewardUnit = samsaraStoneDorpUnit
    end)

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local hHeroTeam = hHero:GetTeam()
            if hHeroTeam == loseTeam then
                --PlayerResource:SetCameraTarget(playerID,samsaraStone)
                camFollowUnit(playerID,samsaraStone,stoneCamTime)
            end
        end
    end
end

--胜方奖励兑现
function winRewardFunc(winTeam)
    if winTeam == DOTA_TEAM_GOODGUYS then
        roundRewardOperation(DOTA_TEAM_GOODGUYS,DOTA_TEAM_BADGUYS,true)
    end
    if winTeam == DOTA_TEAM_BADGUYS then
        roundRewardOperation(DOTA_TEAM_BADGUYS,DOTA_TEAM_GOODGUYS,true)
    end
    if winTeam == nil then
        roundRewardOperation(DOTA_TEAM_GOODGUYS,DOTA_TEAM_BADGUYS,false)
    end
    winTeamParticle(winTeam) -- 胜利特效
end

function roundRewardOperation(winTeam,loseTeam,winFlag)--flag:平局标签 false为平局
    local winReward = GameRules.winBaseReward --基础回合奖励
    local loseReward = 0
    local endReward = 0 --终结连胜奖励
    if winFlag then
        local endSeriesWin = seriesWinRound[loseTeam]
        if endSeriesWin >= 2 then 
            endReward = GameRules.endSeriesWinReward[1] --终结2连胜奖励
            if endSeriesWin >= 3 then
                endReward = GameRules.endSeriesWinReward[2] --终结3连胜以上奖励
            end
        end
        seriesWinRound[winTeam] = seriesWinRound[winTeam] + 1 --胜方连胜+1
        seriesWinRound[loseTeam] = 0  --败方清0
        --连胜2场以上
        local seriesWinRound = seriesWinRound[winTeam]
        if seriesWinRound >= 2 then
            winReward = GameRules.seriesWinReward[1]--获得2连胜奖励
            if seriesWinRound >= 3 then
                winReward = GameRules.seriesWinReward[2] --获得3连胜以上奖励
            end
        end
    else --平局
        local endGoodSeriesWin = seriesWinRound[DOTA_TEAM_GOODGUYS]
        local endBadSeriesWin = seriesWinRound[DOTA_TEAM_BADGUYS]

        --如果触发终结连胜，重新定义胜负队伍，否则都一样
        if endGoodSeriesWin >= 2 or endBadSeriesWin >= 2 then
            if endGoodSeriesWin >= 2 then
                winTeam = DOTA_TEAM_BADGUYS
                loseTeam = DOTA_TEAM_GOODGUYS
            end
            if endBadSeriesWin >= 2 then
                winTeam = DOTA_TEAM_GOODGUYS
                loseTeam = DOTA_TEAM_BADGUYS
            end
            endReward = GameRules.endSeriesWinReward[1] --终结2连胜奖励
            if endGoodSeriesWin >= 3 or endBadSeriesWin >= 3 then
                endReward = GameRules.endSeriesWinReward[2] --终结3连胜以上奖励
            end
        end
        seriesWinRound[DOTA_TEAM_GOODGUYS] = 0
        seriesWinRound[DOTA_TEAM_BADGUYS] = 0
    end

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local hHeroTeam = hHero:GetTeam()
            local roundReward = 0
            if hHeroTeam == winTeam then
                roundReward = winReward + endReward
                --print("胜利+连胜金币："..winReward.."，终结奖励："..endReward)
                PlayerResource:SetGold(playerID, hHero:GetGold()+roundReward, true)
			    showGoldWorthParticle(playerID,roundReward,"team")
            end
            --[[
            if hHeroTeam == loseTeam then
                roundReward = loseReward
                print("失败金币："..loseReward)
            end]]
        end
    end
end

--预备阶段执行学习项目
function getUpGradeListByRound(gameRound)
    local showStatusUpTime = 2 --展示能力提升时间
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local heroHiddenStatusAbility = hHero:GetAbilityByIndex(12)
            heroHiddenStatusAbility:ApplyDataDrivenModifier(hHero, hHero, "modifier_hero_study_datadriven", {Duration = -1}) 
            Timers:CreateTimer(showStatusUpTime ,function ()
                EmitAnnouncerSound("scene_voice_round_study")
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
            end)
        end
    end   
end

--判断回合胜利方
function checkWinTeam()
    local goodAlive = 0
    local badAlive = 0
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            if hHero:IsAlive() then
                local heroTeam = hHero:GetTeam()
                if heroTeam == DOTA_TEAM_GOODGUYS then
                    goodAlive = goodAlive + 1
                end
                if heroTeam == DOTA_TEAM_BADGUYS then
                    badAlive = badAlive + 1
                end
            end
        end
    end

    if goodAlive == 0 and GameRules.checkWinTeam == nil then
        GameRules.checkWinTeam = DOTA_TEAM_BADGUYS
    end
    if badAlive == 0 and GameRules.checkWinTeam == nil and not GameRules.testMode then
        GameRules.checkWinTeam = DOTA_TEAM_GOODGUYS
    end

    if goodMagicStone.alive == 0 or not goodMagicStone:IsAlive() then
        GameRules.checkWinTeam = DOTA_TEAM_BADGUYS
    end

    if badMagicStone.alive == 0 or not badMagicStone:IsAlive() then
        --print("==111==",GameRules.badMagicStone:IsAlive())
        GameRules.checkWinTeam = DOTA_TEAM_GOODGUYS
    end
end

--为胜利方添加胜利特效
function winTeamParticle(winTeam)
    local winTeamParticle = "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf"
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local heroTeam = hHero:GetTeam()
            if heroTeam == winTeam then
                local particleID = ParticleManager:CreateParticle(winTeamParticle, PATTACH_ABSORIGIN_FOLLOW , hHero)
                ParticleManager:SetParticleControl(particleID, 0, hHero:GetAbsOrigin())
                EmitAnnouncerSoundForPlayer("scene_voice_player_win",playerID)
            end
        end
    end
end

--每次轮回地图与玩家数据初始化
function gameRoundInit(gameRound)
    print("===================================gameRoundInit===================================")   
    initPlayerHero()--初始化所有玩家
    initMagicStone()--初始化魔法石
    initBattlefield()--初始化法阵   
   
    clearTreasureBox() --清理上局的箱子
    dorpItems = {}
    GameRules.checkWinTeam = nil
    GameRules.gameRound = gameRound
end    

--初始化英雄局内数据
function initPlayerHero()  
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            --初始化是否学习技能,初始化刷新第一次装备金币
            playerRoundLearn[playerID] = 0
            playerRefreshCost[playerID] = GameRules.refreshCost
            --初始化所有临时BUFF（未做好）（player_power）
            --initTempPlayerPower()
        end
    end
end

--轮回石初始化
function samsaraStoneClear()
    samsaraStoneGet(goodSamsaraStone)
    samsaraStoneGet(badSamsaraStone)
end



function refreshShopList(initLockFlag,gameRound)
    --刷新商店列表
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            if playerShopLock[playerID] == 0 then
                refreshShopListByPlayerID(playerID)
            end
            playerShopLock[playerID] = 0
        end
    end
end

--每回合提升
function roundPowerUp(gameRound)
    print("roundPowerUp")
    local healthArray = {0,10,10,10,10,10,10,10,10,10,10,10}
    local visionArray = {0,50,50,50,50,0,0,0,0,0,0,0}
    local cooldownArray = {0,2,2,2,2,2,2,2,2,2,2,2}
    local manaRegenArray = {0,1,1,1,1,1,1,1,1,1,1,1,1}
    local cooldownVpcf = "particles/lunhui_cdjiakuai.vpcf"
    local healthVpcf = "particles/lunhui_xueliangzengjia.vpcf"
    local manaRegenVpcf = "particles/lunhui_huilan.vpcf"
    local damageVpcf = "particles/lunhui_gongjili.vpcf"
    local visionVpcf =  "particles/lunhui_shiyezengjia.vpcf"
    local baseVpcf = "particles/lunhuirenwutexiao_good.vpcf"
    local keys = {}
    if gameRound > 1 then
        EmitAnnouncerSound("scene_voice_round_up")
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
                local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
                keys.caster = hHero
                setPlayerPower(playerID, "talent_health", true, healthArray[gameRound])
                setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
                setPlayerPower(playerID, "talent_vision", true, visionArray[gameRound])
                setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseHealth)
                setPlayerPower(playerID, "talent_cooldown", true, cooldownArray[gameRound])
                setPlayerBuffByNameAndBValue(keys,"cooldown",0)
                setPlayerPower(playerID, "talent_mana_regen", true, manaRegenArray[gameRound])
                setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)

                Timers:CreateTimer(0,function()
                    OnPowerUp(hHero,cooldownVpcf,cooldownArray[gameRound],"cooldown")
                    OnPowerUpSharp(hHero,baseVpcf) --轮回升级闪光特效
                end)
                Timers:CreateTimer(0.2,function()
                    OnPowerUp(hHero,healthVpcf,healthArray[gameRound],"health")
                end)
                Timers:CreateTimer(0.4,function()
                    OnPowerUp(hHero,manaRegenVpcf,manaRegenArray[gameRound],"mana_regen")
                end)
                Timers:CreateTimer(0.6,function()
                    OnPowerUp(hHero,visionVpcf,visionArray[gameRound],"vision")
                end)
            end
        end
    end
end


--每回合决战阶段提升
function decisiveBattlePowerUp()
    EmitAnnouncerSound("scene_voice_round_battle_fight")
    EmitAnnouncerSound("scene_voice_round_battle_buff_get")
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            --keys.caster = hHero
            hHero:AddAbility("decisive_battle_buff_datadriven"):SetLevel(1)
        end
    end
end

--指定玩家传送到指定地点
function playerPositionTransfer(points,playersID,loadingTime)
    print("playerPositionTransfer")
    for i = 1, #playersID do
        local point = points[i]
        local position = point:GetAbsOrigin()
        local playerID = playersID[i]
        local hero = PlayerResource:GetSelectedHeroEntity(playerID)
        local landParticlesName ="particles/items2_fx/teleport_end.vpcf"
        local oldPosition = hero:GetAbsOrigin()
        local landParticlesID = ParticleManager:CreateParticle(landParticlesName, PATTACH_ABSORIGIN_FOLLOW, hero)
        ParticleManager:SetParticleControl(landParticlesID, 0, oldPosition)
        ParticleManager:SetParticleControl(landParticlesID, 1, oldPosition)

        Timers:CreateTimer(loadingTime,function ()
            --传送到指定地点
            FindClearSpaceForUnit(hero, position, false )
            --过滤之前移动操作
            hero:MoveToPosition(position)
            --移除玩家不能控制
            allPlayerStopRemove()
            --镜头跟随英雄
            camFollowUnit(playerID, hero, 0.5)    
            Timers:CreateTimer(0.5,function ()
                ParticleManager:DestroyParticle(landParticlesID, true)
                return nil
            end)
            return nil
        end)
    end
end

--镜头跟随英雄
function camFollowUnit(playerID,unit,duration)
    PlayerResource:SetCameraTarget(playerID,unit)           
    Timers:CreateTimer(duration,function ()
        PlayerResource:SetCameraTarget(playerID,nil)
        return nil
    end)
end

--定身
function allPlayerStop(flag)
    local playersID = playersAll
    for i = 1, #playersID do
        local playerID = playersID[i]
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then 
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            hHero:AddAbility("ability_init_stop"):SetLevel(1)
            EmitSoundOn("scene_voice_player_fly",hHero)
        end
        
    end
end
--移除定身
function allPlayerStopRemove()
    local playersID = playersAll
    for i = 1, #playersID do
        local playerID = playersID[i]
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            --解除不可控制状态
            if (hHero:HasAbility("ability_init_stop")) then
                hHero:RemoveAbility("ability_init_stop")
            end
            if(hHero:HasModifier("modifier_init_stop")) then
                hHero:RemoveModifierByName("modifier_init_stop")
            end
            EmitSoundOn("scene_voice_player_land",hHero)
        end
    end
end


function prepareOverMsgSend()
    local topTips = "准备阶段结束"
    local bottomTips = "战斗即将开始" 
    sendMsgOnScreenToAll(topTips,bottomTips)
end

function roundOverMsgSend(winWay)
    --print(GameRules.checkWinTeam)
    local winTeamStr
    if GameRules.checkWinTeam == DOTA_TEAM_GOODGUYS then
        winTeamStr =  "天辉胜利！"
    end
    if GameRules.checkWinTeam == DOTA_TEAM_BADGUYS then
        winTeamStr =  "夜魇胜利！"
    end
    if GameRules.checkWinTeam == nil then
        winTeamStr = "平局"
    end
    --print("比分："..GoodStoneHP..":"..BadStoneHP)
    local topTips = winTeamStr
    local bottomTips = "此轮战斗结束，时间宝石启动，新的战斗即将开始"
    
    sendMsgOnScreenToAll(topTips,bottomTips)
    local timeCount = 5
    if winWay then
        Timers:CreateTimer(function()
            bottomTips = "此轮战斗结束，时间宝石启动，新的战斗秒"..timeCount.."后开始"
            sendMsgOnScreenToAll(topTips,bottomTips)
            timeCount = timeCount - 1
            if timeCount < 0 then
                bottomTips = "此轮战斗结束，时间宝石启动，新的战斗即将开始"
                sendMsgOnScreenToAll(topTips,bottomTips)
                return nil
            end
            timeUpCounterSound()
            return 1
        end)
    end
end


function getNowTime()
    local time = GameRules:GetGameTime() - GameRules.PreTime
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

function timeUpCounterSound()
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            EmitAnnouncerSoundForPlayer("scene_voice_round_study_counter",playerID)
        end
    end
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
    GoodStoneHP = 6
    BadStoneHP = 6
    NumberStr ={"一","二","三","四","五","六","七","八","九","十","十一","十二","十三"} 
end