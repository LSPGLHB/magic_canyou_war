require('game_init')
require('shoot_init')
require('player_power')
blink_range = ({})
blink_range_passive = ({})
blink_range_buff = ({})
LinkLuaModifier("blink_range_passive", "blink/blink_range.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("blink_range_buff", "blink/blink_range.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function blink_range:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink_range:GetIntrinsicModifierName()
	return "blink_range_passive"
end

function blink_range:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    local duration = ability:GetSpecialValueFor("duration")

    local fromParticle = "particles/shanxian_yuanju_xiaoshi.vpcf"
    local toParticle = "particles/shanxian_yuanju_chuxian.vpcf"
    

    EmitSoundOn("scene_voice_blink_range_cast", caster)
    blinkOperation(caster, ability, fromParticle, toParticle, nil)

    caster:AddNewModifier(caster, ability, "blink_range_buff", {Duration = duration})
    caster.shootOver = -1
end

function blink_range_buff:IsBuff()
	return true
end

function blink_range_buff:GetEffectName()
	return "particles/shanxian_yuanju_beidong.vpcf"
end

function blink_range_buff:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function blink_range_buff:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkRangeBuffBuff(keys,true)
    end
end

function blink_range_buff:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkRangeBuffBuff(keys,false)
    end
end

function refreshBlinkRangeBuffBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local buff_range = ability:GetSpecialValueFor("buff_range")

    setPlayerPower(playerID, "contract_range", flag, buff_range)

    setPlayerSimpleBuff(keys,"range")

end

function blink_range_passive:IsHidden()
    return true
end

function blink_range_passive:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkRangeBuff(keys,true)
    end
end

function blink_range_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkRangeBuff(keys,false)
    end
end

function refreshBlinkRangeBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local damage_percent = ability:GetSpecialValueFor("damage_percent")
    local range = ability:GetSpecialValueFor("range")

    setPlayerPower(playerID, "contract_damage_d_percent_base", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_b_percent_base", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_c_percent_base", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_a_percent_base", flag, damage_percent)
    setPlayerPower(playerID, "contract_range", flag, range)

    setPlayerSimpleBuff(keys,"range")

end