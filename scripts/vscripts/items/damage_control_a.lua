require('game_init')
require('player_power')
item_damage_control_a = ({})
item_damage_control_a_2 = ({})
item_damage_control_a_3 = ({})
modifier_item_damage_control_a_datadriven = ({})
modifier_item_damage_control_a_2_datadriven = ({})
modifier_item_damage_control_a_3_datadriven = ({})
LinkLuaModifier("modifier_item_damage_control_a_datadriven", "items/damage_control_a.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_a_2_datadriven", "items/damage_control_a.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_a_3_datadriven", "items/damage_control_a.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_damage_control_a:GetIntrinsicModifierName()
	return "modifier_item_damage_control_a_datadriven"
end

function item_damage_control_a_2:GetIntrinsicModifierName()
	return "modifier_item_damage_control_a_2_datadriven"
end


function item_damage_control_a_3:GetIntrinsicModifierName()
	return "modifier_item_damage_control_a_3_datadriven"
end

function modifier_item_damage_control_a_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_a_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_a_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_control_a_2_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_a_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_a_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_control_a_3_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_a_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_a_3_datadriven:OnDestroy()
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
    local item_ability_speed = ability:GetSpecialValueFor("item_ability_speed")
    local item_damage = ability:GetSpecialValueFor("item_damage")   
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")
    local item_speed = ability:GetSpecialValueFor("item_speed")



    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_ability_speed", flag, item_ability_speed)
    setPlayerPower(playerID, "player_damage_d", flag, item_damage)
    setPlayerPower(playerID, "player_damage_c", flag, item_damage)
    setPlayerPower(playerID, "player_damage_b", flag, item_damage)
    setPlayerPower(playerID, "player_damage_a", flag, item_damage)
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)
    setPlayerPower(playerID, "player_speed", flag, item_speed)

    setPlayerSimpleBuff(keys,"cooldown_percent_final")
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end

