require('skill_operation')
require('player_power')
function moveShoot(keys, shoot, particleID, skillBoomCallback, hitUnitCallBack)--skillBoomCallback：技能爆炸形态，hitUnitCallBack：技能中途击中效果（穿透使用）
	--print('moveShoot1:'..shoot.speed)
	--影响弹道的buff--测试速度调整可删除
	shoot.speed = skillSpeedOperation(keys,shoot.speed)
	--print('moveShoot2:'..shoot.speed)
	--实现延迟满法魂效果

	local shootHealthMax = shoot:GetHealth()
	local shootHealthSend = shootHealthMax * 0.8
	local shootHealthStep = shootHealthMax * 0.2 * shoot.speed / 10
	shoot:SetHealth(shootHealthSend)


	shoot.max_distance = shoot.max_distance_operation
	--local direction = shoot.direction

	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function ()
		if shoot.traveled_distance < shoot.max_distance then
			moveShootTimerRun(keys,shoot)
			--实现延迟满法魂效果
			if shootHealthSend < shootHealthMax then
				shootHealthSend = shootHealthSend + shootHealthStep
				shoot:SetHealth(shootHealthSend)
			end
			--技能加强或减弱粒子效果实现
			powerShootParticleOperation(keys,shoot,particleID)
			shoot.traveled_distance = shoot.traveled_distance + shoot.speed
			--子弹命中目标
			local isHitType = shootHit(keys, shoot, isHitType, hitUnitCallBack)
			--击中目标，行程结束
			if isHitType == 1 then		
				if skillBoomCallback ~= nil then
					skillBoomCallback(keys,shoot,particleID) --到达尽头启动AOE
				end
				return nil
			end
			--击中目标，行程继续
			if isHitType == 2 then
				return 0.02
			end
			--到达指定位置，不命中目标
			if isHitType == 3 then
				return 0.02
			end

			--子弹法魂为0，法魂被击破，行程结束
			if shoot.isHealth == 0  then
				if shoot then
					skillBoomCallback(keys,shoot,particleID) 
					return nil
				end
			end
		else
			--超出射程没有命中
			if shoot then		
				if keys.isAOE == 1 and skillBoomCallback ~= nil then --直达尽头发动AOE	
					skillBoomCallback(keys,shoot,particleID) --启动AOE
				else
					if particleID then
						ParticleManager:DestroyParticle(particleID, true)
					end
					shootKill(shoot)--到达尽头消失
				end
				return nil
			end
		end
      return 0.02
     end,0)
end


function shootHit(keys, shoot,hitType, hitUnitCallBack)
	local caster = keys.caster
	local ability = keys.ability
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	--默认不击退
	if keys.isBeatBack == nil then
		keys.isBeatBack = 0
	end
	local hitType = keys.hitType
	--local PlayerID = caster:GetPlayerID() PlayerResource:GetTeam(PlayerID) print("team========:"..team) print("goodguy2:"..DOTA_TEAM_GOODGUYS) print("badguy3:"..DOTA_TEAM_BADGUYS) print("noteam5:"..DOTA_TEAM_NOTEAM) print("CUSTOM_1=6:"..DOTA_TEAM_CUSTOM_1) print("CUSTOM_2=7:"..DOTA_TEAM_CUSTOM_2)
	--寻找目标
	local searchRadius = ability:GetSpecialValueFor("hit_range")
	local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										searchRadius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
	local isHitUnit = true   --初始化设单位为可击中状态
	local searchUnits = {}
	local returnVal = 0
	for k,unit in pairs(aroundUnits) do
		local lable = unit:GetUnitLabel() --该单位为技能子弹
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.isHealth
		local shootHealth = shoot.isHealth
		if shoot.hitUnits == nil then
			shoot.hitUnits = {}
		end
		--让不可多次碰撞的子弹跟目标只碰撞一次
		--子弹忽略自己，忽略发射者，忽略友军，忽略子弹(标签不是技能子弹)
		if shoot ~= unit and unit ~= caster and unitTeam ~= casterTeam and GameRules.skillLabel ~= lable  then
			for i = 1, #shoot.hitUnits do
				if shoot.hitUnits[i] == unit then
					isHitUnit = false  --如果已经击中过就不再击中
					break
				end
			end
			if isHitUnit then
				table.insert(shoot.hitUnits,unit)
			end
		end
		if keys.isMultipleHit == 1 then --可多次碰撞的技能(穿透弹道)
			isHitUnit = true
		end
		--遇到敌人实现伤害并返回撞击反馈
		if(casterTeam ~= unitTeam and shootHealth ~= 0 and isHitUnit) then --触碰到的不是自家队伍，且自身法魂不为0，是否实现撞击
			if(GameRules.skillLabel == lable and unitHealth ~= 0) then --如果碰到的是子弹，且法魂不为0：此处需要比拼法魂大小
				--获取触碰双方的属性--print("shoot-nuit-Type:",shoot.unit_type,unit.unit_type)
				--法魂计算过程(还需加入克制计算)
				local tempHealth = shoot:GetHealth() - unit:GetHealth()
				if(tempHealth > 0) then
					shoot:SetHealth(tempHealth)
					--unit:SetHealth(0) --不能设为0，否则不能kill掉进程
					unit.isHealth = 0
					shootKill(unit)--直接kill掉进程
				else
					if tempHealth == 0 then
						unit.isHealth = 0
					end
					--shoot:SetHealth(0.1)
					shoot.isHealth = 0
					shootKill(shoot)
					tempHealth = tempHealth * -1
					unit:SetHealth(tempHealth)
				end
				returnVal = 0
			else --如果碰到的不是子弹
				--返回中弹标记，出发中弹效果
				if hitType == 1 or hitType == 2 then --爆炸弹，--穿透弹,--并实现伤害
					--撞开击中单位
					if hitUnitCallBack ~= nil then--会产生撞击
						--print("shoot3",shoot.power_lv,shoot.damage)
						hitUnitCallBack(keys, shoot, unit)
					end
					returnVal = hitType
				end
				if hitType == 3 then--直达指定位置，中途不命中单位
					returnVal = hitType
				end
			end
		else--相同队伍的触碰    	 
			 --不搜索自己，标签为子弹
			if shoot ~= unit and GameRules.skillLabel == lable and isHitUnit then
				--fireStormFlag用于标记该aoe是否已经起作用
				if unit.shootPowerFlag == nil  then
					reinforceEach(unit,shoot,nil) --加强运算记录在shoot.power_lv
					unit.shootPowerFlag = 1;--与unit.power_flag是否同一个东西？？？？
				end
			end
		end
	end
	return returnVal
