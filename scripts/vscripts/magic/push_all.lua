require('shoot_init')
function getPush(keys)
    local caster = keys.caster
    
    local ability = keys.ability

    local casterPosition = caster:GetAbsOrigin()
    local interval = 0.02
    local pushSpeed = ability:GetSpecialValueFor("push_speed") * GameRules.speedConstant * interval
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
    
        local direction = (unitPosition - casterPosition):Normalized()
        

        if ((unit.FloatingAirLevel == nil or unit.FloatingAirLevel < 0) and lable ~= GameRules.skillLabel and caster ~= unit) then
            EmitSoundOn(keys.soundPushStaff, unit)
            catchFlag = true
            unit.FloatingAirLevel = 0
            local bufferTempDis = 100
            local hitTargetDebuff = keys.hitTargetDebuff
            ability:ApplyDataDrivenModifier(caster, unit, hitTargetDebuff, {Duration = -1})

            
            
            if lable == GameRules.stoneLabel then
                max_distance = max_distance * 2
            end

            local traveled_distance = 0

            Timers:CreateTimer(function()
                if traveled_distance < max_distance and unit.FloatingAirLevel == 0 then

                    local newPosition = unit:GetAbsOrigin() +  direction * pushSpeed 

                    local groundPos = GetGroundPosition(newPosition, unit)
                    --中途可穿模，最后不能穿
                    local tempLastDis = max_distance - traveled_distance
                    if tempLastDis > bufferTempDis then
                        unit:SetAbsOrigin(groundPos)
                    else
                        FindClearSpaceForUnit( unit, groundPos, false )
                    end
                    traveled_distance = traveled_distance + pushSpeed
                else
                    unit:RemoveModifierByName(hitTargetDebuff)
                    unit.FloatingAirLevel = nil
                    return nil
                end
                return interval
            end)
    
        end
    end


    
    if not catchFlag then
        --ability:ReduceMana()
        ability:EndCooldown()
    end

    
    

end
