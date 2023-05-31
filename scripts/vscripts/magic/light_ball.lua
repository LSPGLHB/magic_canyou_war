require('shoot_init')
require('skill_operation')
function createLightBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()

    local directionTable ={}
    local angle23 = 0.05 * math.pi
    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    table.insert(directionTable,direction2)
    local direction3 = Vector(newX3, newY3, direction.z)
    table.insert(directionTable,direction3)
    initDurationBuff(keys)
    for i = 1, 2, 1 do
        local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,directionTable[i])
        initDurationBuff(keys)
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        moveShoot(keys, shoot, particleID, lightBallBoomCallBack, nil)
    end
end

--技能爆炸,单次伤害
function lightBallBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    local particleBoom = lightBallRenderParticles(keys,shoot) --爆炸粒子效果生成		  
    dealSkilllightBallBoom(keys,shoot) --实现aoe爆炸效果
    EmitSoundOn("magic_light_ball_boom", shoot)
    Timers:CreateTimer(keys.particles_hit_dur,function ()
        ParticleManager:DestroyParticle(particleBoom, true)
        shoot:ForceKill(true)
        shoot:AddNoDraw()
        return nil
    end)
end

function lightBallRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 1))
    return particleBoom
end

function dealSkilllightBallBoom(keys,shoot)
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
	local radius = ability:GetSpecialValueFor("aoe_radius") --AOE爆炸范围
    
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth
		local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
			local damage = getApplyDamageValue(shoot)
			ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
		
			local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
			debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
			debuffDuration = getApplyControlValue(shoot, debuffDuration)
			local faceAngle = ability:GetSpecialValueFor("face_angle")
            setDebuffByFaceAngle(shoot, unit, faceAngle, debuffName ,debuffDuration, caster, ability)
		end
		--如果是技能则进行加强或减弱操作
		if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
            checkHitAbilityToMark(shoot, unit)
		end
	end 
end 


