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
   

    --刷怪
    for i=1, 8 ,1 do
        createUnit('yang',DOTA_TEAM_NOTEAM)
    end
    
   



    creatShop()
    --createHuohai()
    --CreateHeroForPlayer("niu",-1)

end

-- 模拟商人
function creatShop()
    local shop1=Entities:FindByName(nil,"shop1") 
    local shop1Pos = shop1:GetAbsOrigin()
    local unit = CreateUnitByName("shopUnit", shop1Pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
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
--[[
function createShoot(keys)
    for k,v in pairs(keys) do
        print("keys:",k,v)
    end
    local unit = keys.unit --EntIndexToHScript(keys.unit)
    local chaoxiang=unit:GetForwardVector()
    local position=unit:GetAbsOrigin()
    --local tempposition=position+chaoxiang*50
    local new_unit = CreateUnitByName("huoren", position, true, nil, nil, unit:GetTeam())
    new_unit:SetForwardVector(chaoxiang)
    GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
     function ()
      new_unit:MoveToPosition(position+chaoxiang*500)
      return 0.2
     end,0) 
end
]]