end

function moveShootTimerRun(keys,shoot)
	local shootTempPos = shoot:GetAbsOrigin()
	local speed = shoot.speed
	--print('moveShootTimerRun-speed:'..speed)
	local direction = shoot.direction
	--[[此处已经时刻实时同步方向
	if keys.isControl == 1 then
		if shoot.direction ~= nil then 
			direction = shoot.direction
		end	
	end]]
	--此处追踪状态，只知道追踪，其他不管
	if keys.isTrack == 1 then
		direction = (keys.trackUnit:GetAbsOrigin() - Vector(shootTempPos.x, shootTempPos.y, 0)):Normalized()
	end

	local newPos = shootTempPos + direction * speed
	local groundPos = GetGroundPosition(newPos, shoot)
	local shootPos = Vector(groundPos.x, groundPos.y, groundPos.z + shoot.shootHight)
	--FindClearSpaceForUnit( shoot, groundPos, false )--飞行单位可以穿地形不用这个
	shoot:SetAbsOrigin(shootPos)
end

--先
function creatSkillShootInit(keys,shoot,owner,max_distance,direction)
	print("creatSkillShootInit")

	if keys.hitType == nil then--hitType：1碰撞伤害，2穿透伤害，3直达指定位置，不命中单位
		keys.hitType = 1
	end
	if keys.hitType == nil then--hitType：1爆炸，2穿透，3直达指定位置，不命中单位
		keys.hitType = 1
	end
	if keys.isHitCallBack == nil then  --击中有效果，仅类型2穿透技能使用
		keys.isHitCallBack = 0
	end 
	if keys.isTrack == nil then
		keys.isTrack = 0
	end
	if keys.isAOE == nil then
		keys.isAOE = 0
	end
	if keys.canShotDown == nil then
		keys.canShotDown = 0
	end 
	if keys.isMultipleHit == nil then
		keys.isMultipleHit = 0
	end 
	if keys.isControl == nil then
		keys.isControl = 0
	end 

	local caster = keys.caster
	local ability = keys.ability
	local playerID = caster:GetPlayerID()

	if(shoot.control == nil) then
		shoot.control = 0
	end
	shoot.direction = direction
	shoot.traveled_distance = 0 --初始化已经飞行的距离0
	shoot.shootHight = 100 --子弹高度
	shoot.isBreak = 0 --初始化不跳出
	shoot.owner = owner
	shoot:SetOwner(owner)
	shoot.unit_type = keys.unitType --用于计算克制和加强
	print("unit_type"..shoot.unit_type)
	shoot.power_lv = 0 --用于实现克制和加强
	shoot.power_flag = 0 --用于实现克制和加强
	shoot.hitUnits = {}--用于记录命中的目标
	shoot.matchUnitsID ={}--记录被什么技能加强的过
	shoot.matchAbilityLevel ={}--记录被什么等级技能加强的过
	--shoot.matchPower = 0 -- 克制加强系数
	shoot.abilityLevel = keys.AbilityLevel
	local AbilityLevel = keys.AbilityLevel
	--print("shoot:"..shoot.abilityLevel)

	--已处理
	--蓝耗
	
	local manaCost = ability:GetManaCost(1)
	local manaCostBuffName = 'mana_cost'
	shoot.mana_cost_bonus = getFinalValueOperation(playerID,manaCost,manaCostBuffName,AbilityLevel,owner) - manaCost
	--caster:ReduceMana(50.0)--(shoot.mana_cost_bonus)-- 此方法23.4.21更新后不能使用
	caster:SpendMana(shoot.mana_cost_bonus, caster)

	--法魂
	local abilityEnergy = shoot:GetHealth()
	local energyBuffName = 'energy'
	local energyMatchBuffName = 'energy_match'
	--shoot.energy_bonus = finalValueOperation(abilityEnergy,PlayerPower[playerID]['player_energy_'..AbilityLevel],PlayerPower[playerID]['player_energy_'..AbilityLevel..'_precent_base'],PlayerPower[playerID]['player_energy_'..AbilityLevel..'_precent_final']) - abilityEnergy
	--shoot.energy_match_bonus = finalValueOperation(abilityEnergy,PlayerPower[playerID]['player_energy_match_'..AbilityLevel],PlayerPower[playerID]['player_energy_match_'..AbilityLevel..'_precent_base'],PlayerPower[playerID]['player_energy_match_'..AbilityLevel..'_precent_final']) - abilityEnergy
	shoot.energy_bonus = getFinalValueOperation(playerID,abilityEnergy,energyBuffName,AbilityLevel,owner)
	shoot.energy_match_bonus = getFinalValueOperation(playerID,shoot.energy_bonus,energyMatchBuffName,AbilityLevel,owner)
	shoot:AddAbility('ability_health_control'):SetLevel(1)
	shoot:RemoveModifierByName('modifier_health_debuff')
    shoot:SetModifierStackCount('modifier_health_buff', shoot, shoot.energy_bonus)
	shoot:RemoveAbility('ability_health_control')
	--print("abilityEnergy",abilityEnergy)
	--print("energy_bonus",shoot.energy_bonus)

	--直接可用数据
	--伤害
	local damageBase = ability:GetSpecialValueFor("damage")
	local damageBuffName = 'damage'
	local damageMatchBuffName = 'damage_match'
	--shoot.damage = finalValueOperation(damageBase, PlayerPower[playerID]['player_damage_'..AbilityLevel],PlayerPower[playerID]['player_damage_'..AbilityLevel..'_precent_base'], PlayerPower[playerID]['player_damage_'..AbilityLevel..'_precent_final'])
	--shoot.damage_match = finalValueOperation(shoot.damage, PlayerPower[playerID]['player_damage_match_'..AbilityLevel],PlayerPower[playerID]['player_damage_match_'..AbilityLevel..'_precent_base'] ,PlayerPower[playerID]['player_damage_match_'..AbilityLevel..'_precent_final'])
	shoot.damage = getFinalValueOperation(playerID,damageBase,damageBuffName,AbilityLevel,owner)
	shoot.damage_match = getFinalValueOperation(playerID,shoot.damage,damageMatchBuffName,AbilityLevel,owner)
	--print("damage",shoot.damage)
	--弹道速度
	local speedBase =  ability:GetSpecialValueFor("speed")
	local speedBuffName = 'ability_speed'
	--shoot.speed = finalValueOperation(speedBase,PlayerPower[playerID]['player_ability_speed_'..AbilityLevel],PlayerPower[playerID]['player_ability_speed_'..AbilityLevel..'_precent_base'],PlayerPower[playerID]['player_ability_speed_'..AbilityLevel..'_precent_final'])
	shoot.speed = getFinalValueOperation(playerID,speedBase,speedBuffName,AbilityLevel,owner) * 0.02

	--射程
	local rangeBase = max_distance
	local rangeBuffName = 'range'
	shoot.max_distance_operation = getFinalValueOperation(playerID,rangeBase,rangeBuffName,AbilityLevel,owner)


	--半成品（还需现场加工,缺基础数据）
	--控制时间
	local controlBase = shoot.control
	local contrilBuffName = 'control'
	shoot.control = getFinalValueOperation(playerID,controlBase,contrilBuffName,AbilityLevel,owner)
	--[[
	shoot.control_bonus = PlayerPower[playerID]['player_control_'..AbilityLevel]
	shoot.control_precent_base_bonus = PlayerPower[playerID]['player_control_'..AbilityLevel..'_precent_base']
	shoot.control_precent_final_bonus = PlayerPower[playerID]['player_control_'..AbilityLevel..'_precent_final']
	
	shoot.control_match_bonus = PlayerPower[playerID]['player_control_match_'..AbilityLevel]
	shoot.control_match_precent_base_bonus = PlayerPower[playerID]['player_control_match_'..AbilityLevel..'_precent_base']
	shoot.control_match_precent_final_bonus = PlayerPower[playerID]['player_control_match_'..AbilityLevel..'_precent_final']
	]]
	
