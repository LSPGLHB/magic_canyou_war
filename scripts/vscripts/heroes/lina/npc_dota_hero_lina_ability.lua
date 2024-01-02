require('myMaths')
npc_dota_hero_lina_ability = ({})
LinkLuaModifier("modifier_observe_buff", "heroes/lina/observe_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
function npc_dota_hero_lina_ability:OnSpellStart()
--function abilityOnSpellStart(keys)
    local caster = self:GetCaster()
    local ability = self
    --local caster = keys.caster
    --local ability = keys.ability
    local casterTeam = caster:GetTeam()
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local duration = ability:GetSpecialValueFor("duration")
    local ability_speed_down_percent = ability:GetSpecialValueFor("ability_speed_down_percent")
    local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent")
    
    local face_angle = ability:GetSpecialValueFor("face_angle")
    local particleName = "particles/guanchage.vpcf"
    local particleID = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particleID, 1, Vector(aoe_radius, 0, 0)) 
    local modifierName = "modifier_observe_buff"
    caster:AddNewModifier(caster, ability, modifierName, {Duration = duration})
    --ability:ApplyDataDrivenModifier(caster, caster, modifierName, {Duration = duration})

    local allUnits = {}
    local interval = 0.02
    Timers:CreateTimer(function()
        if interval == -1 then
            for _, value in ipairs(allUnits) do
                value.speed = value.saveSpeed
                --print("over"..value.speed)
            end
            return nil
        end
        local casterLocation = caster:GetAbsOrigin()
        local aroundUnits = FindUnitsInRadius(casterTeam, 
                                            casterLocation,
                                            nil,
                                            aoe_radius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)
        local newAllUnits = {}
        for _, unit in pairs(aroundUnits) do
            if unit.owner ~= nil then
                local ownerID = unit.owner:GetPlayerID()
                local casterID = caster:GetPlayerID()
                --print("ID:"..ownerID.."+-+"..casterID)
                if unit:GetUnitLabel() == GameRules.skillLabel and unit.energy_point > 0 and ownerID == casterID then     
                    table.insert(newAllUnits, unit)                 
                    local isFace = isFaceByFaceAngle(unit, caster, face_angle)
                    --local faceFlag = false
                    --local backFlag = false
                    local newFlag = false
                    if unit.saveSpeed == nil then
                        unit.saveSpeed = unit.speed
                        newFlag = true
                    end
                    if isFace then
                        if unit.saveSpeed ~= nil and unit.saveSpeed >= unit.speed then
                            unit.speed = unit.saveSpeed * (1 + ability_speed_up_percent/100)
                            --print("upupup"..unit.speed)
                        end                       
                    end
                    if not isFace then
                        if unit.saveSpeed ~= nil and unit.saveSpeed <= unit.speed then
                            unit.speed = unit.saveSpeed * (1 + ability_speed_down_percent/100)
                            --print("down"..unit.speed)
                        end
                    end
                end
            end
        end
        --离开圈则恢复速度
        refreshNewArrayByOldArray(allUnits,newAllUnits)
        allUnits = newAllUnits
        return interval
    end)

    Timers:CreateTimer(duration,function()
        ParticleManager:DestroyParticle(particleID, true)
        interval = -1
    end)
end

function refreshNewArrayByOldArray(oldArray,newArray)
    for i = 1, #oldArray do
        local flag = true
        for j = 1, #newArray do
            if oldArray[i] == newArray[j] then
                flag = false
            end
        end
        if flag and oldArray[i].energy_point > 0 then
            oldArray[i].speed = oldArray[i].saveSpeed
            --print("ret"..oldArray[i].speed)
        end
    end
end



