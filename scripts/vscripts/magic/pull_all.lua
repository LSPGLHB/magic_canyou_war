require('shoot_init')
function getPull(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = target:GetAbsOrigin()
    --print("targetPos:",targetPosition)
    local lable = target:GetUnitLabel()
    local max_distance =  (casterPosition - targetPosition):Length2D() - 60
    local direction = (casterPosition - targetPosition):Normalized()
    if ((target.FloatingAirLevel == nil or target.FloatingAirLevel < 9) and lable ~= GameRules.skillLabel) then
        EmitSoundOn(keys.soundPull, caster)
        EmitSoundOn(keys.soundPullStaff, target)
        target.FloatingAirLevel = 9
        local bufferTempDis = 100
        local hitTargetDebuff = keys.hitTargetDebuff
        ability:ApplyDataDrivenModifier(caster, target, hitTargetDebuff, {Duration = -1})
        local casterBuff = keys.modifier_caster_name
        ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = -1})
        local interval = 0.02
        local pullSpeed = ability:GetSpecialValueFor("pull_speed") * GameRules.speedConstant * interval
        local traveled_distance = 0
        Timers:CreateTimer(function()
            if traveled_distance < max_distance and target.FloatingAirLevel == 9 then
                local newPosition = target:GetAbsOrigin() +  direction * pullSpeed 

                local groundPos = GetGroundPosition(newPosition, target)
                --中途可穿模，最后不能穿
                local tempLastDis = max_distance - traveled_distance
                if tempLastDis > bufferTempDis then
                    target:SetAbsOrigin(groundPos)
                else
                    FindClearSpaceForUnit( target, groundPos, false )
                end
                if tempLastDis < bufferTempDis * 2 then
                    caster:RemoveModifierByName(casterBuff)	
                end
                traveled_distance = traveled_distance + pullSpeed
            else
                target:RemoveModifierByName(hitTargetDebuff)
                
                target.FloatingAirLevel = nil
                return nil
            end
            return interval
        end)

    else
        ability:ReduceMana()
        ability:EndCooldown()
    end
    

end