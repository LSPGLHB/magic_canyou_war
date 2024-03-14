require("heroes/zuus/zuus_modifier")

npc_dota_hero_zuus_ability = ({})
LinkLuaModifier("modifier_zuus_passive", "heroes/zuus/zuus_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_zuus_cast_buff", "heroes/zuus/zuus_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)


function npc_dota_hero_zuus_ability:GetIntrinsicModifierName()
	return "modifier_zuus_passive"
end

function npc_dota_hero_zuus_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    zuusPassiveBuffRefresh(caster, ability)
    EmitSoundOn("scene_voice_zuus_cast" ,caster)
    
    caster.shootOver = -1
end

