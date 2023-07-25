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
    EmitSoundOn(keys.soundPush, caster)

	for k,unit in pairs(aroundUnits) do
        local unitPosition = unit:GetAbsOrigin()
        local lable = unit:GetUnitLabel()
    
        local direction = (skillPoint - unitPosition):Normalized()

        if unit ~= caster then
            beatBackUnit(keys,caster,unit,pushSpeed,max_distance,direction,true)
        end
        
    end

    --[[
    if not catchFlag then
        ability:EndCooldown()
    end
    ]]
end

