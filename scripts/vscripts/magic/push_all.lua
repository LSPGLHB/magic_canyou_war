require('shoot_init')
function getPush(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local interval = 0.02
    local pushSpeed = ability:GetSpecialValueFor("push_speed") --* GameRules.speedConstant * interval
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local searchRadius = ability:GetSpecialValueFor("search_radius")
    local casterTeam = caster:GetTeam()
    local aroundUnits = FindUnitsInRadius(casterTeam, 
                                        casterPosition,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)

    local catchFlag = false
    

	for k,unit in pairs(aroundUnits) do
        local unitPosition = unit:GetAbsOrigin()
        local label = unit:GetUnitLabel()
    
        local direction = (skillPoint - unitPosition):Normalized()

        if GameRules.stoneLabel == label or unit:IsHero() and unit ~= caster then
            beatBackUnit(keys,caster,unit,pushSpeed,max_distance,direction,AbilityLevel,true)
            local particleName = "particles/shenluotianzheng.vpcf"
            local particleID = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
            ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
            catchFlag = true
            EmitSoundOn(keys.soundPush, caster)
        end
        
    end

    if not catchFlag then
        ability:EndCooldown()
        EmitSoundOn("magic_pull_push_fail",caster)
        local particleName = "particles/fasheshibai.vpcf"
        local particleID = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
    end
end

function blink(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local distance = ability:GetSpecialValueFor("distance")

    local fromParticle = "particles/items_fx/blink_dagger_start.vpcf"
    local toParticle = "particles/items_fx/blink_dagger_end.vpcf"

    local direction = (skillPoint - casterPosition):Normalized()

    local newPos = casterPosition + direction * distance

    local particleFrom = ParticleManager:CreateParticle(fromParticle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particleFrom, 0, caster:GetAbsOrigin())

	--caster:SetAbsOrigin(newPos)
    FindClearSpaceForUnit( caster, newPos, false )

    local particleTo = ParticleManager:CreateParticle(toParticle, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particleTo, 0, caster:GetAbsOrigin())

end

