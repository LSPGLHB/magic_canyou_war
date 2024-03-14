require('game_init')
require('shoot_init')
require('player_power')
item_cannon_push = ({})
item_cannon_push_2 = ({})
item_cannon_push_3 = ({})
modifier_item_cannon_push_datadriven = ({})
modifier_item_cannon_push_2_datadriven = ({})
modifier_item_cannon_push_3_datadriven = ({})
LinkLuaModifier("modifier_item_cannon_push_datadriven", "items/cannon_push.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_cannon_push_2_datadriven", "items/cannon_push.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_push_over", "magic/modifiers/modifier_beat_back.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_cannon_push:GetIntrinsicModifierName()
	return "modifier_item_cannon_push_datadriven"
end

function item_cannon_push_2:GetIntrinsicModifierName()
	return "modifier_item_cannon_push_2_datadriven"
end

function item_cannon_push_3:GetIntrinsicModifierName()
	return "modifier_item_cannon_push_3_datadriven"
end

function modifier_item_cannon_push_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_push_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_push_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_cannon_push_2_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_push_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_push_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_cannon_push_3_datadriven:IsHidden()
	return true
end

function modifier_item_cannon_push_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_cannon_push_3_datadriven:OnDestroy()
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
    
    local item_radius_percent_base = ability:GetSpecialValueFor("item_radius_percent_base")
    local item_control_percent_base = ability:GetSpecialValueFor("item_control_percent_base")
    local item_health = ability:GetSpecialValueFor("item_health")
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")
    local item_speed = ability:GetSpecialValueFor("item_speed")


    setPlayerPower(playerID, "player_radius_percent_base", flag, item_radius_percent_base)
    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)
    setPlayerPower(playerID, "player_speed", flag, item_speed)

    setPlayerSimpleBuff(keys,"radius_percent_base")
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)

end

function item_cannon_push:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_cannon_push:OnSpellStart()
    cannonPush(self)
end

function item_cannon_push_2:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_cannon_push_2:OnSpellStart()
    cannonPush(self)
end

function item_cannon_push_3:GetCastRange(v,t)
    local range = getRangeByName(self,'item')
    return range
end

function item_cannon_push_3:OnSpellStart()
    cannonPush(self)
end

function cannonPush(self)
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local ability = self
    local keys = {}
    keys.caster = caster
    keys.ability = ability
    keys.hitTargetDebuff = "modifier_push_over"
	--keys.hitDisableTurning = "modifier_disable_turning"
    local beatBackDistance = ability:GetSpecialValueFor("push_distance")
    local beatBackSpeed = beatBackDistance / ability:GetSpecialValueFor("duration")
    local beatBackDirection = target:GetForwardVector()
    beatBackUnit(keys,nil,target,beatBackSpeed,beatBackDistance,beatBackDirection,"null",false)
end