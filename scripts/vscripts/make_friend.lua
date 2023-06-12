function createFriend(keys)
    local caster = keys.caster
    local unit = keys.unit --EntIndexToHScript(keys.unit)
    local chaoxiang=unit:GetForwardVector()
    local position=unit:GetAbsOrigin() + chaoxiang * 100
    local player = caster:GetPlayerOwnerID()
    --local tempposition=position+chaoxiang*50
    --print("GetTeam:"..unit:GetTeam())
    local new_unit = CreateUnitByName("huoren", position, true, nil, nil, unit:GetTeam())-- DOTA_TEAM_BADGUYS)--
    new_unit:SetControllableByPlayer(player, true)
    new_unit:SetForwardVector(chaoxiang)
    new_unit:SetPlayerID(caster:GetPlayerID())

    local new_unit2 = CreateUnitByName("huoren", position, true, nil, nil, DOTA_TEAM_BADGUYS)--
    new_unit2:SetControllableByPlayer(player, true)
    new_unit2:SetForwardVector(chaoxiang)
    new_unit2:SetPlayerID(caster:GetPlayerID())
end