require('game_init')
require('player_power')
item_damage_control_imprison = ({})
item_damage_control_imprison_2 = ({})
item_damage_control_imprison_3 = ({})
modifier_item_damage_control_imprison_datadriven = ({})
modifier_item_damage_control_imprison_2_datadriven = ({})
modifier_item_damage_control_imprison_3_datadriven = ({})
modifier_item_damage_control_imprison_buff = ({})
LinkLuaModifier("modifier_item_damage_control_imprison_datadriven", "items/damage_control_imprison.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_imprison_2_datadriven", "items/damage_control_imprison.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_imprison_3_datadriven", "items/damage_control_imprison.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_damage_control_imprison_buff", "items/damage_control_imprison.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_damage_control_imprison:GetIntrinsicModifierName()
	return "modifier_item_damage_control_imprison_datadriven"
end

function item_damage_control_imprison_2:GetIntrinsicModifierName()
	return "modifier_item_damage_control_imprison_2_datadriven"
end

function item_damage_control_imprison_3:GetIntrinsicModifierName()
	return "modifier_item_damage_control_imprison_3_datadriven"
end

function modifier_item_damage_control_imprison_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_imprison_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_imprison_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_control_imprison_2_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_imprison_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_imprison_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_damage_control_imprison_3_datadriven:IsHidden()
	return true
end

function modifier_item_damage_control_imprison_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_damage_control_imprison_3_datadriven:OnDestroy()
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
    
    local item_range = ability:GetSpecialValueFor("item_range")
    local item_ability_speed = ability:GetSpecialValueFor("item_ability_speed")
    local item_health = ability:GetSpecialValueFor("item_health")   
    local item_mana_regen = ability:GetSpecialValueFor("item_mana_regen")
    local item_speed = ability:GetSpecialValueFor("item_speed")


    setPlayerPower(playerID, "player_range", flag, item_range)
    setPlayerPower(playerID, "player_ability_speed", flag, item_ability_speed)
    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_mana_regen", flag, item_mana_regen)
    setPlayerPower(playerID, "player_speed", flag, item_speed)

    setPlayerSimpleBuff(keys,"range")
    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"mana_regen",GameRules.playerBaseManaRegen)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
end

function item_damage_control_imprison:OnSpellStart()
    itemImprisonOnSpellStart(self)
end

function item_damage_control_imprison_2:OnSpellStart()
    itemImprisonOnSpellStart(self)
end

function item_damage_control_imprison_3:OnSpellStart()
    itemImprisonOnSpellStart(self)
end

function itemImprisonOnSpellStart(self)
    local caster = self:GetCaster()
    local ability = self
    local duration = ability:GetSpecialValueFor("duration")

    local particleName = "particles/jinguzishen.vpcf"
    local particleImprisonID = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particleImprisonID, 0, caster:GetAbsOrigin())
    caster:AddNewModifier(caster,ability,"modifier_item_damage_control_imprison_buff", {Duration = duration} )
    caster:AddNoDraw()
    caster.isNoDraw = 1
    Timers:CreateTimer(duration,function()
        ParticleManager:DestroyParticle(particleImprisonID , true)
        caster:RemoveNoDraw()
        caster.isNoDraw = 0
    end)

end


function modifier_item_damage_control_imprison_buff:IsBuff()
    return true
end

function modifier_item_damage_control_imprison_buff:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true
	}
	return state
end