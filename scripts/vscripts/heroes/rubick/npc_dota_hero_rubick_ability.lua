npc_dota_hero_rubick_ability = ({})
LinkLuaModifier("modifier_rubick_passive", "heroes/rubick/rubick_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_rubick_pull_caster_buff", "heroes/rubick/rubick_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_rubick_pull_target_buff", "heroes/rubick/rubick_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function npc_dota_hero_rubick_ability:GetCastRange(v,t)
    local range = self:GetSpecialValueFor("aoe_radius")
    return range
end

function npc_dota_hero_rubick_ability:GetIntrinsicModifierName()
	return "modifier_rubick_passive"
end

function npc_dota_hero_rubick_ability:OnSpellStart()
    local caster = self:GetCaster()
    --local target = self:GetCursorTarget()
    local ability = self
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
        if (unit.FloatingAirLevel == nil or unit.FloatingAirLevel < 9) and unit:IsHero() and unit ~= caster and unitTeam == casterTeam and unit:IsAlive() then
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
        EmitSoundOn("magic_pull_all", caster)
        EmitSoundOn("magic_pull_push_staff", unitTarget)
        unitTarget.FloatingAirLevel = 9
        local bufferTempDis = 100
        local max_distance =  (caster:GetAbsOrigin() - unitTarget:GetAbsOrigin()):Length2D() - 60
        local direction = (caster:GetAbsOrigin() - unitTarget:GetAbsOrigin()):Normalized()
        local buffTime = max_distance / ability:GetSpecialValueFor("pull_speed")
        local hitTargetDebuff = "modifier_rubick_pull_target_buff"
        unitTarget:AddNewModifier(unitTarget, ability, hitTargetDebuff, {Duration = buffTime})
        local casterBuff = "modifier_rubick_pull_caster_buff"
        caster:AddNewModifier(caster, ability, casterBuff, {Duration = buffTime})
        local interval = 0.02
        local pullSpeed = ability:GetSpecialValueFor("pull_speed") * GameRules.speedConstant * interval
        local traveled_distance = 0
        Timers:CreateTimer(function()
            if traveled_distance < max_distance and unitTarget.FloatingAirLevel == 9 then
                local newPosition = unitTarget:GetAbsOrigin() +  direction * pullSpeed 
                local groundPos = GetGroundPosition(newPosition, unitTarget)
                --中途可穿模，最后不能穿
                local tempLastDis = max_distance - traveled_distance
                if tempLastDis > bufferTempDis then
                    unitTarget:SetAbsOrigin(groundPos)
                else
                    FindClearSpaceForUnit( unitTarget, groundPos, false )
                end
                if tempLastDis < bufferTempDis * 2 then
                    caster:RemoveModifierByName(casterBuff)	
                end
                traveled_distance = traveled_distance + pullSpeed
            else
                unitTarget:RemoveModifierByName(hitTargetDebuff)   
                unitTarget.FloatingAirLevel = nil
                return nil
            end
            return interval
        end)

    else
        ability:EndCooldown()
        ability:StartCooldown(2)
        EmitSoundOn("magic_pull_push_fail",caster)
        local failParticleName = "particles/fasheshibai.vpcf"
        local failParticleID = ParticleManager:CreateParticle(failParticleName, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(failParticleID, 0, caster:GetAbsOrigin())
    end
    
    caster.shootOver = -1
end