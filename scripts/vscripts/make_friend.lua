function createFriend(keys)
    local caster = keys.caster
    local unit = keys.unit --EntIndexToHScript(keys.unit)
    local chaoxiang=unit:GetForwardVector()
    local position=unit:GetAbsOrigin() + chaoxiang * 500
    local position2 = caster:GetAbsOrigin()

    local player = caster:GetPlayerOwnerID()
    --local tempposition=position+chaoxiang*50
    --print("GetTeam:"..unit:GetTeam())
    local new_unit = CreateUnitByName("huoren", position, true, nil, nil, unit:GetTeam())-- DOTA_TEAM_BADGUYS)--
    new_unit:SetControllableByPlayer(player, true)
    new_unit:SetForwardVector(chaoxiang)
    new_unit:SetPlayerID(caster:GetPlayerID())
    new_unit:SetSkin(1)
    --print("1:",ACT_DOTA_LOADOUT_RATE)
    --print("2:",ACT_DOTA_LOADOUT)
    --print("3:",ACT_DOTA_RUN)
    --[[
    local i = 1000
    Timers:CreateTimer(0,function()
        print ("i=",i)
        new_unit:StartGesture(i)
        if i < 9999 then
            i = i + 1
        end
        return 0.1
    end)
   ]]

    
    local new_unit2 = CreateUnitByName("huoren", position, true, nil, nil, DOTA_TEAM_BADGUYS)--
    new_unit2:SetControllableByPlayer(player, true)
    new_unit2:SetForwardVector(chaoxiang)
    new_unit2:SetPlayerID(caster:GetPlayerID())

end