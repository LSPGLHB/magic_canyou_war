require('shoot_init')
require('skill_operation')
function createSmallTornado(keys)
		local caster = keys.caster
		local ability = keys.ability
		local speed = ability:GetSpecialValueFor("speed")
		local max_distance = ability:GetSpecialValueFor("max_distance")
		local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
		local position = caster:GetAbsOrigin()
		local direction = (ability:GetCursorPosition() - position):Normalized()
		local shoot = CreateUnitByName(keys.unitModel, position, true, nil, nil, caster:GetTeam())
        creatSkillShootInit(keys,shoot,caster,max_distance,direction)
		initDurationBuff(keys)
		aoe_duration = getApplyControlValue(shoot, aoe_duration)
		shoot.control = aoe_duration	
		local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot) 
		ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
		moveShoot(keys, shoot, particleID, smallTornadoBoomCallBack, smallTornadoTakeAwayCallBack)
end

function smallTornadoBoomCallBack(keys,shoot,particleID)
    ParticleManager:DestroyParticle(particleID, true) --子弹特效消失
    smallTornadoDuration(keys,shoot) --实现持续光环效果以及粒子效果
end

function smallTornadoDuration(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
    local aoeDebuff = keys.hitTargetDebuff
	shoot.debuffName = aoeDebuff
    local aoe_duration_radius = ability:GetSpecialValueFor("aoe_duration_radius") --AOE持续作用范围
    --print("smallTornadoDuration:"..shoot.control)
	local aoe_duration = shoot.control
    local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local tempTimer = 0
	local interval = 0.02
    local particleBoom = smallTornadoRenderParticles(keys,shoot)
	
    Timers:CreateTimer(0,function ()
		local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_duration_radius,
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
				damage = damage * interval
				checkHitUnitToMark(shoot.hitUnits, true, unit)
				ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
				blackHole(keys, shoot, unit, aoeDebuff, interval, tempTimer, aoe_duration)
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 then
                checkHitAbilityToMark(shoot, unit)
            end
        end
        if tempTimer < aoe_duration then --这里产生误差，需要换算法
            tempTimer = tempTimer + interval
            return interval
        else 
			clearUnitsModifierByName(shoot,aoeDebuff)
            ParticleManager:DestroyParticle(particleBoom, true)
            EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)	
            shoot:ForceKill(true)
            shoot:AddNoDraw()
            return nil
        end
	end)
end

--特效显示效果
function smallTornadoRenderParticles(keys,shoot)
    local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetSpecialValueFor("aoe_duration_radius")
	print("smallTornadoRenderParticles:"..shoot.control)
	local particleBoom = ParticleManager:CreateParticle(keys.durationParticlesBoom, PATTACH_WORLDORIGIN, caster)
    local shootPos = shoot:GetAbsOrigin()
	ParticleManager:SetParticleControl(particleBoom, 0, Vector(shootPos.x, shootPos.y, shootPos.z))
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(particleBoom, 2, Vector(shoot.control, 0, 0))
	return particleBoom
end

function smallTornadoTakeAwayCallBack(keys, shoot, unit)
	takeAwayUnit(keys, shoot, unit)
end

