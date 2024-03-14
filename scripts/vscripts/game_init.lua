require('scene/grass_hide')
--require('scene/player_battlefield_buff')
require('scene/magic_tower')
require('myMaths')
LinkLuaModifier( "modifier_power_up", "scene/modifier_power_up.lua" , LUA_MODIFIER_MOTION_NONE)
function initMapStatus()
    --真随机设定
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
    math.randomseed(tonumber(timeTxt))

    TreasureBoxGold = "treasureBoxGold"
    
    --playerBattlefieldBuff = {}--6个法阵初始化(10个是备用而已)
    for playerID = 0, 9 do
        --playerBattlefieldBuff[i] = {} 
        --玩家数据初始化
        --playerContractLearn[playerID]={}
        --playerContractLearn[playerID]['contractName'] = 'nil'

        playerBlinkLearn[playerID] = {}
        playerBlinkLearn[playerID]['name'] = 'nil'
        playerTalentLearn[playerID]={}
        playerTalentLearn[playerID]['talentNameC'] = 'nil'
        playerTalentLearn[playerID]['talentNameB'] = 'nil'
        playerTalentLearn[playerID]['talentNameA'] = 'nil'
        playerOrderTarget[playerID] = 'nil'
        playerRandomItemNumList[playerID] = {}
        playerShopLock[playerID] = 0
        playerRefreshCost[playerID] = GameRules.refreshCost
        playerSeriesKill[playerID] = 0
    end

    --掉落物品
    dorpItems = {} 

    --初始化连胜局计算
    seriesWinRound = {}
    seriesWinRound[DOTA_TEAM_GOODGUYS] = 0
    seriesWinRound[DOTA_TEAM_BADGUYS] = 0

    --各种箱子
    centerTreasureBox = {}
    otherTreasureBox = {}
    remainsBox = {}

    --用于商店
    roundItemNameList = {}
	roundItemCostList = {}
	roundItemTextureNameList = {}
	roundItemAttributeList = {}

    --法阵能力设置
    --[[
    BattlefieldBuffVision = {200,200,300,300,400,400,400,400,400,400}
    BattlefieldBuffSpeed = {30,38,46,54,62,70,78,86,94,102}
    BattlefieldBuffManaRegen = {10,12,13,15,16,18,19,21,22,24}
    ]]
    --商店刷新库
    shopProbability = {}
    --建立商店
    creatShop()

    
    --刷怪
    --[[
    for i=1, 8 ,1 do
        createUnit('yang',DOTA_TEAM_BADGUYS)
    end
    ]]
    --grassBuffWork()
end

function clearTreasureBox()
    for k,val in pairs(centerTreasureBox) do
        if val.alive == 1 then
            val:ForceKill(true)
        end
    end
    centerTreasureBox = {}

    for k,val in pairs(otherTreasureBox) do
        if val.alive == 1 then
            val:ForceKill(true)
        end
    end
    otherTreasureBox ={}

    for k,val in pairs(remainsBox) do
        if val.alive == 1 then
            val:ForceKill(true)
        end
    end
    remainsBox = {}
end

