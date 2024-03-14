require('game_init')
require('shoot_init')
require('player_power')
blink_cooldown = ({})
blink_cooldown_passive = ({})
LinkLuaModifier("blink_cooldown_passive", "blink/blink_cooldown.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function blink_cooldown:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink_cooldown:GetIntrinsicModifierName()
	return "blink_cooldown_passive"
end

function blink_cooldown:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
    local mana_regen = ability:GetSpecialValueFor("mana_regen")

    local fromParticle = "particles/shanxian_fanji_xiaoshi.vpcf"
    local toParticle = "particles/shanxian_fanji_chuxian.vpcf"
    local casterParticle = "particles/shanxian_fanji_beidong.vpcf"

    EmitSoundOn("scene_voice_blink_cooldown_cast", caster)
    blinkOperation(caster, ability, fromParticle, toParticle, nil)

    local particleCaster = ParticleManager:CreateParticle(casterParticle, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleCaster, 0, caster:GetAbsOrigin())
    
    caster:GiveMana(mana_regen)
    reduceCooldownAllAbibity(caster, cooldown_reduce)

    caster.shootOver = -1
end

function blink_cooldown_passive:IsHidden()
    return true
end

function blink_cooldown_passive:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkMissBuff(keys,true)
    end
end

function blink_cooldown_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkMissBuff(keys,false)
    end
end

function refreshBlinkMissBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local damage_percent = ability:GetSpecialValueFor("damage_percent")
    local range = ability:GetSpecialValueFor("range")

    setPlayerPower(playerID, "contract_damage_d_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_c_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_b_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_a_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_range", flag, range)

    setPlayerSimpleBuff(keys,"range")

end