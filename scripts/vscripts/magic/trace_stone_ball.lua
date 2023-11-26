require('shoot_init')
require('skill_operation')
require('player_power')
function createTraceStoneBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)

    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    shoot.particleID = particleID
    EmitSoundOn(keys.soundCast, shoot)
    shoot.intervalCallBack = traceStoneBallIntervalCallBack
    moveShoot(keys, shoot, traceStoneBallBoomCallback, nil)

end





--技能爆炸,单次伤害
function traceStoneBallBoomCallback(shoot)  
	boomAOEOperation(shoot, traceStoneBallAOEOperationCallback)
end
--爆炸粒子效果生成	
function traceStoneBallRenderParticles(shoot)
	local particlesName = shoot.particles_boom
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end
function traceStoneBallStrikeRenderParticles(shoot) 	
	local keys = shoot.keysTable
	local particlesName = keys.particles_strike
	local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
	ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end


function traceStoneBallAOEOperationCallback(shoot,unit)
	local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local double_damage_percentage = ability:GetSpecialValueFor("double_damage_percentage") 
	local damage_rate = ability:GetSpecialValueFor("damage_rate") 
	--math.randomseed(tostring(GameRules:GetGameTime()):reverse():sub(1,6))

	local randomNum = math.random(0,100)
	local trace_distance = (shoot:GetAbsOrigin() - shoot.position):Length2D()
	shoot.damage = shoot.damage + (trace_distance / 100) * damage_rate
	local damage = getApplyDamageValue(shoot)

	if randomNum < double_damage_percentage then
		damage = damage * 2
		EmitSoundOn(keys.soundStrike, shoot)
		traceStoneBallStrikeRenderParticles(shoot) 	
	else
		traceStoneBallRenderParticles(shoot) 	
	end
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end

--技能追踪
function traceStoneBallIntervalCallBack(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local casterTeam = caster:GetTeam()
	local position=shoot:GetAbsOrigin()
	local searchRadius = ability:GetSpecialValueFor("search_range")
	if shoot.trackUnit == nil then
		local aroundUnits = FindUnitsInRadius(casterTeam, 
											position,
											nil,
											searchRadius,
											DOTA_UNIT_TARGET_TEAM_BOTH,
											DOTA_UNIT_TARGET_ALL,
											0,
											0,
											false)

		for k,unit in pairs(aroundUnits) do
			--local unitEnergy = unit.energy_point
			--local shootEnergy = shoot.energy_point
			if checkIsEnemyHeroNoMagicStone(shoot,unit) then
				shoot.trackUnit = unit
				local shootSpeed = shoot.speed
				shoot.speed = 0
				shoot.position = shoot:GetAbsOrigin()
				shoot.traveled_distance =  0.5 * shoot.max_distance
				ParticleManager:SetParticleControl(shoot.particleID, 13, Vector(0, 1, 0))
				EmitSoundOn(keys.soundTrace, shoot)
				Timers:CreateTimer(0.5 ,function()
					shoot.speed = shootSpeed * 1.5
				end)
			end
		end
	end

	--print("ooo:",shoot.traveled_distance)
	if shoot.trackUnit ~= nil then
		shoot.direction = (shoot.trackUnit:GetAbsOrigin() - position):Normalized()
	end
end