end

--施放技能时buff加强
function initDurationBuff(keys)
	setPlayerDurationBuffByName(keys,"vision",GameRules.playerBaseVision)
	setPlayerDurationBuffByName(keys,"speed",GameRules.playerBaseSpeed)
	setPlayerDurationBuffByName(keys,"health",GameRules.playerBaseHealth)
	setPlayerDurationBuffByName(keys,"mana",GameRules.playerBaseMana)
	setPlayerDurationBuffByName(keys,"mana_regen",GameRules.playerBaseManaRegen)
end




function shootKill(shoot)
	shoot:ForceKill(true)
	shoot:AddNoDraw()
end

function clearUnitsModifierByName(shoot,modifierName)
	for i = 1, #shoot.hitUnits  do
		local unit = shoot.hitUnits[i]
		unit:InterruptMotionControllers( true )
		unit:RemoveModifierByName(modifierName)
	end
end

--击退单位
function beatBackUnit(keys,shoot,hitTarget,beatBackDistance,beatBackSpeed,canSecHit)--canSecHit:是否能二次撞击1为能
	local caster = keys.caster
	local ability = keys.ability
	local powerLv = shoot.power_lv
	hitTarget.power_lv = powerLv
	--击退距离受加强削弱影响(此处如果是带走的就有问题了)
	--beatBackDistance = powerLevelOperation(powerLv, beatBackDistance) 
	local hitTargetDebuff = keys.hitTargetDebuff
	--hitTarget:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = control_time} )--需要调用lua的modefier
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})
	shootPenetrateParticleOperation(keys,shoot)--中弹效果
	local shootPos = shoot:GetAbsOrigin()
	local tempShootPos  = Vector(shootPos.x,shootPos.y,0)--把撞击的高度降到0用于计算
	local targetPos= hitTarget:GetAbsOrigin()
	local tempTargetPos = Vector(targetPos.x ,targetPos.y ,0)--把目标的高度降到0用于计算
	local beatBackDirection =  (tempTargetPos - tempShootPos):Normalized()
	local interval = 0.02
	local speedmod = beatBackSpeed * interval
	local bufferTempDis = hitTarget:GetPaddedCollisionRadius()
	local traveled_distance = 0
	--记录击退时间
	local beatTime = GameRules:GetGameTime()
	hitTarget.lastBeatBackTime = beatTime
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
	function ()
		if traveled_distance < beatBackDistance and beatTime == hitTarget.lastBeatBackTime then --如果击退时间没被更改继续执行
			local newPosition = hitTarget:GetAbsOrigin() +  beatBackDirection * speedmod -- Vector(beatBackDirection.x, beatBackDirection.y, 0) * speedmod
			local groundPos = GetGroundPosition(newPosition, hitTarget)
			--中途可穿模，最后不能穿
			local tempLastDis = beatBackDistance - traveled_distance
			if tempLastDis > bufferTempDis then
				hitTarget:SetAbsOrigin(groundPos)
			else
				FindClearSpaceForUnit( hitTarget, groundPos, false )
			end
			traveled_distance = traveled_distance + speedmod
			if canSecHit == 1 then --进入第二次撞击
				checkSecondHit(keys,hitTarget)
			end
		else
			hitTarget:InterruptMotionControllers( true )
			hitTarget:RemoveModifierByName(hitTargetDebuff)		
			hitTarget.beatBackFlag = 0  --变回可碰撞状态
			--EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", caster)
			return nil
		end
		return interval
	end,0)
