npc_dota_hero_crystal_maiden_ability = ({})
LinkLuaModifier("modifier_crystal_maiden_passive", "heroes/crystal_maiden/cleanse_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_crystal_maiden_control_up_passive", "heroes/crystal_maiden/cleanse_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_crystal_maiden_speed_up_passive", "heroes/crystal_maiden/cleanse_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function npc_dota_hero_crystal_maiden_ability:GetCastRange(v,t)
    local range = self:GetSpecialValueFor("aoe_radius")
    return range
end

function npc_dota_hero_crystal_maiden_ability:GetIntrinsicModifierName()
	return "modifier_crystal_maiden_passive"
end

function npc_dota_hero_crystal_maiden_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    local durationSpeedUp = ability:GetSpecialValueFor("speed_up_duration")
    local modifierSpeedUpCast = "modifier_crystal_maiden_speed_up_passive"
    caster:AddNewModifier(caster, ability, modifierSpeedUpCast, {Duration = durationSpeedUp})

    local durationControlUp = ability:GetSpecialValueFor("control_up_duration")
    local modifierControlUpCast= "modifier_crystal_maiden_control_up_passive"
    caster:AddNewModifier(caster, ability, modifierControlUpCast, {Duration = durationControlUp})

    caster:Purge( false, true, false, true, false )

    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterLocation = caster:GetAbsOrigin()
    local casterTeam = caster:GetTeam()

    local unitTarget
    local targetDistance = 0
    local hasDebuff = false
    
    local aroundUnits = FindUnitsInRadius(casterTeam, 
                                    casterLocation,
                                    nil,
                                    aoe_radius,
                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                    DOTA_UNIT_TARGET_ALL,
                                    0,
                                    0,
                                    false)
    
    for _, unit in pairs(aroundUnits) do
        local unitTeam = unit:GetTeam()
        local refreshFlag = false
        if unit:IsHero() and unit ~= caster and unitTeam == casterTeam and unit:IsAlive() then
            local distance = (unit:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
            local unitModifies = unit:FindAllModifiers()
            local debuffFlag = false
            for _, mod in pairs(unitModifies) do
                local modName = mod:GetName()
                local debuffPos = modName:find("debuff")
                if debuffPos ~= nil then
                    debuffFlag = true 
                end
            end
            if unitTarget == nil then
                unitTarget = unit
                targetDistance = distance
                hasDebuff = debuffFlag
            end
            if hasDebuff == false then
                if debuffFlag == false and targetDistance > distance then
                    refreshFlag = true
                end
                if debuffFlag == true then
                    refreshFlag = true
                    hasDebuff = true
                end
            else
                if debuffFlag == true and targetDistance > distance then
                    refreshFlag = true
                    hasDebuff = true
                end
            end

            if refreshFlag then
                unitTarget = unit
                targetDistance = distance
            end

        end
    end

    if unitTarget ~= nil then
        unitTarget:Purge( false, true, false, true, false )
        unitTarget:AddNewModifier(unitTarget, ability, modifierSpeedUpCast, {Duration = durationSpeedUp})
        unitTarget:AddNewModifier(unitTarget, ability, modifierControlUpCast, {Duration = durationControlUp})
    end
    caster.shootOver = -1
end
