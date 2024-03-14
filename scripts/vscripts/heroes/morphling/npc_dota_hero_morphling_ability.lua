require("heroes/morphling/morphling_modifier")

npc_dota_hero_morphling_ability = ({})
LinkLuaModifier("modifier_morphling_passive", "heroes/morphling/morphling_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_morphling_cast_buff", "heroes/morphling/morphling_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)


function npc_dota_hero_morphling_ability:GetIntrinsicModifierName()
	return "modifier_morphling_passive"
end

function npc_dota_hero_morphling_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self

    local modifierName= "modifier_morphling_cast_buff"
    caster:AddNewModifier(caster, ability, modifierName, {Duration = -1})
    EmitSoundOn("scene_voice_morphling_cast", caster)
    caster.shootOver = -1
end

