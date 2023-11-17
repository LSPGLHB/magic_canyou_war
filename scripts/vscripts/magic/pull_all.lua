require('shoot_init')
function getPull(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local targetPosition = target:GetAbsOrigin()
    --print("targetPos:",targetPosition)
    local label = target:GetUnitLabel()
    local max_distance =  (casterPosition - targetPosition):Length2D() - 60
    local direction = (casterPosition - targetPosition):Normalized()
    if ((target.FloatingAirLevel == nil or target.FloatingAirLevel < 9) and (label == GameRules.stoneLabel or target:IsHero()) and target ~= caster) then
        EmitSoundOn(keys.soundPull, caster)
        EmitSoundOn(keys.soundPullStaff, target)
        target.FloatingAirLevel = 9
        local bufferTempDis = 100
        local hitTargetDebuff = keys.hitTargetDebuff
        local buffTime = max_distance / ability:GetSpecialValueFor("pull_speed")
        ability:ApplyDataDrivenModifier(caster, target, hitTargetDebuff, {Duration = buffTime})
        local casterBuff = keys.modifier_caster_name
        ability:ApplyDataDrivenModifier(caster, caster, casterBuff, {Duration = buffTime})
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
        --ability:ReduceMana()
        ability:EndCooldown()
        EmitSoundOn("magic_pull_push_fail",caster)
        local particleName = "particles/fasheshibai.vpcf"
        local particleID = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
    end
    

end