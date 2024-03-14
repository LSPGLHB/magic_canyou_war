require('game_init')
require('player_power')
item_assist_hpregen = ({})
item_assist_hpregen_2 = ({})
item_assist_hpregen_3 = ({})
modifier_item_assist_hpregen_datadriven = ({})
modifier_item_assist_hpregen_2_datadriven = ({})
modifier_item_assist_hpregen_3_datadriven = ({})
modifier_item_assist_hpregen_buff = ({})
LinkLuaModifier("modifier_item_assist_hpregen_datadriven", "items/assist_hpregen.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_hpregen_2_datadriven", "items/assist_hpregen.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_hpregen_3_datadriven", "items/assist_hpregen.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_item_assist_hpregen_buff", "items/assist_hpregen.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function item_assist_hpregen:GetIntrinsicModifierName()
	return "modifier_item_assist_hpregen_datadriven"
end


function item_assist_hpregen_2:GetIntrinsicModifierName()
	return "modifier_item_assist_hpregen_2_datadriven"
end

function item_assist_hpregen_3:GetIntrinsicModifierName()
	return "modifier_item_assist_hpregen_3_datadriven"
end

function modifier_item_assist_hpregen_datadriven:IsHidden()
	return true
end

function modifier_item_assist_hpregen_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_hpregen_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_assist_hpregen_2_datadriven:IsHidden()
	return true
end

function modifier_item_assist_hpregen_2_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_hpregen_2_datadriven:OnDestroy()
    if IsServer() then
        print("OnDestroy")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,false)
    end
end

function modifier_item_assist_hpregen_3_datadriven:IsHidden()
	return true
end

function modifier_item_assist_hpregen_3_datadriven:OnCreated()
    if IsServer() then
        print("OnCreated")
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshItemBuff(keys,true)
    end 
end

function modifier_item_assist_hpregen_3_datadriven:OnDestroy()
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
    local item_control_percent_base = ability:GetSpecialValueFor("item_control_percent_base")
    local item_speed = ability:GetSpecialValueFor("item_speed")

    setPlayerPower(playerID, "player_health", flag, item_health)
    setPlayerPower(playerID, "player_control_percent_base", flag, item_control_percent_base)
    setPlayerPower(playerID, "player_speed", flag, item_speed)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)

end

function item_assist_hpregen:OnSpellStart()
    itemHPRegenOnSpellStart(self)
end

function item_assist_hpregen_2:OnSpellStart()
    itemHPRegenOnSpellStart(self)
end

function item_assist_hpregen_3:OnSpellStart()
    itemHPRegenOnSpellStart(self)
end

function itemHPRegenOnSpellStart(self)
    local caster = self:GetCaster()
    local ability = self
    --local item_hp_regen_percent = ability:GetSpecialValueFor("item_hp_regen_percent")
    local duration = ability:GetSpecialValueFor("duration")   
    caster:AddNewModifier(caster,ability,"modifier_item_assist_hpregen_buff", {Duration = duration})
end





function modifier_item_assist_hpregen_buff:IsBuff()
	return true
end

function modifier_item_assist_hpregen_buff:GetEffectName()
	return "particles/zhuangbei_huixue.vpcf"
end

function modifier_item_assist_hpregen_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_assist_hpregen_buff:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
	return funcs
end

function modifier_item_assist_hpregen_buff:GetModifierHealthRegenPercentage()
    local ability = self:GetAbility()
    local duration = ability:GetSpecialValueFor("duration")
    local hp_regen_percent = ability:GetSpecialValueFor("item_hp_regen_percent")
    local buffValue = hp_regen_percent / duration
    return buffValue
end

function modifier_item_assist_hpregen_buff:OnTakeDamage(keys)
    local unit = self:GetParent()
    if IsServer() and keys.unit == unit then
        unit:RemoveModifierByName("modifier_item_assist_hpregen_buff")
    end
end