end

--击退的单位二次击退其他单位
function checkSecondHit(keys,shoot)
	local caster = keys.caster
	local ability = keys.ability
	local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local searchRadius = 100
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
		--local name = unit:GetContext("name")
		local lable = unit:GetUnitLabel()
		local casterTeam = caster:GetTeam()
		local unitTeam = unit:GetTeam()
		if(GameRules.skillLabel ~= lable and shoot ~= unit and casterTeam~=unitTeam and unit.beatBackFlag ~= 1) then --碰到的不是子弹,不是自己,不是发射技能的队伍,没被该技能碰撞过		
			unit.beatBackFlag = 1 --碰撞中，变成不可再碰撞状态
			local beatBackSpeed = ability:GetSpecialValueFor("beat_back_speed")
			local beatBackDistance = ability:GetSpecialValueFor("beat_back_two")
			beatBackUnit(keys,shoot,unit,beatBackDistance,beatBackSpeed,0,0)
		end
	end
end

--带走被撞击单位
function takeAwayUnit(keys,shoot,hitTarget)
	local caster = keys.caster
	local ability = keys.ability
	local speed = shoot.speed 
	local direction = shoot.direction
	local hitTargetDebuff = keys.hitTargetDebuff
	local debuffTable = hitTarget:FindModifierByName(hitTargetDebuff)
	if debuffTable == nil then
		ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})
	end
	local newPosition = hitTarget:GetAbsOrigin() +  direction * speed 
	local groundPos = GetGroundPosition(newPosition, hitTarget)
	hitTarget:SetAbsOrigin(groundPos)
