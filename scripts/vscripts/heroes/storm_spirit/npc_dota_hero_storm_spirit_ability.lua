npc_dota_hero_storm_spirit_ability = ({})
LinkLuaModifier("modifier_storm_spirit_passive", "heroes/storm_spirit/storm_spirit_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)



function npc_dota_hero_storm_spirit_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local power_up_duration = ability:GetSpecialValueFor("power_up_duration")
    local damage_up_percent = ability:GetSpecialValueFor("damage_up_percent")
    local cooldown_reduce_percent = ability:GetSpecialValueFor("cooldown_reduce_percent")
    local modifierName = "modifier_storm_spirit_passive"
    caster:AddNewModifier(caster, ability, modifierName, {Duration = power_up_duration})

    EmitSoundOn("scene_voice_storm_spirit_cast", caster)
    caster.shootOver = -1
end

