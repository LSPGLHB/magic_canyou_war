function OnPowerUp(caster,particlesFile,value,type)
    --print("==OnPowerUp==")
    local position = caster:GetAbsOrigin()
    local particleID = ParticleManager:CreateParticle(particlesFile, PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleID, 0, position)
	if type == "cooldown" then
        local x = math.floor(value)
        local y = value * 10 % 10
	    ParticleManager:SetParticleControl(particleID, 1, Vector(x,y,0))
    end

    if type == "health" then
        local cp1x = 0
        if value >= 0 then
            cp1x = 0
        else
            cp1x = 1
        end
        local cp1y = math.floor(value/10)
        local cp1z = value % 10

        local cp2x = 1
        local cp2y = 1
        local cp2z = 1

        if value < 10 then
            cp1y = cp1z
            cp2z = 0
        end

	    ParticleManager:SetParticleControl(particleID, 1, Vector(cp1x,cp1y,cp1z))
        ParticleManager:SetParticleControl(particleID, 2, Vector(cp2x,cp2y,cp2z))
    end

    if type == "mana_regen" then
        local x = math.floor(value)
        local y = value * 10 % 10
	    ParticleManager:SetParticleControl(particleID, 1, Vector(x,y,0))
    end

    if type == "vision" then
        local cp1x = 0
        if value >= 0 then
            cp1x = 0
        else
            cp1x = 1
        end
        local cp1x = math.floor(value/100)
        local cp1y = math.floor((value % 100) / 10)
        local cp1z = math.floor((value % 100) % 10)

        local cp2x = 1
        local cp2y = 1
        local cp2z = 1

        if cp1x == 0 then
            cp1x = cp1y
            cp1y = cp1z
            cp2z = 0
            if cp1x == 0 then
                cp1x = cp1y
                cp2y = 0
                cp2z = 0
            end
        end

	    ParticleManager:SetParticleControl(particleID, 1, Vector(cp1x,cp1y,cp1z))
        ParticleManager:SetParticleControl(particleID, 2, Vector(cp2x,cp2y,cp2z))
    end

    Timers:CreateTimer(2,function()
        ParticleManager:DestroyParticle(particleID, true)
    end)
    
end

function OnPowerUpSharp(caster,particlesFile)
    local position = caster:GetAbsOrigin()
    local particleID = ParticleManager:CreateParticle(particlesFile, PATTACH_ABSORIGIN_FOLLOW , caster)
    ParticleManager:SetParticleControl(particleID, 1, position)
    ParticleManager:SetParticleControl(particleID, 5, Vector(1,1,1))
end