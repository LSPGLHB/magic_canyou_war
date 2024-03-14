npc_dota_hero_omniknight_ability = ({})
LinkLuaModifier("modifier_omniknight_passive", "heroes/omniknight/supply_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
function npc_dota_hero_omniknight_ability:GetCastRange(v,t)
    local range = self:GetSpecialValueFor("aoe_radius")
    return range
end

function npc_dota_hero_omniknight_ability:GetIntrinsicModifierName()
	return "modifier_omniknight_passive"
end

function npc_dota_hero_omniknight_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    
    local hp_supply_percent = ability:GetSpecialValueFor("hp_supply_percent")
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    
    
    local casterLocation = caster:GetAbsOrigin()
    local casterTeam = caster:GetTeam()
    local hpUnit = caster
    local aroundUnits = FindUnitsInRadius(casterTeam, 
                                    casterLocation,
                                    nil,
                                    aoe_radius,
                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                    DOTA_UNIT_TARGET_ALL,
                                    0,
                                    0,
                                    false)
    for _, unit in pairs(aroundUnits) do
        --local targetLabel = value:GetUnitLabel()
        --print("aroundUnits:"..unit:GetName())
        local unitTeam = unit:GetTeam()
        if unit:IsHero() and unitTeam == casterTeam and caster:IsAlive() then
            local hp_percent = hpUnit:GetHealth() / hpUnit:GetMaxHealth()
            local temp_hp_percent = unit:GetHealth() / unit:GetMaxHealth()

            if temp_hp_percent < hp_percent then
                hpUnit = unit
            end

        end
    end
    
    
    local particleName = "particles/huixuege.vpcf"
    local particleID = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, hpUnit)
    ParticleManager:SetParticleControl(particleID, 0, hpUnit:GetAbsOrigin())
    ParticleManager:SetParticleControl(particleID, 1, Vector(150, 0, 0))
    
    Timers:CreateTimer(0.3,function()
        hpUnit:Heal(hpUnit:GetMaxHealth() * 0.3, nil)
        EmitSoundOn("scene_voice_omniknight_cast",hpUnit)
    end)
    Timers:CreateTimer(2,function()
        ParticleManager:DestroyParticle(particleID, true)
    end)
    caster.shootOver = -1
end