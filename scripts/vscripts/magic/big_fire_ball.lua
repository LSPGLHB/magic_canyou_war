require('shoot_init')
require('skill_operation')
function createBigFireBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    local speed = ability:GetSpecialValueFor("speed")
    local angleRate = ability:GetSpecialValueFor("angle_rate") * math.pi
	local aoe_radius = ability:GetSpecialValueFor("aoe_radius")
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = (skillPoint - casterPoint ):Length2D()
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    --过滤掉增加施法距离的操作
	shoot.max_distance_operation = max_distance
    initDurationBuff(keys)
	shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    moveShoot(keys, shoot, particleID, bigFireBallBoomCallBack, nil)
end

--技能爆炸,单次伤害
function bigFireBallBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    bigFireBallRenderParticles(keys,shoot) --爆炸粒子效果生成		  
    dealSkillbigFireBallBoom(keys,shoot) --实现aoe爆炸效果
    --bigFireBallDuration(keys,shoot) --实现持续光环效果以及粒子效果
    EmitSoundOn("magic_big_fire_ball_boom", shoot)
	--EndShootControl(keys)--遥控用
    Timers:CreateTimer(1,function ()
        --ParticleManager:DestroyParticle(particleBoom, true)
        --EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)
        shoot:ForceKill(true)
        shoot:AddNoDraw()
        return nil
    end)
end

function bigFireBallRenderParticles(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	--local radius = ability:GetSpecialValueFor("aoe_radius") / 6
	local particleBoom = ParticleManager:CreateParticle(keys.particlesBoom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(shoot.aoe_radius, 1, 0))
end

function dealSkillbigFireBallBoom(keys,shoot)
	local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
	local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.modifierDebuffName
	local radius = shoot.aoe_radius --AOE爆炸范围
    
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
            local beat_back_one = ability:GetSpecialValueFor("beat_back_one") 
	        local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed")   
            --local tempDistance = (shoot:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
            --local beatBackDistance = beat_back_one - tempDistance   --只击退到AOE的600码
            beatBackUnit(keys,shoot,unit,beat_back_one,beatBackSpeed,1,1)
			local damage = getApplyDamageValue(shoot)
			ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
	
			local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
			debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,nil)--数值加强
			debuffDuration = getApplyControlValue(shoot, debuffDuration)--相生加强

			local faceAngle = ability:GetSpecialValueFor("face_angle")
			
			local flag = setDebuffByFaceAngle(shoot, unit, faceAngle)
            if flag then
                ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
            end

		end
		--如果是技能则进行加强或减弱操作
		if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
            checkHitAbilityToMark(shoot, unit)
		end
	end 
end

