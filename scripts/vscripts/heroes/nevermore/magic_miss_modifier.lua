require('player_power')
--主动技能，英雄加速
modifier_nevermore_speed_up_cast = ({})
function modifier_nevermore_speed_up_cast:IsBuff()
	return true
end

function modifier_nevermore_speed_up_cast:GetEffectName()
	return "particles/shenfage.vpcf"
end

function modifier_nevermore_speed_up_cast:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_nevermore_speed_up_cast:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_nevermore_speed_up_cast:GetModifierMoveSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("cast_speed_up")
end

--英雄加速，闪避预备状态
modifier_nevermore_speed_up_passive = ({})
function modifier_nevermore_speed_up_passive:IsDebuff()
	return true
end

function modifier_nevermore_speed_up_passive:GetEffectName()
	return "particles/shenfage_beidong.vpcf"
end

function modifier_nevermore_speed_up_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_nevermore_speed_up_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_nevermore_speed_up_passive:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("passive_speed_up_percent")
end

function modifier_nevermore_speed_up_passive:OnTakeDamage(keys)
    local unit = self:GetParent()
    if IsServer() and keys.unit == unit then
        unit.missBuffFlag = false
        missCount = 0
        --print("missCount:"..missCount)
        unit:SetModifierStackCount("modifier_nevermore_miss_passive",unit,missCount)
        unit:RemoveModifierByName("modifier_nevermore_speed_up_passive")
    end
end

function modifier_nevermore_speed_up_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.missBuffFlag = true
        EmitSoundOn("scene_voice_nevermore_passive",unit)
    end
end

function modifier_nevermore_speed_up_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        local ability = self:GetAbility()
        if unit.missBuffFlag then
            local miss_times = ability:GetSpecialValueFor("miss_times")
            local miss_ability_power_up_duration = ability:GetSpecialValueFor("miss_ability_power_up_duration")
            missCount = missCount + 1
            if missCount == miss_times then
                missCount = 0
                unit:AddNewModifier(unit, ability, "modifier_nevermore_strike_passive", {Duration = miss_ability_power_up_duration})
            end
            --print("missCount:"..missCount)
            unit:SetModifierStackCount("modifier_nevermore_miss_passive",unit,missCount)
        end
    end
end


--被动常驻，搜索技能，添加闪避预备状态
modifier_nevermore_miss_passive = ({})
missCount = 0

function modifier_nevermore_miss_passive:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
        local casterTeam = caster:GetTeam()
        intervalNeverMorePassive = 0.02
        Timers:CreateTimer(function()
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
            for _, unit in pairs(aroundUnits) do
                local unitTeam = unit:GetTeam()
                local targetLabel = unit:GetUnitLabel()
                local modifierName = "modifier_nevermore_speed_up_passive"
                local duration = ability:GetSpecialValueFor("passive_speed_up_duration")
                
                if targetLabel == GameRules.skillLabel and unit.energy_point ~= 0 and unitTeam ~= casterTeam and not caster:HasModifier(modifierName) and unit:IsAlive() then
                    --print("modifier_nevermore_speed_up_passive")
                    caster:AddNewModifier(caster, ability, modifierName, {Duration = duration})
                end
            end
            return intervalNeverMorePassive
        end)
    end
end

function modifier_nevermore_miss_passive:OnDestroy()
    if IsServer() then
        intervalNeverMorePassive = nil
    end
end

--强袭buff
modifier_nevermore_strike_passive = ({})
function modifier_nevermore_strike_passive:GetEffectName()
	return "particles/shenfage_beidong2.vpcf"
end

function modifier_nevermore_strike_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function modifier_nevermore_strike_passive:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local unit = self:GetParent()
        local playerID = unit:GetPlayerID()
        local interval = 0.02
        local nevermoreStrikeCount = 2
        unit:SetModifierStackCount("modifier_nevermore_strike_passive",unit,nevermoreStrikeCount)
        EmitSoundOn("scene_voice_nevermore_passive",unit)
        local keys = {}
        keys.caster = unit
        keys.ability = self:GetAbility()
        refreshNeverMoreMissBuff(keys,true)
    end
end

function modifier_nevermore_strike_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshNeverMoreMissBuff(keys,false)
    end
end

function refreshNeverMoreMissBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local miss_ability_speed_up_percent = ability:GetSpecialValueFor("miss_ability_speed_up_percent")
    local miss_ability_damage_percent = ability:GetSpecialValueFor("miss_ability_damage_percent")
    local miss_ability_control_percent = ability:GetSpecialValueFor("miss_ability_control_percent")

    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, miss_ability_speed_up_percent)
    setPlayerPower(playerID, "talent_control_percent_final", flag, miss_ability_control_percent)

    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, miss_ability_damage_percent)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, miss_ability_damage_percent)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, miss_ability_damage_percent)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, miss_ability_damage_percent)
end

function modifier_nevermore_strike_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ABILITY_START
	}
	return funcs
end

function modifier_nevermore_strike_passive:OnAbilityStart(keys)
    if IsServer() and keys.unit == self:GetParent() then
        local unit = self:GetParent()
        local modifierName = "modifier_nevermore_strike_passive"
        local nevermoreStrikeCount = unit:GetModifierStackCount( modifierName, unit )
        powerUpAbilityCount(unit, modifierName, nevermoreStrikeCount, nil, nil)
    end
end


