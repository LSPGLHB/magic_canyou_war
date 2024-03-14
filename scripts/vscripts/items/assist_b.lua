require('game_init')
require('player_power')
item_assist_b = ({})
item_assist_b_2 = ({})
item_assist_b_3 = ({})
modifier_item_assist_b_datadriven = ({})
modifier_item_assist_b_2_datadriven = ({})
modifier_item_assist_b_3_datadriven = ({})
LinkLuaModifier("modifier_item_assist_b_datadriven", "items/assist_b.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_b_2_datadriven", "items/assist_b.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_b_3_datadriven", "items/assist_b.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_assist_b:GetIntrinsicModifierName()
	return "modifier_item_assist_b_datadriven"
end

function item_assist_b_2:GetIntrinsicModifierName()
	return "modifier_item_assist_b_2_datadriven"
end

function item_assist_b_3:GetIntrinsicModifierName()
	return "modifier_item_assist_b_3_datadriven"
end

function modifier_item_assist_b_datadriven:IsHidden()
	return true
end

function modifier_item_assist_b_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_b_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_assist_b_2_datadriven:IsHidden()
	return true
end

function modifier_item_assist_b_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_b_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_assist_b_3_datadriven:IsHidden()
	return true
end

function modifier_item_assist_b_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_b_3_datadriven:OnDestroy()
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
    
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_mana = ability:GetSpecialValueFor("item_mana")
    local item_cooldown_percent_final = ability:GetSpecialValueFor("item_cooldown_percent_final")
    local item_speed = ability:GetSpecialValueFor("item_speed")

    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana", flag, item_mana)  
    setPlayerPower(playerID, "player_cooldown_percent_final", flag, item_cooldown_percent_final)
    setPlayerPower(playerID, "player_speed", flag, item_speed)

    
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana",GameRules.playerBaseMana)
    setPlayerSimpleBuff(keys,"cooldown_percent_final")
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end

