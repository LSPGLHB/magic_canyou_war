require('shoot_init')
npc_dota_hero_invoker_ability = ({})
npc_dota_hero_invoker_ability_stage_b = ({})
LinkLuaModifier("modifier_invoker_passive_permanent", "heroes/invoker/invoker_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_invoker_passive", "heroes/invoker/invoker_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("npc_dota_hero_invoker_ability_modifier_cooldown", "heroes/invoker/invoker_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
--LinkLuaModifier("modifier_invoker_stage_b_passive", "heroes/invoker/invoker_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)


function npc_dota_hero_invoker_ability:OnUpgrade()
    local caster = self:GetCaster()
    Timers:CreateTimer(1,function()
        caster:AddAbility("npc_dota_hero_invoker_ability_stage_b"):SetLevel(1)
    end)
end

function npc_dota_hero_invoker_ability:GetIntrinsicModifierName()
	return "modifier_invoker_passive"
end

function npc_dota_hero_invoker_ability_stage_b:GetIntrinsicModifierName()
	return "modifier_invoker_passive_permanent"
end


function npc_dota_hero_invoker_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    
    local ability_a_name = "npc_dota_hero_invoker_ability"
    local ability_b_name = "npc_dota_hero_invoker_ability_stage_b"
    caster:SwapAbilities( ability_a_name, ability_b_name, false, true )

    local modifierInvokerPassive= "modifier_invoker_passive"
    caster:RemoveModifierByName(modifierInvokerPassive)

    caster.shootOver = -1
end

function npc_dota_hero_invoker_ability_stage_b:OnSpellStart()
    local caster = self:GetCaster()
    local ability_a_name = "npc_dota_hero_invoker_ability"
    local ability_b_name = "npc_dota_hero_invoker_ability_stage_b"
    caster:SwapAbilities( ability_a_name, ability_b_name, true, false )

    local modifierInvokerCooldownPassive = "npc_dota_hero_invoker_ability_modifier_cooldown"
    if not caster:HasModifier(modifierInvokerCooldownPassive) then
        local modifierInvokerPassive= "modifier_invoker_passive"
        local ability = caster:FindAbilityByName(ability_a_name)
        caster:AddNewModifier(caster, ability, modifierInvokerPassive, {Duration = -1})
    end
    caster.shootOver = -1
end

