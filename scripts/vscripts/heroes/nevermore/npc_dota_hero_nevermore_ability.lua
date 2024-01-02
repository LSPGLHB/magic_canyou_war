npc_dota_hero_nevermore_ability = ({})
LinkLuaModifier("modifier_magic_miss_passive", "heroes/earth_spirit/tie_defence_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_speed_up_passive", "heroes/earth_spirit/tie_defence_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_speed_up_cast", "heroes/earth_spirit/tie_defence_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_strike_passive", "heroes/earth_spirit/tie_defence_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function npc_dota_hero_nevermore_ability:GetIntrinsicModifierName()
	return "modifier_magic_miss_passive"
end

function npc_dota_hero_nevermore_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    --local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local cast_speed_up = ability:GetSpecialValueFor("cast_speed_up")
    --local passive_speed_up_percent = ability:GetSpecialValueFor("passive_speed_up_percent")
    local miss_ability_speed_up_percent = ability:GetSpecialValueFor("miss_ability_speed_up_percent")
    local miss_ability_speed_up_damage = ability:GetSpecialValueFor("miss_ability_speed_up_damage")
    local miss_ability_speed_up_duration = ability:GetSpecialValueFor("miss_ability_speed_up_duration")
    local miss_count = ability:GetSpecialValueFor("miss_count")
    local miss_times = ability:GetSpecialValueFor("miss_times")


    local modifierSpeedUpCast = "modifier_speed_up_cast"
    caster:AddNewModifier(caster, ability, modifierSpeedUpCast, {Duration = duration})


    local modifierStrike = "modifier_strike_passive"
    
    --[[
    local interval = 0.02
    Timers:CreateTimer(function()
        if interval == -1 then
            return nil
        end
        
        return interval
    end)
    Timers:CreateTimer(duration,function()

        interval = -1

    end)]]
end

