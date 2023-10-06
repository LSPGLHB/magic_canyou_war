require('scene/battlefield')

function initMapStats()

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


    --魔法石初始化
    createMagicStone()

    --宝箱初始化
    createTreasureBox()

    --法阵初始化
    createBattlefield()

    --初始化所有玩家的天赋
    playerContractLearn = {}
    playerTalentLearn = {}
    playerOrderTarget = {}
    playerRandomItemNumList = {}
    playerOrderTimer = {}
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
    end
   

    --刷怪
    for i=1, 8 ,1 do
        createUnit('yang',DOTA_TEAM_BADGUYS)
    end

    --建立商店
    creatShop()
    --createHuohai()
    --CreateHeroForPlayer("niu",-1)

end

function createTreasureBox()
    local treasureBox1Entities = Entities:FindByName(nil,"treasureBox1") 
    local treasureBox1Location = treasureBox1Entities:GetAbsOrigin()
    --local item_name = 'item_gold_coin_10'
    --local item = CreateItem(item_name, nil, nil)	--handle CreateItem(string item_name, handle owner, handle owner)
    --CreateItemOnPositionSync(treasureBox1Location,item)
    local treasureBox = CreateUnitByName("treasureBoxGold", treasureBox1Location, true, nil, nil, DOTA_TEAM_NOTEAM)
    treasureBox:GetAbilityByIndex(0):SetLevel(1)
    treasureBox:GetAbilityByIndex(1):SetLevel(1)

end




