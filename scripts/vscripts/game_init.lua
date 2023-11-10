require('scene/battlefield')
require('myMaths')
function initMapStatus()

    --真随机设定
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','') 
    math.randomseed(tonumber(timeTxt))
--[[
    PlayerStats={}
    for i = 0, 9 do
        PlayerStats[i] = {} --每个玩家数据包
        PlayerStats[i]['changdu'] = 0
    end
]]
    --用于记录玩家是否学习，用于启动随机学习
    playerRoundLearn = {}

    TreasureBoxGold = "treasureBoxGold"
 
    --初始化所有玩家的天赋
    playerOrderTimer = {}
    playerContractLearn = {}
    playerTalentLearn = {}
    playerOrderTarget = {}
    playerRandomItemNumList = {}
    playerOrderTimer = {}
    playerShopLock = {}
    playerRefreshCost = {}
    dorpItems = {}
    for i = 0, 9 do
        playerContractLearn[i]={}
        playerContractLearn[i]['contractName'] = 'nil'
        playerTalentLearn[i]={}
        playerTalentLearn[i]['talentNameC'] = 'nil'
        playerTalentLearn[i]['talentNameB'] = 'nil'
        playerTalentLearn[i]['talentNameA'] = 'nil'

        playerOrderTarget[i] = 'nil'
        playerOrderTimer[i] = 1
        playerRandomItemNumList[i] = {}

        playerShopLock[i] = 0
        playerRefreshCost[i] = GameRules.refreshCost
    end

    centerTreasureBox = {}
    otherTreasureBox = {}

    --建立商店
    creatShop()

    --刷怪
    --[[
    for i=1, 8 ,1 do
        createUnit('yang',DOTA_TEAM_BADGUYS)
    end
    ]]

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
end

function initTreasureBox()
    print("=====================initTreasureBox==========================")
    local centerBox = "centerbox"
    local goodBox = "goodbox"
    local badBox = "badbox"
    local centerRandonNumList = getRandomNumList(1, 3, 2)
    local goodRandonNumList = getRandomNumList(1, 6, 3)
    local badRandonNumList = getRandomNumList(1, 6, 3)
    local delayTime = 45
   
    Timers:CreateTimer(delayTime,function ()
        for i = 1, 2 ,1 do
            local centerBoxName = "centerbox"..centerRandonNumList[i]
            local centerBoxEntities = Entities:FindByName(nil,centerBoxName) 
            local centerBox = CreateUnitByName("treasureBoxGold", centerBoxEntities:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
            centerBox:GetAbilityByIndex(0):SetLevel(1)
            centerBox:GetAbilityByIndex(1):SetLevel(1)
            centerBox.alive = 1
            table.insert(centerTreasureBox,centerBox)
        end
        return nil
    end)

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
    local goodSamsaraStone = CreateUnitByName("samsaraStone", goodSamsaraStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    goodSamsaraStone:SetSkin(0)
    goodSamsaraStone:SetAngles(0, 270, 10)
    goodSamsaraStone:GetAbilityByIndex(0):SetLevel(1)
end


--魔法石初始化
function initMagicStone()
    print("=========initHeroStatus============")
    if goodMagicStone ~= nil then
        goodMagicStone:ForceKill(true)
    end

    if goodMagicStonePan ~= nil then
        goodMagicStonePan:ForceKill(true)
    end

    if badMagicStone ~= nil then
        badMagicStone:ForceKill(true)
    end

    if badMagicStonePan ~= nil then
        badMagicStonePan:ForceKill(true)
    end

    local goodMagicStoneEntities = Entities:FindByName(nil,"goodMagicStone") 
    local goodMagicStoneLocation = goodMagicStoneEntities:GetAbsOrigin()
    local goodMagicStonePan = CreateUnitByName("magicStonePan", goodMagicStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    goodMagicStonePan:GetAbilityByIndex(0):SetLevel(1)
    goodMagicStonePan:SetSkin(0)
    goodMagicStone = CreateUnitByName("magicStone", goodMagicStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    goodMagicStone:AddAbility("magic_stone_good")
    goodMagicStone:GetAbilityByIndex(0):SetLevel(1)
    goodMagicStone:SetSkin(0)
    GameRules.goodMagicStone = goodMagicStone
    --goodMagicStone:SetContext("name", "magicStone", 0)
    
    local badMagicStoneEntities = Entities:FindByName(nil,"badMagicStone")
    local badMagicStoneLocation = badMagicStoneEntities:GetAbsOrigin()
    local badMagicStonePan = CreateUnitByName("magicStonePan", badMagicStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    badMagicStonePan:GetAbilityByIndex(0):SetLevel(1)
    badMagicStonePan:SetSkin(1)
    badMagicStone = CreateUnitByName("magicStone", badMagicStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    badMagicStone:AddAbility("magic_stone_bad")
    badMagicStone:GetAbilityByIndex(0):SetLevel(1)
    badMagicStone:SetSkin(1)
    GameRules.badMagicStone = badMagicStone
    --badMagicStone:SetContext("name", "magicStone", 0)
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



    --玩家英雄初始化
function initHeroByPlayerID(playerID)
    --print("initHeroByPlayerID:"..playerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
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
    hHero:AddAbility(commonAttack):SetLevel(1)  --0
    hHero:AddAbility("pull_all_datadriven"):SetLevel(1) --1
    hHero:AddAbility("push_all_datadriven"):SetLevel(1) --2   --  make_friend_datadriven
    hHero:AddAbility("nothing_c"):SetLevel(1) --3
    hHero:AddAbility("nothing_b"):SetLevel(1) --4
    hHero:AddAbility("nothing_a"):SetLevel(1) --5
    hHero:AddAbility("nothing_c_stage"):SetLevel(1) --6
    hHero:AddAbility("nothing_b_stage"):SetLevel(1) --7
    hHero:AddAbility("nothing_a_stage"):SetLevel(1) --8
    hHero:AddAbility("hero_order_datadriven"):SetLevel(1) --9
    hHero:AddAbility('treasure_box_open_datadriven'):SetLevel(1) --10
    hHero:AddAbility('battlefield_capture_datadriven'):SetLevel(1) --11
    hHero:AddAbility("hero_hidden_status_datadriven"):SetLevel(1) --12
    
    --hHero:GetAbilityByIndex(9):SetHidden(true)--也不行
    --hHero:GetAbilityByIndex(10):SetLevel(1)

	hHero:SetTimeUntilRespawn(1) --重新设置复活时间
    
    PlayerResource:SetGold(playerID,60,true)
end


--物品掉落（金币箱打开）
function RollDrops(unit)
	local dropInfoSort = initDropInfo(unit:GetUnitName())
    --print("===========RollDrops=============:"..#dropInfoSort)
    for k = 0 , #dropInfoSort do
        local item_name = dropInfoSort[k]['name']
        local chance = dropInfoSort[k]['chance']
        print("Creating "..item_name.."="..chance)
        if RollPercentage(chance) then
            -- 创建对应的物品
            print("item_name:==========================="..item_name)
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
    print("initDropInfo")
    if dropInfo then
        local i = 0
        for item_name,chance in pairs(dropInfo) do
            local tempName = item_name
            local tempChance = chance
            print("start:"..tempName.."="..tempChance)
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
