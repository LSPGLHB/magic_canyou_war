npc_dota_hero_nevermore_ability = ({})
LinkLuaModifier("modifier_nevermore_miss_passive", "heroes/nevermore/magic_miss_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_nevermore_speed_up_passive", "heroes/nevermore/magic_miss_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_nevermore_speed_up_cast", "heroes/nevermore/magic_miss_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_nevermore_strike_passive", "heroes/nevermore/magic_miss_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function npc_dota_hero_nevermore_ability:GetCastRange(v,t)
    local range = self:GetSpecialValueFor("aoe_radius")
    return range
end

function npc_dota_hero_nevermore_ability:GetIntrinsicModifierName()
	return "modifier_nevermore_miss_passive"
end

function npc_dota_hero_nevermore_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    local duration = ability:GetSpecialValueFor("cast_speed_up_duration")

    local modifierSpeedUpCast = "modifier_nevermore_speed_up_cast"
    caster:AddNewModifier(caster, ability, modifierSpeedUpCast, {Duration = duration})
    EmitSoundOn("scene_voice_nevermore_cast",caster)
    caster.shootOver = -1
 
end