end

--黑洞效果
function blackHole(keys, shoot, unit, modifierDebuffName, interval, tempTimer, blackHoleDuration)
	local caster = keys.caster
	local ability = keys.ability
	local debuffTable = unit:FindModifierByName(modifierDebuffName)
	if debuffTable == nil then
		ability:ApplyDataDrivenModifier(caster, unit, modifierDebuffName, {Duration = -1})
	end
	local G_Speed = ability:GetSpecialValueFor("G_speed")
	G_Speed = G_Speed * interval
	local shootPos = shoot:GetAbsOrigin()
	local unitPos = unit:GetAbsOrigin()
	local vectorDistance = Vector(shootPos.x,shootPos.y,0) - Vector(unitPos.x,unitPos.y,0)
	local G_Direction = (vectorDistance):Normalized()
	local G_Distance = (vectorDistance):Length2D()
	if G_Distance < 50 then --此处还需调整
		G_Speed = G_Distance
	end
	local newPosition = unitPos +  G_Direction * G_Speed
	local groundPos = GetGroundPosition(newPosition, unit)
	unit:SetAbsOrigin(groundPos)
	if tempTimer >= blackHoleDuration then
		FindClearSpaceForUnit( unit, groundPos, false )
	end
end

--未注入灵魂
--[[
function aoeDuration(keys,shoot,getFlagCallBack)
    local caster = keys.caster
	local ability = keys.ability
    local visionDebuff = keys.modifierDebuffName
    local aoe_duration_radius = ability:GetSpecialValueFor("aoe_duration_radius") --AOE持续作用范围
    local aoe_duration = ability:GetSpecialValueFor("aoe_duration") --AOE持续作用时间
    local debuff_duration = ability:GetSpecialValueFor("debuff_duration") --debuff持续时间
	
    local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local tempTimer = 0
    local particleBoom = staticStromRenderParticles(keys,shoot)
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
			--local theFlag = getFlagCallBack(keys,shoot, unit )
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
                local faceAngle = ability:GetSpecialValueFor("face_angle")
                local blindDirection = shoot:GetAbsOrigin()  - unit:GetAbsOrigin()
                local blindRadian = math.atan2(blindDirection.y, blindDirection.x) * 180 
                local blindAngle = blindRadian / math.pi
                --单位朝向是0-360，相对方向是0-180,-180-0，需要换算
                if blindAngle < 0 then
                    blindAngle = blindAngle + 360
                end
                local victimAngle = unit:GetAnglesAsVector().y
                local resultAngle = blindAngle - victimAngle
                resultAngle = math.abs(resultAngle)
                if resultAngle > 180 then
                    resultAngle = 360 - resultAngle
                end
                if faceAngle > resultAngle then --固定角度减视野
                    ability:ApplyDataDrivenModifier(caster, unit, visionDebuff, {Duration = debuff_duration})
                end
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 then
                reinforceEach(unit,shoot,nil)
            end
        end
        if tempTimer < aoe_duration then
            tempTimer = tempTimer + 0.1
            return 0.1
        else 
            ParticleManager:DestroyParticle(particleBoom, true)
            EmitSoundOn("Hero_Disruptor.StaticStorm", shoot)	
            shoot:ForceKill(true)
            shoot:AddNoDraw()
            return nil
        end
	end)
end

]]
