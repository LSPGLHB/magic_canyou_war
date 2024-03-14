require('game_init')
require('player_power')
item_cannon_b = ({})
item_cannon_b_2 = ({})
item_cannon_b_3 = ({})
modifier_item_cannon_b_datadriven = ({})
modifier_item_cannon_b_2_datadriven = ({})
modifier_item_cannon_b_3_datadriven = ({})
LinkLuaModifier("modifier_item_cannon_b_datadriven", "items/cannon_b.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_cannon_b_2_datadriven", "items/cannon_b.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_cannon_b_3_datadriven", "items/cannon_b.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_cannon_b:GetIntrinsicModifierName()
	return "modifier_item_cannon_b_datadriven"
end

function item_cannon_b_2:GetIntrinsicModifierName()
	return "modifier_item_cannon_b_2_datadriven"
end

function item_cannon_b_3:GetIntrinsicModifierName()
	return "modifier_item_cannon_b_3_datadriven"
end

function modifier_item_cannon_b_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_b_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_b_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_cannon_b_2_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_b_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_b_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_cannon_b_3_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_b_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_b_3_datadriven:OnDestroy()
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
    
    local item_control_percent_base = ability:GetSpecialValueFor("item_control_percent_base")
    local item_range_percent_base = ability:GetSpecialValueFor("item_range_percent_base") 
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")
    local item_damage = ability:GetSpecialValueFor("item_damage")

    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_range_percent_base", flag, item_range_percent_base)  
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)
    setPlayerPower(playerID, "player_damage_d", flag, item_damage)
    setPlayerPower(playerID, "player_damage_c", flag, item_damage)
    setPlayerPower(playerID, "player_damage_b", flag, item_damage)
    setPlayerPower(playerID, "player_damage_a", flag, item_damage)

    setPlayerSimpleBuff(keys,"range_percent_base")
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")

end

