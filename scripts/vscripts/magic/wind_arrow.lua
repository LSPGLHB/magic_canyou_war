require('shoot_init')
require('skill_operation')
require('player_power')
function createShoot(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")


    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm_sp1, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCastSp1, shoot)
    shoot.windSpeedUpUnit = {}
    shoot.intervalCallBack = windArrowIntervalCallBack
    moveShoot(keys, shoot, windArrowBoomCallBack, nil)
end

--技能爆炸,单次伤害
function windArrowBoomCallBack(shoot)
    windNetBoomRenderParticles(shoot)
    boomAOEOperation(shoot, windArrowAOEOperationCallback)
end

function windNetBoomRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function windArrowAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	
	local ability = keys.ability
    local bounds_damage_percent =  ability:GetSpecialValueFor("bounds_damage_percent") / 100

    local damage = getApplyDamageValue(shoot) + unit:GetHealth() * bounds_damage_percent
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})

	EmitSoundOn(keys.soundCastSp1, shoot)
end

function windArrowIntervalCallBack(shoot)
    local keys = shoot.keysTable
    local ability = keys.ability
    local shoot_speed = shoot.speed
    local wind_speed = ability:GetSpecialValueFor("wind_speed") * GameRules.speedConstant * 0.02
    local wind_speed_max = ability:GetSpecialValueFor("wind_speed_max") * GameRules.speedConstant * 0.02
    local wind_radius = ability:GetSpecialValueFor("wind_radius") 

    local caster = keys.caster
    local casterTeam = caster:GetTeam()
    local position = shoot:GetAbsOrigin()
    

    local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										wind_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
        local isTeamSkill = checkIsTeamSkill(shoot,unit)
        if isTeamSkill then
            
            local isHitFlag = true
            for i = 1, #shoot.windSpeedUpUnit do
                if shoot.windSpeedUpUnit[i] == unit then
                    isHitFlag = false  --如果已经击中过就不再击中
                    break
                end
            end
            if isHitFlag then
                table.insert(shoot.windSpeedUpUnit, unit)
                if shoot_speed < wind_speed_max then
                    shoot.speed = shoot_speed + wind_speed 
                    local new_particleID = ParticleManager:CreateParticle(keys.particles_nm_sp2, PATTACH_ABSORIGIN_FOLLOW , shoot)
		            ParticleManager:SetParticleControlEnt(new_particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
                    EmitSoundOn(keys.soundCastSp2, shoot)
                end
            end
        end
       
    end
end