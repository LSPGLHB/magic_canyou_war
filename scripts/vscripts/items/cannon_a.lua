require('game_init')
require('player_power')
item_cannon_a = ({})
item_cannon_a_2 = ({})
item_cannon_a_3 = ({})
modifier_item_cannon_a_datadriven = ({})
modifier_item_cannon_a_2_datadriven = ({})
modifier_item_cannon_a_3_datadriven = ({})
LinkLuaModifier("modifier_item_cannon_a_datadriven", "items/cannon_a.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_cannon_a_2_datadriven", "items/cannon_a.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_cannon_a_3_datadriven", "items/cannon_a.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_cannon_a:GetIntrinsicModifierName()
	return "modifier_item_cannon_a_datadriven"
end

function item_cannon_a_2:GetIntrinsicModifierName()
	return "modifier_item_cannon_a_2_datadriven"
end

function item_cannon_a_3:GetIntrinsicModifierName()
	return "modifier_item_cannon_a_3_datadriven"
end

function modifier_item_cannon_a_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_a_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_a_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_cannon_a_2_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_a_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_a_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_cannon_a_3_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_a_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_a_3_datadriven:OnDestroy()
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
    
    local item_range_percent_base = ability:GetSpecialValueFor("item_range_percent_base")
    local item_radius_percent_base = ability:GetSpecialValueFor("item_radius_percent_base")
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")

    setPlayerPower(playerID, "player_range_percent_base", flag, item_range_percent_base)
    setPlayerPower(playerID, "player_radius_percent_base", flag, item_radius_percent_base)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)

    setPlayerSimpleBuff(keys,"range_percent_base")
    setPlayerSimpleBuff(keys,"radius_percent_base")
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")

end

