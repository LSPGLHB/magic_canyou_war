require('myMaths')
npc_dota_hero_faceless_void_ability = ({})
LinkLuaModifier( "modifier_faceless_void_buff", "heroes/faceless_void/pingzhang_modifier.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )


function npc_dota_hero_faceless_void_ability:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local casterLocation = caster:GetAbsOrigin()
    local casterTeam = caster:GetTeam()
    local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local duration = ability:GetSpecialValueFor("duration")
    local ability_speed_down_percent = ability:GetSpecialValueFor("ability_speed_down_percent")
    local ability_speed_up_percent = ability:GetSpecialValueFor("ability_speed_up_percent")
    local cooldown_reduce = ability:GetSpecialValueFor("cooldown_reduce")
    local modifierName = "modifier_faceless_void_buff"
    local particleName = "particles/pingzhangge_pingzhang.vpcf"
    local particleID = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particleID, 0, casterLocation)
	ParticleManager:SetParticleControl(particleID, 1, Vector(aoe_radius, aoe_radius, aoe_radius))
    EmitSoundOn("scene_voice_faceless_void_cast",caster)
    caster:AddNewModifier(caster, ability,modifierName,{Duration = duration})

    local currentStack = 0
    local interval = 0.02
    local pingzhangUnits = {}
    Timers:CreateTimer(function()
        if interval == -1 then
            return nil
        end
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
            local targetLabel = unit:GetUnitLabel()
            local unitEnergy = unit.energy_point
            local checkFlag = checkContainsArrayValue(pingzhangUnits, unit)
            if (targetLabel == GameRules.skillLabel or targetLabel == GameRules.towerSkillLabel) and unitEnergy ~= 0 and not checkFlag then
                local unitTeam = unit:GetTeam()
                local unitSpeed = unit.speed
                if unitTeam == casterTeam then
                    unit.speed = unitSpeed * (1 + ability_speed_up_percent/100)
                else
                    unit.speed = unitSpeed * (1 + ability_speed_down_percent/100)
                end
                table.insert(pingzhangUnits, unit)
                --print(unitTeam..":"..unitSpeed)
                --caster:GetModifierStackCount( modifierName, caster )
                currentStack = currentStack + 1
                caster:SetModifierStackCount(modifierName,caster,currentStack)
            end
        end 

        return interval
    end)

    Timers:CreateTimer(duration,function()
        local cooldownReduce = currentStack * cooldown_reduce
        ParticleManager:DestroyParticle(particleID, true)
        interval = -1
        if currentStack > 0 then
            local cooldownTimeRemaining = ability:GetCooldownTimeRemaining()
            cooldownTimeRemaining = cooldownTimeRemaining - cooldownReduce
            ability:EndCooldown()
            ability:StartCooldown(cooldownTimeRemaining)
        end
    end)
    
end



