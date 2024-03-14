require('player_power')
modifier_invoker_passive_permanent = ({})
function modifier_invoker_passive_permanent:IsHidden()
    return true
end
function modifier_invoker_passive_permanent:OnCreated()
    if IsServer() then
        --local caster = self:GetCaster()
        local unit = self:GetParent()
        local ability = self:GetAbility()
        unit.invokerPassivePermanent = {}
        unit.invokerPassivePermanent["abilitySpeedUpPercent"] = ability:GetSpecialValueFor("passive_ability_speed_up_percent")
        --unit.invokerPassivePermanent["rangeUpPercent"] = ability:GetSpecialValueFor("passive_range_up_percent")
        unit.invokerPassivePermanent["radiusUpPercent"] = ability:GetSpecialValueFor("passive_radius_up_percent")
        unit.invokerPassivePermanent["particlesName"] = "particles/yuansudashi_beidong.vpcf"

    end
end


modifier_invoker_passive = ({})
--搜索自家碰撞减CD
function modifier_invoker_passive:GetEffectName()
	return "particles/yuansudashi_zhudong.vpcf"
end

function modifier_invoker_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
function modifier_invoker_passive:OnCreated()
    if IsServer() then
        local unit = self:GetParent()
        unit.invokerPassive = true
        unit.invokerRestrainEneryToPercent = self:GetAbility():GetSpecialValueFor("restrain_energy_reduce_to")
        --print(self:GetAbility():GetSpecialValueFor("restrain_energy_reduce_to"))
        local keys = {}
        keys.caster = unit
        keys.ability = self:GetAbility()
        refreshInvokerBuff(keys,true)
        EmitSoundOn("scene_voice_invoker_cast",unit)
    end
end

function modifier_invoker_passive:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        unit.invokerPassive = false
        local keys = {}
        keys.caster = unit
        keys.ability = self:GetAbility()
        refreshInvokerBuff(keys,false)
    end
end

function refreshInvokerBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local range_up_percent = ability:GetSpecialValueFor("range_up_percent")
    local radius_up_percent = ability:GetSpecialValueFor("radius_up_percent")


    setPlayerPower(playerID, "talent_range_percent_final", flag, range_up_percent)
    setPlayerPower(playerID, "talent_radius_percent_final", flag, radius_up_percent)

    setPlayerSimpleBuff(keys,"range_percent_final")
    setPlayerSimpleBuff(keys,"radius_percent_final")

end

function modifier_invoker_passive:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ABILITY_START
	}
	return funcs
end

function modifier_invoker_passive:OnAbilityStart(keys)
    if IsServer() and keys.unit == self:GetParent() then
        local unit = self:GetParent()
        --print("ability"..ability:GetName())
        local modifierName = "modifier_invoker_passive"
        local count = 1
        powerUpAbilityCount(unit, modifierName, count, funcA, nil)    
    end
end

function funcA(unit)
    local modifierInvokerCooldownPassive= "npc_dota_hero_invoker_ability_modifier_cooldown"
    local ability = unit:FindAbilityByName("npc_dota_hero_invoker_ability")
    local cooldown = ability:GetSpecialValueFor("cooldown")
    
    local modifierNameBase = "modifier_cooldown_buff"
	local cooldownBonus = 0
	local modifierNameFinalPercent = "modifier_cooldown_percent_final_buff"
	local cooldownBonusPercent = 0
	if unit:HasModifier(modifierNameBase) then
		cooldownBonus = unit:GetModifierStackCount(modifierNameBase,unit)
	end
	if unit:HasModifier(modifierNameFinalPercent) then
		cooldownBonusPercent = unit:GetModifierStackCount(modifierNameFinalPercent,unit)
	end

    cooldown = (cooldown - cooldownBonus) * (1 - cooldownBonusPercent / 100)

    unit:AddNewModifier(unit, ability, modifierInvokerCooldownPassive, {Duration = cooldown})
    ability:StartCooldown(cooldown)
end


npc_dota_hero_invoker_ability_modifier_cooldown = ({})

function npc_dota_hero_invoker_ability_modifier_cooldown:IsDebuff()
    return true
end

function npc_dota_hero_invoker_ability_modifier_cooldown:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        local ability = unit:FindAbilityByName("npc_dota_hero_invoker_ability")
        local modifierInvokerPassive= "modifier_invoker_passive"
        unit:AddNewModifier(unit, ability, modifierInvokerPassive, {Duration = -1})
    end
end


--modifier_invoker_stage_b_passive = ({})