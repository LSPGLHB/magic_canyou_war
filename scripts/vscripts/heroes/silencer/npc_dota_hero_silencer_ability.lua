function OnChannelSucceeded(keys)
    local caster	= keys.caster
	local ability	= keys.ability
    local buffDuration = ability:GetSpecialValueFor("power_up_duration")
    
    local powerUpModifier = "silencer_power_up_modifier"
    local currentStack = caster:GetModifierStackCount(powerUpModifier, ability) + 1
    --print("currentStack:"..currentStack)

    ability:ApplyDataDrivenModifier(caster, caster, powerUpModifier, {Duration = buffDuration})
    --caster:AddNewModifier(caster,ability,powerUpModifier, {Duration = buffDuration})

    caster:SetModifierStackCount( powerUpModifier, ability, currentStack )

    local vx = 0
    local vy = 0
    local vz = 0
    if currentStack >= 1 then
        vx = 1
        if currentStack >= 2 then
            vy = 1
            if currentStack >= 3 then
                vz = 1
            end
        end
    end
    local particleID = caster.silencerPassiveParticlesID
    if particleID == nil then
        particleID = ParticleManager:CreateParticle("particles/mingxiangge_buff.vpcf", PATTACH_POINT_FOLLOW, caster)
    end
    ParticleManager:SetParticleControl(particleID, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particleID, 1, Vector(vx,vy,vz))
    caster.silencerPassiveParticlesID = particleID

    caster.shootOver = -1
end


