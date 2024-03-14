require("player_power")
modifier_morphling_passive = ({})

function modifier_morphling_passive:IsBuff()
    return true
end

function modifier_morphling_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.morphlingPassive = 0
        unit.morphlingPassiveArray = {}
        unit.morphlingPassiveArray["hitAbilityName"] = "npc_dota_hero_morphling_ability"
        unit.morphlingPassiveArray["refreshCount"] = self:GetAbility():GetSpecialValueFor("refresh_count")
        unit.morphlingPassiveArray["modifierName"] = "modifier_morphling_passive"
        unit.morphlingPassiveArray["particlesName"] = "particles/duiboge_beidong.vpcf"
    end
end

function modifier_morphling_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        unit.morphlingPassive = nil
        unit.morphlingPassiveArray["hitAbilityName"] = nil
        unit.morphlingPassiveArray["refreshCount"] = nil
        unit.morphlingPassiveArray["modifierName"] = nil
        unit.morphlingPassiveArray["particlesName"] = nil
    end
end



modifier_morphling_cast_buff = ({})

function modifier_morphling_cast_buff:IsBuff()
    return true
end

function modifier_morphling_cast_buff:GetEffectName()
	return "particles/duiboge_zhudongjihuo.vpcf"
end

function modifier_morphling_cast_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_morphling_cast_buff:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        local stackCount = 1
        unit:SetModifierStackCount("modifier_morphling_cast_buff",unit,stackCount)

        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()  
        refreshMorphlingBuff(keys,true)
    end
end

function modifier_morphling_cast_buff:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshMorphlingBuff(keys,false)
    end
end

function refreshMorphlingBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    
    local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent")
    local damage_up_percent = ability:GetSpecialValueFor("damage_up_percent")
    

    setPlayerPower(playerID, "talent_ability_speed_percent_final", flag, ability_speed_up_percent)
    setPlayerPower(playerID, "talent_damage_d_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_c_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_b_percent_final", flag, damage_up_percent)
    setPlayerPower(playerID, "talent_damage_a_percent_final", flag, damage_up_percent)

end

function modifier_morphling_cast_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ABILITY_START
	}
	return funcs
end

function modifier_morphling_cast_buff:OnAbilityStart(keys)
    if IsServer() and keys.unit == self:GetParent() then
        local unit = self:GetParent()
        local modifierName = "modifier_morphling_cast_buff"
        local stackCount = unit:GetModifierStackCount( modifierName, unit )
        powerUpAbilityCount(unit, modifierName, stackCount, nil, nil)
    end
end