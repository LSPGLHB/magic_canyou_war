require('shoot_init')
require('skill_operation')
x_soil_ball_datadriven =({})
LinkLuaModifier( "x_soil_ball_datadriven_modifier_debuff", "magic/modifiers/x_soil_ball_modifier_debuff.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL )

function x_soil_ball_datadriven:GetCastRange(v,t)
    local range = getRangeByName(self,'b')
    return range
end

function x_soil_ball_datadriven:OnSpellStart()
    createShoot(self)
end

function createShoot(ability)
    local caster = ability:GetCaster()
    local magicName = ability:GetAbilityName()
    local keys = getMagicKeys(ability,magicName)

    keys.particles_nm =      "particles/22xxingtuqiu_shengcheng.vpcf"
    keys.soundCast = 		"magic_x_soil_ball_cast"
    keys.particles_power = 	"particles/22xxingtuqiu_jiaqiang.vpcf"
    keys.soundPower =		"magic_soil_power_up"
    keys.particles_weak = 	"particles/22xxingtuqiu_xueruo.vpcf"
    keys.soundWeak =			"magic_soil_power_down"
    keys.particles_misfire = "particles/22xxingtuqiu_jiluo.vpcf"
    keys.soundMisfire =		"magic_soil_mis_fire"
    keys.particles_miss =    "particles/22xxingtuqiu_xiaoshi.vpcf"
    keys.soundMiss =			"magic_soil_miss"
    keys.particles_boom = 	"particles/22xxingtuqiu_mingzhong.vpcf"
    keys.soundBoom =			"magic_x_soil_ball_boom"
    keys.hitTargetDebuff =  "x_soil_ball_datadriven_modifier_debuff"

    local skillPoint = ability:GetCursorPosition()

    local max_distance = ability:GetSpecialValueFor("max_distance")

    local casterPoint = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPoint):Normalized()
    local shootPosTable ={}
    local angle23 = 0.45 * math.pi

    local newX2 = math.cos(math.atan2(direction.y, direction.x) - angle23)
    local newY2 = math.sin(math.atan2(direction.y, direction.x) - angle23)
    local newX3 = math.cos(math.atan2(direction.y, direction.x) + angle23)
    local newY3 = math.sin(math.atan2(direction.y, direction.x) + angle23)
    local direction2 = Vector(newX2, newY2, direction.z)
    local direction3 = Vector(newX3, newY3, direction.z)

    local shootPos2 = casterPoint + direction2 * 250
    table.insert(shootPosTable,shootPos2)
    local shootPos3 = casterPoint + direction3 * 250
    table.insert(shootPosTable,shootPos3)

    initDurationBuff(keys)
    for i = 1, 2, 1 do
        local shootPos = shootPosTable[i]
        local shoot = CreateUnitByName(keys.unitModel, shootPos, true, nil, nil, caster:GetTeam())
        shoot.shootCount = i
        shootPos = Vector(shootPos.x,shootPos.y,shootPos.z+100)
        shoot:SetAbsOrigin(shootPos)
        local shootDirection = (skillPoint - shoot:GetAbsOrigin()):Normalized()
        creatSkillShootInit(keys,shoot,caster,max_distance,shootDirection)
        --shoot.aoe_radius = aoe_radius
        local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
        ParticleManager:SetParticleControlEnt(particleID, keys.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
        shoot.particleID = particleID
        EmitSoundOn(keys.soundCast, shoot)
        Timers:CreateTimer(ability:GetSpecialValueFor("delay_shoot"), function()
            moveShoot(keys, shoot, xSoilBallBoomCallBack, nil)
            return nil
        end)
    end
    caster.shootOver = 1
end

--技能爆炸,单次伤害
function xSoilBallBoomCallBack(shoot)
    --ParticleManager:DestroyParticle(shoot.particleID, true) --子弹特效消失
    xSoilBallRenderParticles(shoot) --爆炸粒子效果生成		  
    --dealSkillxSoilBallBoom(keys,shoot) --实现aoe爆炸效果
    boomAOEOperation(shoot, xSoilBallAOEOperationCallback)
end

function xSoilBallRenderParticles(shoot)
    local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius")
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, caster)
	local groundPos = GetGroundPosition(shoot:GetAbsOrigin(), shoot)
	ParticleManager:SetParticleControl(particleBoom, 3, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 10, Vector(radius, 1, 1))
end

function xSoilBallAOEOperationCallback(shoot,unit)
    local keys = shoot.keysTable
    local caster = keys.caster
	local playerID = caster:GetPlayerID()
	local ability = keys.ability
    local AbilityLevel = shoot.abilityLevel
    local debuffName = keys.hitTargetDebuff
    local damage = getApplyDamageValue(shoot) / 2
    local debuffDuration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
    debuffDuration = getFinalValueOperation(playerID,debuffDuration,'control',AbilityLevel,owner)
    debuffDuration = getApplyControlValue(shoot, debuffDuration)

    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = ability:GetAbilityDamageType()})
    if unit:HasModifier(debuffName) then
        debuffDuration = debuffDuration * 2
    end
    --ability:ApplyDataDrivenModifier(caster, unit, debuffName, {Duration = debuffDuration})
    unit:AddNewModifier(caster,ability,debuffName, {Duration = debuffDuration})

end


