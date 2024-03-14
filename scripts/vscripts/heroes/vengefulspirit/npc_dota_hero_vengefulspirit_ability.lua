npc_dota_hero_vengefulspirit_ability = ({})
LinkLuaModifier("modifier_vengefulspirit_cast_buff", "heroes/vengefulspirit/vengefulspirit_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function npc_dota_hero_vengefulspirit_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local modifierName = "modifier_vengefulspirit_cast_buff"
    local power_up_duration = ability:GetSpecialValueFor("power_up_duration") 
    caster:AddNewModifier(caster, ability, modifierName, {Duration = power_up_duration})
    EmitSoundOn("scene_voice_vengefulspirit_cast", caster)
    caster.shootOver = -1
end

