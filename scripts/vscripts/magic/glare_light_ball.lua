require('shoot_init')
require('skill_operation')
function createGlareLightBall(keys)
    local caster = keys.caster
    local ability = keys.ability
    local skillPoint = ability:GetCursorPosition()
    --local speed = ability:GetSpecialValueFor("speed")
	local aoe_radius = ability:GetSpecialValueFor("damage_aoe_radius") 
    local casterPoint = caster:GetAbsOrigin()
    local max_distance = ability:GetSpecialValueFor("max_distance") 
    local direction = (skillPoint - casterPoint):Normalized()
    local shoot = CreateUnitByName(keys.unitModel, casterPoint, true, nil, nil, caster:GetTeam())
    creatSkillShootInit(keys,shoot,caster,max_distance,direction)
    initDurationBuff(keys)
	shoot.aoe_radius = aoe_radius
    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	shoot.particleID = particleID
	EmitSoundOn(keys.soundCast, caster)
    shoot.intervalCallBack = glareLightBallBoomCallBack --周期运行
    moveShoot(keys, shoot, nil, nil)
end

--技能爆炸,单次伤害
function glareLightBallBoomCallBack(shoot)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability

    local damage_aoe_radius = ability:GetSpecialValueFor("damage_aoe_radius") 
    local debuff_aoe_radius = ability:GetSpecialValueFor("debuff_aoe_radius") 
    local faceAngle = ability:GetSpecialValueFor("face_angle")
    local defenceParticles = keys.particles_defense
    local isHit = 0

	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										debuff_aoe_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.energyHealth
		local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if checkIsEnemyNoSkill(shoot,unit) and checkIsHitUnit(shoot,unit,0) then
            local isface = isFaceByFaceAngle(shoot, unit, faceAngle)
            if isface then
                local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
                ability:ApplyDataDrivenModifier(caster, unit, keys.hitTargetDebuff, {Duration = debuffDuration}) 
                isHit = 1
            else
                local defenceParticlesID =ParticleManager:CreateParticle(defenceParticles, PATTACH_OVERHEAD_FOLLOW , unit)
                ParticleManager:SetParticleControlEnt(defenceParticlesID, 3 , unit, PATTACH_OVERHEAD_FOLLOW, nil, shoot:GetAbsOrigin(), true)

                EmitSoundOn(keys.soundDefense, unit)

                Timers:CreateTimer(0.5, function()
                    ParticleManager:DestroyParticle(defenceParticlesID, true)
                    return nil
                end)
            end
		end
		--如果是技能则进行加强或减弱操作
		if checkIsSkill(shoot,unit) then
            checkHitAbilityToMark(shoot, unit)
		end
	end 

    local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										damage_aoe_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	for k,unit in pairs(aroundUnits) do
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.energyHealth
		local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if checkIsEnemyNoSkill(shoot,unit) and checkIsHitUnit(shoot,unit,1) then
			local damage = getApplyDamageValue(shoot)
	        ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})  
            isHit = 1
		end
		--如果是技能则进行加强或减弱操作
		if checkIsSkill(shoot,unit) then
            checkHitAbilityToMark(shoot, unit)
		end
	end 
    if isHit == 1 then
        shootSoundAndParticle(shoot, "boom")
    end
end

