require('game_init')
require('player_power')
item_damage_d = ({})
item_damage_d_2 = ({})
item_damage_d_3 = ({})
modifier_item_damage_d_datadriven = ({})
modifier_item_damage_d_2_datadriven = ({})
modifier_item_damage_d_3_datadriven = ({})
LinkLuaModifier("modifier_item_damage_d_datadriven", "items/damage_d.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_d_2_datadriven", "items/damage_d.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_d_3_datadriven", "items/damage_d.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_damage_d:GetIntrinsicModifierName()
	return "modifier_item_damage_d_datadriven"
end


function item_damage_d_2:GetIntrinsicModifierName()
	return "modifier_item_damage_d_2_datadriven"
end

function item_damage_d_3:GetIntrinsicModifierName()
	return "modifier_item_damage_d_3_datadriven"
end


function modifier_item_damage_d_datadriven:IsHidden()
	return true
end

function modifier_item_damage_d_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_d_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_d_2_datadriven:IsHidden()
	return true
end

function modifier_item_damage_d_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_d_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_d_3_datadriven:IsHidden()
	return true
end

function modifier_item_damage_d_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_d_3_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end


function refreshItemBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local item_damage_percent_base = ability:GetSpecialValueFor("item_damage_percent_base")
    local item_range = ability:GetSpecialValueFor("item_range")
    local item_health = ability:GetSpecialValueFor("item_health")   
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")

    
    setPlayerPower(playerID, "player_damage_d_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_damage_c_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_damage_b_percent_base", flag, item_damage_percent_base)
    setPlayerPower(playerID, "player_damage_a_percent_base", flag, item_damage_percent_base)

    setPlayerPower(playerID, "player_range", flag, item_range)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)

    setPlayerSimpleBuff(keys,"range")
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)

end

function item_damage_d:OnSpellStart()
    itemDamageDCooldownOnSpellStart(self)
end

function item_damage_d_2:OnSpellStart()
    itemDamageDCooldownOnSpellStart(self)
end

function item_damage_d_3:OnSpellStart()
    itemDamageDCooldownOnSpellStart(self)
end

function itemDamageDCooldownOnSpellStart(self)
    local caster = self:GetCaster()
    local ability = self
    local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
    reduceCooldownAllAbibity(caster, cooldown_reduce)
end