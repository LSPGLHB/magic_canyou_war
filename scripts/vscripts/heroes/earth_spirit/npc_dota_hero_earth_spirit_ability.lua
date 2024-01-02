npc_dota_hero_earth_spirit_ability = ({})
LinkLuaModifier("modifier_tie_defence_passive", "heroes/earth_spirit/tie_defence_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_tie_defence_buff", "heroes/earth_spirit/tie_defence_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)


function npc_dota_hero_earth_spirit_ability:GetIntrinsicModifierName()
	return "modifier_tie_defence_passive"
end

function npc_dota_hero_earth_spirit_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local defence_percent = ability:GetSpecialValueFor("defence_percent")
    local duration = ability:GetSpecialValueFor("duration")
    local refresh_count = ability:GetSpecialValueFor("refresh_count")
    local modifierName = "modifier_tie_defence_buff"
    caster:AddNewModifier(caster, ability, modifierName, {Duration = duration})
    local interval = 0.02
    Timers:CreateTimer(function()
        if interval == -1 then
            return nil
        end
        caster:Purge( false, true, false, true, false )
        return interval
    end)
    Timers:CreateTimer(duration,function()

        interval = -1

    end)
end