--魔法石初始化
function createMagicStone()
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
    goodMagicStone = CreateUnitByName("magicStone", goodMagicStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    goodMagicStone:AddAbility("magic_stone_good")
    goodMagicStone:GetAbilityByIndex(0):SetLevel(1)
    --goodMagicStone:GetAbilityByIndex(1):SetLevel(1)
    goodMagicStone:SetSkin(0)
    goodMagicStone:SetContext("name", "magicStone", 0)
    goodMagicStonePan = CreateUnitByName("magicStonePan", goodMagicStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    goodMagicStonePan:GetAbilityByIndex(0):SetLevel(1)
    goodMagicStonePan:SetSkin(0)
    


    local badMagicStoneEntities = Entities:FindByName(nil,"badMagicStone")
    local badMagicStoneLocation = badMagicStoneEntities:GetAbsOrigin()
    badMagicStone = CreateUnitByName("magicStone", badMagicStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    badMagicStone:AddAbility("magic_stone_bad")
    badMagicStone:GetAbilityByIndex(0):SetLevel(1)
    --badMagicStone:GetAbilityByIndex(1):SetLevel(1)
    badMagicStone:SetSkin(1)
    badMagicStone:SetContext("name", "magicStone", 0)
    badMagicStonePan = CreateUnitByName("magicStonePan", badMagicStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    badMagicStonePan:GetAbilityByIndex(0):SetLevel(1)
    badMagicStonePan:SetSkin(1)
end

-- 商人
function creatShop()
    local shop1=Entities:FindByName(nil,"shop1") 
    local shop1Pos = shop1:GetAbsOrigin()
    local unit = CreateUnitByName("shopUnit", shop1Pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
    unit:SetContext("name", "shop", 0)


    local shop2=Entities:FindByName(nil,"shop2") 
    local shop2Pos = shop2:GetAbsOrigin()
    local unit = CreateUnitByName("shopUnit", shop2Pos, true, nil, nil, DOTA_TEAM_BADGUYS)
    unit:SetContext("name", "shop", 0)
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



function createBaby(playerid)
    local followed_unit=PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']]
    local chaoxiang=followed_unit:GetForwardVector()
    local position=followed_unit:GetAbsOrigin()
    local newposition=position-chaoxiang*100
  
  
    local new_unit = CreateUnitByName("littlebug", newposition, true, nil, nil, followed_unit:GetTeam())
    new_unit:SetForwardVector(chaoxiang)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
       function ()
        new_unit:MoveToNPC(followed_unit)
        return 0.2
       end,0) 
    --new_unit:SetControllableByPlayer(playerid, true)
    PlayerStats[playerid]['group_pointer']=PlayerStats[playerid]['group_pointer']+1
    PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']]=new_unit

  end	

    --玩家英雄初始化
function initHeroByPlayerID(playerID)
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
    if heroTeam == DOTA_TEAM_BADDGUYS then
        commonAttack = "common_attack_bad_datadriven"
    end
    --local tempAbility = hHero:GetAbilityByIndex(0):GetAbilityName()
    --hHero:RemoveAbility(tempAbility) 
    hHero:AddAbility(commonAttack):SetLevel(1)
    hHero:AddAbility("pull_all_datadriven"):SetLevel(1)
    hHero:AddAbility("push_all_datadriven"):SetLevel(1)
    hHero:AddAbility("nothing_c"):SetLevel(1)
    hHero:AddAbility("nothing_b"):SetLevel(1)
    hHero:AddAbility("nothing_a"):SetLevel(1)
    hHero:AddAbility("nothing_c_stage"):SetLevel(1)
    hHero:AddAbility("nothing_b_stage"):SetLevel(1)
    hHero:AddAbility("nothing_a_stage"):SetLevel(1)
    hHero:AddAbility("hero_order_datadriven"):SetLevel(1)
    hHero:AddAbility('treasure_box_open_datadriven'):SetLevel(1)
    hHero:AddAbility('battlefield_capture_datadriven'):SetLevel(1)
    


    --hHero:GetAbilityByIndex(9):SetHidden(true)--也不行
    --hHero:GetAbilityByIndex(10):SetLevel(1)

	hHero:SetTimeUntilRespawn(999) --重新设置复活时间
end


--死亡物品掉落
function RollDrops(unit)
	initDropInfo(unit)

    for k = 0 , #DropInfoSort do
        local item_name = DropInfoSort[k]['name']
        local chance = DropInfoSort[k]['chance']
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
        for item_name,chance in pairs(DropInfoSort) do
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

function initDropInfo(unit)
    -- 读取上面读取的掉落KV文件，然后读取到对应的单位的定义文件
    local DropInfo = GameRules.DropTable[unit:GetUnitName()]
    DropInfoSort = {}
    
    if DropInfo then
        local i = 0
        for item_name,chance in pairs(DropInfo) do
            local tempName = item_name
            local tempChance = chance
            --print("start:"..tempName.."="..tempChance)
            for j = 0 , i do  
                if j == i then
                    DropInfoSort[i] = {}
                    DropInfoSort[i]['name'] = tempName
                    DropInfoSort[i]['chance'] = tempChance
                    --print("i="..i..",name="..tempName.."="..tempChance)
                    break;
                end
                    --print("check:"..tempChance..'<'..DropInfoSort[j]['chance'])
                if tempChance < DropInfoSort[j]['chance'] then
                    local inputName = tempName
                    local inputChance = tempChance
                    tempName = DropInfoSort[j]['name']
                    tempChance = DropInfoSort[j]['chance']
                    --print("tempname="..tempName.."="..tempChance)
                    DropInfoSort[j] = {}
                    DropInfoSort[j]['name'] = inputName
                    DropInfoSort[j]['chance'] = inputChance
                    --print("j="..j..",name="..item_name.."="..chance)
                end

            end  
            i = i + 1
        end
    end

end


--[[
function initGoldCoin()

	goldCoin = {}
    local i = 0
	for key, value in pairs(GameRules.goldCoin) do
        goldCoin[i]={}
        goldCoin[i]['name'] = key
		for k,v in pairs(value) do
            if k == 'Holder' then
                goldCoin[i]['holder'] = v
            end
            if k == 'Worth' then
                goldCoin[i]['worth'] = v
            end
		end
        i = i + 1
	end
end]]