--中央宝箱
--[[
function initCenterTreasureBox()
    print("=====================initCenterTreasureBox==========================")
    local centerBox = "centerbox"
    local centerRandonNumList = getRandomNumList(1, 3, 2)
    for i = 1, 2 ,1 do
        local centerBoxName = "centerbox"..centerRandonNumList[i]
        local centerBoxEntities = Entities:FindByName(nil,centerBoxName) 
        local centerBox = CreateUnitByName("treasureBoxGold", centerBoxEntities:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
        centerBox:GetAbilityByIndex(0):SetLevel(1)
        centerBox:GetAbilityByIndex(1):SetLevel(1)
        centerBox.alive = 1
        table.insert(centerTreasureBox,centerBox)
    end
end]]

--野区宝箱
function initTreasureBox()
    print("=====================initTreasureBox==========================")
    local goodBox = "goodbox"
    local badBox = "badbox"
    local goodRandonNumList = getRandomNumList(1, 6, 3)
    local badRandonNumList = getRandomNumList(1, 6, 3)
    for i = 1, 3 ,1 do
        local goodBoxName = "goodbox"..goodRandonNumList[i]
        local goodBoxEntities = Entities:FindByName(nil,goodBoxName) 
        local goodBox = CreateUnitByName("treasureBoxGold", goodBoxEntities:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
        goodBox:GetAbilityByIndex(0):SetLevel(1)
        goodBox:GetAbilityByIndex(1):SetLevel(1)
        goodBox.alive = 1
        table.insert(otherTreasureBox,goodBox)
    end

    for i = 1, 3 ,1 do
        local badBoxName = "badbox"..badRandonNumList[i]
        local badBoxEntities = Entities:FindByName(nil,badBoxName) 
        local badBox = CreateUnitByName("treasureBoxGold", badBoxEntities:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
        badBox:GetAbilityByIndex(0):SetLevel(1)
        badBox:GetAbilityByIndex(1):SetLevel(1)
        badBox.alive = 1
        table.insert(otherTreasureBox,badBox)
    end
end

--轮回石初始化
function initSamsaraStone()
    local goodSamsaraStoneEntities = Entities:FindByName(nil,"goodSamsaraStone") 
    local goodSamsaraStoneLocation = goodSamsaraStoneEntities:GetAbsOrigin()
    goodSamsaraStone = CreateUnitByName("samsaraStone", goodSamsaraStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    goodSamsaraStone:SetSkin(0)
    goodSamsaraStone:SetAngles(0, 270, 10)
    goodSamsaraStone:GetAbilityByIndex(0):SetLevel(1)

    local badSamsaraStoneEntities = Entities:FindByName(nil,"badSamsaraStone") 
    local badSamsaraStoneLocation = badSamsaraStoneEntities:GetAbsOrigin()
    badSamsaraStone = CreateUnitByName("samsaraStone", badSamsaraStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    badSamsaraStone:SetSkin(1)
    badSamsaraStone:SetAngles(0, 270, 10)
    badSamsaraStone:GetAbilityByIndex(0):SetLevel(1)
end

--轮回石碎片获取
function samsaraStoneGet(samsaraStone)
    local rewardUnit =  samsaraStone.rewardUnit
    local teamBonus = GameRules.loseBaseReward
    local stoneTeam = samsaraStone:GetTeam()
    if rewardUnit ~= nil then
        rewardUnit:SetModelScale(0.01)
        rewardUnit:ForceKill(true)      
        ParticleManager:DestroyParticle(rewardUnit.particleID, true)
        samsaraStone.rewardUnit = nil
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
                local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hHero:GetTeam() == stoneTeam then
                    PlayerResource:SetGold(playerID, hHero:GetGold()+teamBonus, true)
                    showGoldWorthParticle(playerID,teamBonus,"team")
                end
            end
        end
    end
end



-- 商人
function creatShop()
    local shop1=Entities:FindByName(nil,"shop1") 
    local shop1Pos = shop1:GetAbsOrigin()
    local unit1 = CreateUnitByName("shopUnit", shop1Pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
    unit1:SetAngles(0, 225, 0)
    unit1:GetAbilityByIndex(0):SetLevel(1)
    unit1:SetContext("name", "shop", 0)


    local shop2=Entities:FindByName(nil,"shop2") 
    local shop2Pos = shop2:GetAbsOrigin()
    local unit2 = CreateUnitByName("shopUnit", shop2Pos, true, nil, nil, DOTA_TEAM_BADGUYS)
    unit2:SetAngles(0, 225, 0)
    unit2:GetAbilityByIndex(0):SetLevel(1)
    unit2:SetContext("name", "shop", 0)

    local testunit =Entities:FindByName(nil,"testdog") 
    local testdog = CreateUnitByName("testdog", Vector(-8410.24,-739.667,264), true, nil, nil, DOTA_TEAM_NEUTRALS)
    --testdog:GetAbilityByIndex(0):SetLevel(1)
    testdog:SetContext("name", "testdog", 0)

end


--玩家英雄初始化
function initHero()
    --初始化所有玩家的数据
    
    playerRoundLearn = {}--用于记录玩家是否学习，用于启动随机学习

    playerOrderTarget = {} --玩家点击单位
    --playerContractLearn = {} --玩家天赋
    playerBlinkLearn = {}

    playerTalentLearn = {} --玩家铭文
    playerRandomItemNumList = {} --玩家商店物品随机数
    playerShopLock = {} --玩家商店锁定标记
    playerRefreshCost = {} --玩家商店刷新金钱
    playerSeriesKill = {} --玩家累计连续击杀（死亡清0）
    playerIDByHero = {}
    

    
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        --print("======GetConnectionState=========")
        --print(PlayerResource:GetConnectionState(playerID))
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            hHero.playerID = playerID
            local heroTeam = hHero:GetTeam()
            
            for i = 0 , hHero:GetAbilityCount() do
                local tempAbility = hHero:GetAbilityByIndex(i)
                if tempAbility ~= nil then
                    hHero:RemoveAbility(tempAbility:GetAbilityName())
                end
            end
            local commonAttack 
            if heroTeam == DOTA_TEAM_GOODGUYS then
                commonAttack = "common_attack_good_datadriven"
            end
            if heroTeam == DOTA_TEAM_BADGUYS then
                commonAttack = "common_attack_bad_datadriven"
            end
            --local tempAbility = hHero:GetAbilityByIndex(0):GetAbilityName()
            --hHero:RemoveAbility(tempAbility) 
            local heroAbility = hHero:GetUnitName().."_ability"
            --print("heroAbility:"..heroAbility)
            hHero:AddAbility("nothing_c"):SetLevel(1) --0
            hHero:AddAbility("nothing_b"):SetLevel(1) --1
            hHero:AddAbility("nothing_a"):SetLevel(1) --2

            hHero:AddAbility(commonAttack):SetLevel(1)  --3
            hHero:AddAbility(heroAbility):SetLevel(1) --4
            hHero:AddAbility("blink"):SetLevel(1) --5   --push_all_datadriven

            hHero:AddAbility("nothing_c_stage"):SetLevel(1) --6
            hHero:AddAbility("nothing_b_stage"):SetLevel(1) --7
            hHero:AddAbility("nothing_a_stage"):SetLevel(1) --8
            hHero:AddAbility("hero_order_datadriven"):SetLevel(1) --9
            hHero:AddAbility('treasure_box_open_datadriven'):SetLevel(1) --10
            hHero:AddAbility('battlefield_capture_datadriven'):SetLevel(1) --11
            hHero:AddAbility("hero_hidden_status_datadriven"):SetLevel(1) --11
            hHero:AddAbility("make_friend_datadriven"):SetLevel(1) --12
            

            hHero:SetTimeUntilRespawn(1) --重新设置复活时间

            PlayerResource:SetGold(playerID,50,true)

            

            

            local player = PlayerResource:GetPlayer(playerID)
            --右下按钮显示
            CustomUI:DynamicHud_Create(playerID,"UIButtonBox","file://{resources}/layout/custom_game/UI_button.xml",nil)
            Timers:CreateTimer(2,function ()
                CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "initJS", {})
            end)
            --契约板面
            --CustomUI:DynamicHud_Create(playerID,"UIContractPanelBG","file://{resources}/layout/custom_game/UI_contract_box.xml",nil)
            

            --天赋面板
            CustomUI:DynamicHud_Create(playerID,"UITalentPanelBG","file://{resources}/layout/custom_game/UI_talent_box.xml",nil)

            
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local heroHiddenStatusAbility = hHero:GetAbilityByIndex(12)
            heroHiddenStatusAbility:ApplyDataDrivenModifier(hHero, hHero, "modifier_hero_study_datadriven", {Duration = 2}) 
        end
    end

end


--物品掉落（金币箱打开）
function RollDrops(unit)
	local dropInfoSort = initDropInfo(unit:GetUnitName())
    --print("===========RollDrops=============:"..#dropInfoSort)
    for k = 0 , #dropInfoSort do
        local item_name = dropInfoSort[k]['name']
        local chance = dropInfoSort[k]['chance']
        --print("Creating "..item_name.."="..chance)
        if RollPercentage(chance) then
            -- 创建对应的物品
            --print("item_name:==========================="..item_name)
            local item = CreateItem(item_name, nil, nil)	--handle CreateItem(string item_name, handle owner, handle owner)
            local pos = unit:GetAbsOrigin()
            -- 用LaunchLoot函数可以有一个掉落动画，当然，也可以用CreateItemOnPositionSync来直接掉落。
              -- item:LaunchLoot(false, 50, 50, pos)
            CreateItemOnPositionSync(pos,item)
            break;
        end
    end
-- 循环所有需要掉落的物品
--[[
        for item_name,chance in pairs(dropInfoSort) do
            print("Creating "..item_name.."="..chance)
            if RollPercentage(chance) then
                -- 创建对应的物品
				
                local item = CreateItem(item_name, nil, nil)	--handle CreateItem(string item_name, handle owner, handle owner)
                local pos = unit:GetAbsOrigin()
				-- 用LaunchLoot函数可以有一个掉落动画，当然，也可以用CreateItemOnPositionSync来直接掉落。
              	-- item:LaunchLoot(false, 50, 50, pos)
				CreateItemOnPositionSync(pos,item)
				GameRules.BaoshiPos = pos
                
            end
        end]]
end

function RollPercentageFlag(randomNum)
    local flag = false
    local randomNum = math.random()
    local chanceNum = randomNum / 100
    if randomNum < chanceNum then
        flag = true
    end        
    return flag
end

function initDropInfo(unitName)
    -- 读取上面读取的掉落KV文件，然后读取到对应的单位的定义文件
    local dropInfo = GameRules.DropTable[unitName]
    local dropInfoSort = {}
    --print("initDropInfo")
    if dropInfo then
        local i = 0
        for item_name,chance in pairs(dropInfo) do
            local tempName = item_name
            local tempChance = chance
            --print("start:"..tempName.."="..tempChance)
            for j = 0 , i do  
                if j == i then
                    dropInfoSort[i] = {}
                    dropInfoSort[i]['name'] = tempName
                    dropInfoSort[i]['chance'] = tempChance
                    --print("i="..i..",name="..tempName.."="..tempChance)
                    break;
                end
                    --print("check:"..tempChance..'<'..dropInfoSort[j]['chance'])
                if tempChance < dropInfoSort[j]['chance'] then
                    local inputName = tempName
                    local inputChance = tempChance
                    tempName = dropInfoSort[j]['name']
                    tempChance = dropInfoSort[j]['chance']
                    --print("tempname="..tempName.."="..tempChance)
                    dropInfoSort[j] = {}
                    dropInfoSort[j]['name'] = inputName
                    dropInfoSort[j]['chance'] = inputChance
                    --print("j="..j..",name="..item_name.."="..chance)
                end
            end  
            i = i + 1
        end
    end
    return dropInfoSort
end

function heroStudyFinish(playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    if hHero:HasModifier("modifier_hero_study_datadriven") then
		hHero:RemoveModifierByName("modifier_hero_study_datadriven")
	end
    EmitAnnouncerSoundForPlayer("scene_voice_round_ability_get",playerID)
end


function getGoldWorthOperation(worth)
    local worthValue = {}
    worthValue["value"] = {0,0,0}
    worthValue["type"] = {0,0,0}
    local bai = math.floor(worth / 100)
    local shi = math.floor((worth % 100) / 10)
    local ge = math.floor(worth % 10)

    if bai > 0 then
        worthValue["value"][1] = bai
        worthValue["value"][2] = shi
        worthValue["value"][3] = ge
        worthValue["type"][1] = 1
        worthValue["type"][2] = 1
        worthValue["type"][3] = 1
    else
        if shi > 0 then
            worthValue["value"][1] = shi
            worthValue["value"][2] = ge
            worthValue["type"][1] = 1
            worthValue["type"][2] = 1
        else
            worthValue["value"][1] = ge
            worthValue["type"][1] = 1
        end
    end
    return worthValue
end

function showGoldWorthParticle(playerID,worth,type)
    local worthValue = getGoldWorthOperation(worth)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    local particleName = "particles/jinbihuoqu.vpcf"
    local soundStr
    local particleID = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, hHero)
    ParticleManager:SetParticleControl(particleID, 0, hHero:GetAbsOrigin())
    ParticleManager:SetParticleControl(particleID, 1, Vector(worthValue["value"][1],worthValue["value"][2],worthValue["value"][3]))
    ParticleManager:SetParticleControl(particleID, 2, Vector(worthValue["type"][1],worthValue["type"][2],worthValue["type"][3]))
    ParticleManager:SetParticleControl(particleID, 3, Vector(worth+5,0,0))
    if worth >= 17 then
        soundStr = "scene_voice_coin_get_big"
    else
        soundStr = "scene_voice_coin_get_small" 
    end
    if type == "team" then
        EmitAnnouncerSoundForPlayer(soundStr, playerID)
    else  
        EmitSoundOn(soundStr, hHero)
    end
end

function blinkOperation(caster, ability, fromParticle, toParticle)

    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local direction = (skillPoint - casterPosition):Normalized()
    local distance = (skillPoint - casterPosition):Length2D()
    local newPosition = skillPoint
    if distance > max_distance then
        newPosition = casterPosition + direction * max_distance
    end
    
    local canWalk = GridNav:CanFindPath(casterPosition,newPosition)
    
    while not canWalk do
        newPosition = newPosition - direction * 10
        canWalk = GridNav:CanFindPath(casterPosition,newPosition)
    end
    caster:MoveToPosition(newPosition + direction * 1)

    local particleFrom = ParticleManager:CreateParticle(fromParticle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particleFrom, 0, caster:GetAbsOrigin())

    FindClearSpaceForUnit( caster, newPosition, false )

    local particleTo = ParticleManager:CreateParticle(toParticle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particleTo, 0, caster:GetAbsOrigin())
    
    return newPosition
end

--是否属于所有类型技能
function heroCheckSkill(caster,unit)
	local isTeamSkill = false

	local casterTeam = caster:GetTeam()
	local unitTeam = unit:GetTeam()
	local label = unit:GetUnitLabel()
	if (unit ~= caster and (label == GameRules.skillLabel or label == GameRules.towerSkillLabel)) then
		isTeamSkill = true
	end
	return isTeamSkill
end

--全技能减冷却
function reduceCooldownAllAbibity(caster, reduceTime)
    for i = 0 , 5, 1 do
        local ability = caster:GetAbilityByIndex(i)
        local cooldownTimeRemaining = ability:GetCooldownTimeRemaining()		
        cooldownTimeRemaining = cooldownTimeRemaining - reduceTime 
        ability:EndCooldown()
        ability:StartCooldown(cooldownTimeRemaining)
        local modifierName = ability:GetAbilityName().."_modifier_cooldown"
        if caster:HasModifier(modifierName) then
            caster:RemoveModifierByName(modifierName)
            caster:AddNewModifier( caster, ability, modifierName, {Duration = cooldownTimeRemaining} )
        end
    end
end

--刷新被动属性
function heroAbilityPassiveInit(hero)
    local keys = {}
    keys.caster = hero

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"vision",GameRules.playerBaseVision) 
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerBuffByNameAndBValue(keys,"mana",GameRules.playerBaseMana)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
    setPlayerBuffByNameAndBValue(keys,"defense",GameRules.playerBaseDefense)

    setPlayerSimpleBuff(keys,"cooldown")
    setPlayerSimpleBuff(keys,"cooldown_percent_final")
    setPlayerSimpleBuff(keys,"range")
    setPlayerSimpleBuff(keys,"range_percent_final")
    setPlayerSimpleBuff(keys,"radius")
    setPlayerSimpleBuff(keys,"radius_percent_final")
end











--测试用
function initTreasureBoxTest()
    local treasureBox1Entities = Entities:FindByName(nil,"treasureBox1") 
    local treasureBox1Location = treasureBox1Entities:GetAbsOrigin()
    --local item_name = 'item_gold_coin_10'
    --local item = CreateItem(item_name, nil, nil)	--handle CreateItem(string item_name, handle owner, handle owner)
    --CreateItemOnPositionSync(treasureBox1Location,item)
    local treasureBox = CreateUnitByName("treasureBoxGold", treasureBox1Location, true, nil, nil, DOTA_TEAM_NOTEAM)
    treasureBox:GetAbilityByIndex(0):SetLevel(1)
    treasureBox:GetAbilityByIndex(1):SetLevel(1)
end

function createUnit(unitName,team)
    --初始化刷怪
    local temp_zuoshang=Entities:FindByName(nil,"zuoshang") --找到左上的实体
    zuoshang_zuobiao=temp_zuoshang:GetAbsOrigin()

    local temp_youxia=Entities:FindByName(nil,"youxia") --找到左上的实体
    youxia_zuobiao=temp_youxia:GetAbsOrigin()

    local temp_x =math.random(youxia_zuobiao.x - zuoshang_zuobiao.x) + zuoshang_zuobiao.x
    local temp_y =math.random(youxia_zuobiao.y - zuoshang_zuobiao.y) + zuoshang_zuobiao.y
    local location = Vector(temp_x, temp_y ,0)

    --[[
    print("team=3"..DOTA_TEAM_BADGUYS)
    print("team=2"..DOTA_TEAM_GOODGUYS)
    print("team=5"..DOTA_TEAM_NOTEAM)
    print("team=4"..DOTA_TEAM_NEUTRALS)]]
    local unit = CreateUnitByName(unitName, location, true, nil, nil, team)
    unit:SetContext("name", unitName, 0)
end

