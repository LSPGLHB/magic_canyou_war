require('skill_operation')
require('player_power')
function moveShoot(keys, shoot, skillBoomCallback, hitUnitCallBack)--skillBoomCallback：AOE技能爆炸形态，hitUnitCallBack：技能击中效果（单体伤害以及穿透使用）
	shoot.skillBoomCallback = skillBoomCallback
	shoot.hitUnitCallBack = hitUnitCallBack
	--local keys = shoot.keysTable
	--实现延迟满法魂效果
	--[[local shootHealthMax = shoot:GetHealth()
	local shootHealthSend = shootHealthMax * 0.8
	local shootHealthStep = shootHealthMax * 0.2 * shoot.speed / 10
	shoot:SetHealth(shootHealthSend)]]
	shoot.max_distance = shoot.max_distance_operation
	--local direction = shoot.direction
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),function ()
		if shoot.traveled_distance < shoot.max_distance then
			moveShootTimerRun(keys,shoot)
			--实现延迟满法魂效果
			--[[if shootHealthSend < shootHealthMax then
				shootHealthSend = shootHealthSend + shootHealthStep
				shoot:SetHealth(shootHealthSend)
			end]]
			--技能加强或减弱粒子效果实现
			powerShootParticleOperation(keys,shoot)--此处已刷新shoot.particleID
			shoot.traveled_distance = shoot.traveled_distance + shoot.speed
			--子弹命中目标
			local isHitType = shootHit(shoot)
			if shoot.energyHealth == 0 then
				shootKill(shoot)--子弹消失
				return nil
			end
			if shoot.energyHealth ~= 0 then 
				--击中目标，行程结束
				if isHitType == 1 then	
					if skillBoomCallback ~= nil then--触碰触发AOE（如果技能存在AOE）
						--print("over_hit")
						clearUnitsModifierByName(shoot, keys.shootAoeDebuff)
						skillBoomCallback(shoot) --启动AOE
						--shootKill(shoot)
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
			end
		else
			--超出射程没有命中
			if shoot.energyHealth ~= 0 then		
				print("over_distence")
				clearUnitsModifierByName(shoot, keys.shootAoeDebuff)
				if shoot.isAOE == 1 and skillBoomCallback ~= nil then --直达尽头发动AOE	
					--启动AOE
					skillBoomCallback(shoot)
				else
					shootSoundAndParticle(shoot, "miss")
					shootKill(shoot)--到达尽头消失
				end
				return nil
			end
		end
      return 0.02
     end,0)
end

function shootHit(shoot)
	local hitUnitCallBack = shoot.hitUnitCallBack
	local keys = shoot.keysTable
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
	--local isHitShoot = true
	shoot.tempHitUnits = {}
	local returnVal = 0--返回子弹碰撞后有什么反应的标志
	for k,unit in pairs(aroundUnits) do
		local lable = unit:GetUnitLabel() --该单位为技能子弹
		local unitTeam = unit:GetTeam()
		local unitHealth = unit.energyHealth
		local shootHealth = shoot.energyHealth
		--让不可多次碰撞的子弹跟目标只碰撞一次
		--子弹忽略自己，忽略发射者，忽略友军，忽略子弹(标签不是技能子弹)
		if shoot ~= unit and unit ~= caster and unitTeam ~= casterTeam and GameRules.skillLabel ~= lable  then
			isHitUnit = checkHitUnitToMark(shoot, isHitUnit, unit)
			--print("isHitUnit:",isHitUnit)
			--如果子弹有aoedebuff则需要做好准备做检测掉出aoe的单位
			if shoot.shootAoeDebuff ~= nil then
				table.insert(shoot.tempHitUnits, unit)
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
				reinforceEach(unit,shoot,nil)
				reinforceEach(shoot,unit,nil)
				local shootHealth = shoot:GetHealth()
				shootHealth = getApplyEnergyValue(shoot, shootHealth)
				local unitHealth = unit:GetHealth()
				unitHealth = getApplyEnergyValue(unit, unitHealth)
				
				local tempHealth = shootHealth - unitHealth
				print("shootHealth:",shootHealth,"-",unitHealth)
				if(tempHealth > 0) then
					energyBattleOperation(shoot, unit, tempHealth)
				else
					if tempHealth == 0 then
						energyBattleOperation(shoot, unit, tempHealth)
					end
					energyBattleOperation(unit, shoot, tempHealth)
				end
				returnVal = 0 
			else --如果碰到的不是子弹
				--返回中弹标记，出发中弹效果
				if  hitType == 1 then--击中单位停止
					returnVal = hitType
				end
				if hitType == 2 then --爆炸弹，--穿透弹,--并实现伤害
					--撞开击中单位
					if hitUnitCallBack ~= nil then--单体击中或会产生撞击
						--print("shoot3",shoot.power_lv,shoot.damage)
						hitUnitCallBack(shoot, unit)
						shootSoundAndParticle(shoot, "hit")
					end
					returnVal = hitType
				end
				if hitType == 3 then--直达指定位置，中途不命中单位
					returnVal = hitType
				end
			end
		else--相同队伍的触碰 --不搜索自己，标签为子弹
			if shoot ~= unit and casterTeam == unitTeam and GameRules.skillLabel == lable then--and isHitUnit then(不知道是不是可以删除)
				--shootPowerFlag用于标记该aoe是否已经起作用(此处标记应该在里面或者用数组标记所有接触过的子弹名字)
				checkHitAbilityToMark(shoot, unit)
			end
			--相同队伍的触碰 --不搜索自己，标签不为子弹
			if shoot ~= unit and casterTeam == unitTeam and GameRules.skillLabel ~= lable then
				checkHitTeamerRemoveDebuff(unit)
			end
		end
	end
	--处理掉出aoe的单位的debuff
	refreshBuffByArray(shoot,shoot.shootAoeDebuff)
	return returnVal
end

function energyBattleOperation(winBall, loseBall, tempHealth)
	print("energyBattleOperation:",tempHealth)
	local skillBoomCallback = loseBall.skillBoomCallback
	if tempHealth ~= 0 then
		if tempHealth < 0 then
			tempHealth = tempHealth * -1
		end
		winBall:SetHealth(tempHealth)--unit:SetHealth(0) --不能设为0，否则不能kill掉进程
	end
	loseBall.energyHealth = 0
	if loseBall.isMisfire == 1 then
		shootSoundAndParticle(loseBall, "misFire")
		shootKill(loseBall)
	end
	if loseBall.isMisfire ~= 1 then
		skillBoomCallback(loseBall)
		shootKill(loseBall)
	end
	--此处将被子弹控制的单位debuff去除
	clearUnitsModifierByName(loseBall,loseBall.shootAoeDebuff)
end

--记录击中技能目标
function checkHitAbilityToMark(shoot, unit)	
	local isHitFlag = true
	for i = 1, #shoot.hitShoot do
		if shoot.hitShoot[i] == unit then
			isHitFlag = false  --如果已经击中过就不再击中
			--print('checkHitAbilityToMark1')
			break
		end
	end
	if isHitFlag then
		table.insert(shoot.hitShoot, unit)
		reinforceEach(unit,shoot,nil) --加强运算记录在shoot.power_lv
	end

	local tempFlag = true
	for j = 1, #unit.hitShoot do
		if unit.hitShoot[j] == shoot then
			tempFlag = false  --如果已经击中过就不再击中
			--print('checkHitAbilityToMark2')
			break
		end
	end
	if tempFlag then
		table.insert(unit.hitShoot, shoot)
		reinforceEach(shoot,unit,nil) --加强运算记录在shoot.power_lv
	end
end

--记录击中单位目标到数组，返回标记（true：未击中过，false：已经击中过）
function checkHitUnitToMark(shoot, isHitFlag, unit)
	for i = 1, #shoot.hitUnits do
		--print("checkHitUnitToMark:",shoot.hitUnits[i],"=",unit)
		if shoot.hitUnits[i] == unit then	
			isHitFlag = false  --如果已经击中过就不再击中
			break
		end
	end
	if isHitFlag then
		--print("checkHitUnitToMarkININININI")
		table.insert(shoot.hitUnits, unit)
	end
	return isHitFlag
end

--清除单位的debuff
function clearUnitsModifierByName(shoot,modifierName)
	--print("clearUnitsModifierByName:", modifierName)
	if modifierName ~= nil then
		for i = 1, #shoot.hitUnits do
			local tempUnit = shoot.hitUnits[i]
			tempUnit:InterruptMotionControllers( true )
			tempUnit.shootFloatingAir = 0  --去掉浮空状态
			if tempUnit:HasModifier(modifierName) then
				tempUnit:RemoveModifierByName(modifierName)
			end
			FindClearSpaceForUnit( tempUnit, tempUnit:GetAbsOrigin(), false )
		end
	end
	shoot.hitUnits = {}
	shoot.tempHitUnits = {}
end

--去除掉出AOE范围的debuff，并更新数组
function refreshBuffByArray(shoot, modifierName)
	if modifierName ~= nil then
		--print("refreshBuffByArray")
		local oldArray = {}
		oldArray = shoot.hitUnits
		local newArray = {}
		newArray = shoot.tempHitUnits
		for i = 1, #oldArray do
			local flag = true
			for j = 1, #newArray do
				if oldArray[i] == newArray[j] then
					flag = false
				end
			end
			if flag then
				if oldArray[i]:HasModifier(modifierName) then
					oldArray[i]:RemoveModifierByName(modifierName)
				end
			end
		end
		shoot.hitUnits = shoot.tempHitUnits
	end
end

--命中友方移除debuff
function checkHitTeamerRemoveDebuff(unit)
	local sleepDebuffName = "modifier_sleep_debuff_datadriven"
	if unit:HasModifier(sleepDebuffName) then
		unit:RemoveModifierByName(sleepDebuffName)
		EmitSoundOn("magic_wake_up", unit)
	end
end

function moveShootTimerRun(keys,shoot)
	local shootTempPos = shoot:GetAbsOrigin()
	local speed = shoot.speed
	--print('moveShootTimerRun-speed:'..speed)
	local direction = shoot.direction
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

--初始化
function creatSkillShootInit(keys,shoot,owner,max_distance,direction)
	--print("creatSkillShootInit")
	if keys.hitType == nil then--hitType：1碰撞伤害，2穿透伤害，3直达指定位置，不命中单位
		keys.hitType = 1
	end
	shoot.hitType = keys.hitType
	if keys.isHitCallBack == nil then  --击中有效果，仅类型2穿透技能使用
		keys.isHitCallBack = 0
	end 
	shoot.isHitCallBack = keys.isHitCallBack
	if keys.isTrack == nil then
		keys.isTrack = 0
	end
	shoot.isTrack = keys.isTrack
	if keys.isMisfire == nil then
		keys.isMisfire = 0
	end
	shoot.isMisfire = keys.isMisfire
	if keys.isAOE == nil then
		keys.isAOE = 0
	end
	shoot.isAOE = keys.isAOE
	if keys.isMultipleHit == nil then
		keys.isMultipleHit = 0
	end 
	shoot.isMultipleHit = keys.isMultipleHit
	if keys.isControl == nil then
		keys.isControl = 0
	end 
	shoot.isControl = keys.isControl
	if keys.isDelay == nil then
		keys.isDelay = 0
	end 
	shoot.isDelay = keys.isDelay
	

	shoot.keysTable = keys
	shoot.soundCast = keys.soundCast
	shoot.soundPower = keys.soundPower
	shoot.soundWeak = keys.soundWeak
	shoot.soundMiss = keys.soundMiss
	shoot.soundMisfire = keys.soundMisfire
	shoot.soundHit = keys.soundHit
	shoot.soundBoom = keys.soundBoom
	shoot.soundDuration = keys.soundDuration

	shoot.particles_hit = keys.particles_hit
	shoot.particles_boom = keys.particles_boom
	shoot.particles_power = keys.particles_power
	shoot.particles_weak = keys.particles_weak
	shoot.particles_miss = keys.particles_miss
	shoot.particles_misfire = keys.particles_misfire

	shoot.cp = keys.cp

	local caster = keys.caster
	local ability = keys.ability
	local playerID = caster:GetPlayerID()
	shoot.aoe_duration = 0
	shoot.debuff_duration = 0
	shoot.direction = direction
	shoot.traveled_distance = 0 --初始化已经飞行的距离0
	shoot.shootHight = 100 --子弹高度
	shoot.isBreak = 0 --初始化不跳出
	shoot.owner = owner
	shoot:SetOwner(owner)
	shoot.unit_type = keys.unitType --用于计算克制和加强
	--print("unit_type"..shoot.unit_type)
	shoot.power_lv = 0 --用于实现克制和加强
	shoot.power_flag = 0 --用于实现克制和加强，标记粒子效果使用
	shoot.hitUnits = {}--用于记录命中的目标
	shoot.tempHitUnits = {}
	shoot.hitShoot = {} -- 用于记录击中过的子弹，避免重复运算
	shoot.matchUnitsID ={}--记录被什么技能加强的过
	shoot.matchAbilityLevel ={}--记录被什么等级技能加强的过
	--shoot.matchPower = 0 -- 克制加强系数
	shoot.abilityLevel = keys.AbilityLevel
	local AbilityLevel = shoot.abilityLevel
	--print("shoot:"..shoot.abilityLevel)


	shoot.aoe_radius = ability:GetSpecialValueFor("aoe_radius")
	if shoot.aoe_radius == 0 then
		shoot.aoe_radius = ability:GetSpecialValueFor("hit_range")
	end

	if keys.hitTargetDebuff ~= nil then
		shoot.hitTargetDebuff = keys.hitTargetDebuff
	end
	if keys.aoeTargetDebuff ~= nil then
		shoot.aoeTargetDebuff = keys.aoeTargetDebuff
	end
	if keys.shootAoeDebuff ~= nil then
		shoot.shootAoeDebuff = keys.shootAoeDebuff
	end
	
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
	local tempEnergy = getFinalValueOperation(playerID,abilityEnergy,energyBuffName,AbilityLevel,owner) 
	shoot.energy_bonus = tempEnergy - abilityEnergy
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
	--local damageMatchBuffName = 'damage_match'
	shoot.damage = getFinalValueOperation(playerID,damageBase,damageBuffName,AbilityLevel,owner)
	
	--print("damage",shoot.damage)
	--弹道速度
	local speedBase =  ability:GetSpecialValueFor("speed")
	local speedBuffName = 'ability_speed'
	shoot.speed = getFinalValueOperation(playerID,speedBase,speedBuffName,AbilityLevel,owner) * GameRules.speedConstant * 0.02

	--射程
	local rangeBase = max_distance
	local rangeBuffName = 'range'
	shoot.max_distance_operation = getFinalValueOperation(playerID,rangeBase,rangeBuffName,AbilityLevel,owner)

	--控制时间(在其他地方执行)
end

--施放技能时buff加强
function initDurationBuff(keys)
	setPlayerDurationBuffByName(keys,"vision",GameRules.playerBaseVision)
	setPlayerDurationBuffByName(keys,"speed",GameRules.playerBaseSpeed)
	setPlayerDurationBuffByName(keys,"health",GameRules.playerBaseHealth)
	setPlayerDurationBuffByName(keys,"mana",GameRules.playerBaseMana)
	setPlayerDurationBuffByName(keys,"mana_regen",GameRules.playerBaseManaRegen)
end

function shootSoundAndParticle(shoot, type)--type为nil只发声
	--local keys = shoot.keysTable
	local particlesName
	local soundName
	local soundDelay = 0
	if shoot.soundDurationDelay ~= nil then
		soundDelay = shoot.soundDurationDelay
	end
	if type ~= nil then
		if type ==	"miss" then
			particlesName = shoot.particles_miss
			soundName = shoot.soundMiss
		end
		if type == "misFire" then
			particlesName = shoot.particles_misfire
			soundName = shoot.soundMisfire
		end
		if type ==	"hit" then
			particlesName = shoot.particles_hit
			soundName = shoot.soundHit
		end
		if type ==	"boom" then  --击中效果，在本文件内做
			--particlesName = keys.particles_boom
			soundName = shoot.soundBoom
		end
		if type ==	"duration" then --持续效果，在本文件内做
			--particlesName = keys.particles_duration
			soundName = shoot.soundDuration
		end

	end
	--粒子效果
	if particlesName ~= nil then
		local newParticlesID = ParticleManager:CreateParticle(particlesName, PATTACH_ABSORIGIN_FOLLOW , shoot)
		ParticleManager:SetParticleControlEnt(newParticlesID, shoot.cp , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
	end
	--声音
	if soundName ~= nil then
		Timers:CreateTimer(soundDelay,function ()
			EmitSoundOn(soundName, shoot)
		end)
	end
end

--子弹消除
function shootKill(shoot)
	local keys = shoot.keysTable
	--消除粒子效果
	ParticleManager:DestroyParticle(shoot.particleID, true)
	--命中后动画持续时间
	shoot:ForceKill(true)
	Timers:CreateTimer(keys.particles_hit_dur,function ()
		--消除子弹以及中弹粒子效果
		shoot:AddNoDraw()
	end)
end


--击退单位处理
function beatBackPenetrateParticleOperation(keys,shoot)
	--中弹粒子效果
	ParticleManager:CreateParticle(keys.particles_hit, PATTACH_ABSORIGIN_FOLLOW, shoot) 
	--中弹声音
	EmitSoundOn(keys.sound_beak, shoot)
end

--击退单位
function beatBackUnit(keys,shoot,hitTarget,beatBackSpeed,beatBackDistance,isFirstBeat)
	local caster = keys.caster
	local ability = keys.ability
	--local powerLv = shoot.power_lv
	--hitTarget.power_lv = powerLv
	--击退距离受加强削弱影响(此处如果是带走的就有问题了)
	--beatBackDistance = powerLevelOperation(powerLv, beatBackDistance) 
	local hitTargetDebuff = keys.hitTargetDebuff
	--hitTarget:AddNewModifier(caster, ability, hitTargetDebuff, {Duration = control_time} )--需要调用lua的modefier
	ability:ApplyDataDrivenModifier(caster, hitTarget, hitTargetDebuff, {Duration = -1})
	beatBackPenetrateParticleOperation(keys,shoot)--中弹效果
	local shootPos = shoot:GetAbsOrigin()
	local tempShootPos  = Vector(shootPos.x,shootPos.y,0)--把撞击的高度降到0用于计算
	local targetPos= hitTarget:GetAbsOrigin()
	local tempTargetPos = Vector(targetPos.x ,targetPos.y ,0)--把目标的高度降到0用于计算
	local beatBackDirection =  (tempTargetPos - tempShootPos):Normalized()
	local interval = 0.02
	local acceleration = -3000 --加速度
	local V0 = beatBackSpeed * interval
	local speedmod = V0
	acceleration = acceleration * interval
	local bufferTempDis = hitTarget:GetPaddedCollisionRadius()
	local traveled_distance = 0
	local hitFlag = false
	if isFirstBeat then
		hitTarget.isFirstBeat = 1
	end
	--记录击退时间
	local beatTime = GameRules:GetGameTime()
	hitTarget.lastBeatBackTime = beatTime
	if hitTarget.shootFloatingAir == nil then 
		hitTarget.shootFloatingAir = 0
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"),
	function ()
		if traveled_distance < beatBackDistance and beatTime == hitTarget.lastBeatBackTime and hitTarget.shootFloatingAir == 0 then --如果击退时间没被更改继续执行（被其他技能击退则执行新的，旧的不再运行）
			local newPosition = hitTarget:GetAbsOrigin() +  beatBackDirection * speedmod -- Vector(beatBackDirection.x, beatBackDirection.y, 0) * speedmod
			speedmod = speedmod + acceleration * interval
			local groundPos = GetGroundPosition(newPosition, hitTarget)
			--中途可穿模，最后不能穿
			local tempLastDis = beatBackDistance - traveled_distance
			if tempLastDis > bufferTempDis then
				hitTarget:SetAbsOrigin(groundPos)
			else
				FindClearSpaceForUnit( hitTarget, groundPos, false )
			end
			traveled_distance = traveled_distance + speedmod
			--print("traveled_distance:"..speedmod.."="..traveled_distance)
			local remainDistance = beatBackDistance - traveled_distance

			hitFlag = checkSecondHit(keys,hitTarget,beatBackSpeed,remainDistance)

			if hitFlag then --速度传给撞击的单位，该单位停止
				traveled_distance = beatBackDistance
			end
		else
			hitTarget.isFirstBeat = 0
			hitTarget:InterruptMotionControllers( true )
			hitTarget:RemoveModifierByName(hitTargetDebuff)		
			--EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", caster)
			return nil
		end
		return interval
	end,0)
end

--击退的单位二次击退其他单位  (存在全角度搜索BUG，应该将搜索角度限制在90度内，待优化)
function checkSecondHit(keys,shoot,beatBackSpeed,remainDistance)
	local caster = keys.caster
	local ability = keys.ability
	local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local searchRadius = 100
	local hitFlag = false
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
		if(GameRules.skillLabel ~= lable and shoot ~= unit and casterTeam~=unitTeam and unit.isFirstBeat ~= 1 ) then --碰到的不是子弹,不是自己,不是发射技能的队伍,没被该技能碰撞过	and unit.beatBackFlag ~= 1	
			--unit.beatBackFlag = 1 --碰撞中，变成不可再碰撞状态
			beatBackUnit(keys,shoot,unit,beatBackSpeed,remainDistance,false)
			hitFlag = true
			return hitFlag
		end
	end
	return hitFlag
end

--带走被撞击单位
function takeAwayUnit(shoot,hitTarget)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local speed = shoot.speed 
	local direction = shoot.direction
	local shootAoeDebuff = keys.shootAoeDebuff
	local debuffTable = hitTarget:FindModifierByName(shootAoeDebuff)

	if hitTarget.shootFloatingAir == nil or hitTarget.shootFloatingAir == 0 then
		hitTarget.shootFloatingAir = 1   --浮空状态，不能被其他位移控制取代
	end
	--if hitTarget.shootFloatingAir == 1 then
		--print("debuffTable:", debuffTable)
		if debuffTable == nil then		
			ability:ApplyDataDrivenModifier(caster, hitTarget, shootAoeDebuff, {Duration = -1})
		end
		local newPosition = hitTarget:GetAbsOrigin() +  direction * speed 
		local groundPos = GetGroundPosition(newPosition, hitTarget)
		hitTarget:SetAbsOrigin(groundPos)
	--end	
end

--黑洞效果
function blackHole(shoot, G_Speed)
	local keys = shoot.keysTable
	local interval = 0.02
	G_Speed = G_Speed * interval
	local caster = keys.caster
	local ability = keys.ability
	local playerID = caster:GetPlayerID()
	local aoeTargetDebuff = shoot.aoeTargetDebuff 
    local aoe_radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") --AOE持续作用范围
    --print("blackHoleDuration:"..shoot.aoe_duration)
	local aoe_duration = shoot.aoe_duration
    local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	--启动计时器，时间到了结束debuff销毁子弹
	Timers:CreateTimer(aoe_duration,function ()
		--print("timeOver")
		shoot.isKill = 1
		clearUnitsModifierByName(shoot,aoeTargetDebuff)
		return nil
	end)
	--管理移动效果计时器
    Timers:CreateTimer(0,function ()
		--子弹被销毁的话结束计时器进程
		if shoot.isKill == 1 then
			return nil
		end
		local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
        for k,unit in pairs(aroundUnits) do
            local unitTeam = unit:GetTeam()
            local unitHealth = unit.energyHealth
            local lable = unit:GetUnitLabel()
            --只作用于敌方，或石头单位
            if casterTeam ~= unitTeam or lable == GameRules.stoneLabel then
				local shootPos = shoot:GetAbsOrigin()
				local unitPos = unit:GetAbsOrigin()
				local vectorDistance = Vector(shootPos.x,shootPos.y,0) - Vector(unitPos.x,unitPos.y,0)
				local G_Direction = (vectorDistance):Normalized()
				local G_Distance = (vectorDistance):Length2D()
				local newPosition = unitPos +  G_Direction * G_Speed
				local groundPos = GetGroundPosition(newPosition, unit)
				unit:SetAbsOrigin(groundPos)
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 then
                checkHitAbilityToMark(shoot, unit)
            end
        end
        return interval
	end)
	--管理buff的计时器
	local buffInterval = 0.1
	Timers:CreateTimer(0,function ()
		--子弹被销毁的话结束计时器进程
		if shoot.isKill == 1 then
			return nil
		end
		shoot.tempHitUnits = {}
		local aroundUnits = FindUnitsInRadius(casterTeam, 
										position,
										nil,
										aoe_radius,
										DOTA_UNIT_TARGET_TEAM_BOTH,
										DOTA_UNIT_TARGET_ALL,
										0,
										0,
										false)
		for k,unit in pairs(aroundUnits) do
			local unitTeam = unit:GetTeam()
			--local unitHealth = unit.energyHealth
			local lable = unit:GetUnitLabel()
			--只作用于敌方,非技能单位
			if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
				local newFlag = checkHitUnitToMark(shoot, true, unit)--用于技能结束时清理debuff	
				if newFlag then  --新加入的加上buff
					ability:ApplyDataDrivenModifier(caster, unit, aoeTargetDebuff, {Duration = -1})
				end
				table.insert(shoot.tempHitUnits, unit)
			end
		end
		refreshBuffByArray(shoot,shoot.aoeTargetDebuff)
		return buffInterval
	end)
end



--控制效果
function controlTurn(caster, shoot, controlDuration)
	local timeCount = 0
	local interval = 0.1
	caster:SetContextThink( DoUniqueString( "updateStoneSpear" ), function ( )
	--GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"), function ()
		-- Interrupted
		if not caster:HasModifier( casterBuff ) then
			return nil
		end
		--朝向为0-360
		local shootAngles = shoot:GetAnglesAsVector().y
		local casterAngles	= caster:GetAnglesAsVector().y
		local Steering = 1
		if shootAngles ~= casterAngles then
			local resultAngle = casterAngles - shootAngles
			resultAngle = math.abs(resultAngle)
			if resultAngle > 180 then
				if shootAngles < casterAngles then
					Steering = -1
				end
			else
				if shootAngles > casterAngles then
					Steering = -1
				end
			end
			local currentDirection =  shoot:GetForwardVector()
			local newX2 = math.cos(math.atan2(currentDirection.y, currentDirection.x) + angleRate * Steering)
			local newY2 = math.sin(math.atan2(currentDirection.y, currentDirection.x) + angleRate * Steering)
			local tempDirection = Vector(newX2, newY2, currentDirection.z)
			shoot:SetForwardVector(tempDirection)
			shoot.direction = tempDirection
		end

		if timeCount < controlDuration then
			timeCount = timeCount + interval
			return interval
		else
			return nil
		end
	end, 0)
end

--角度计算添加buff,满足条件返回true
function setDebuffByFaceAngle(shoot, unit, faceAngle)
    local blindDirection = shoot:GetAbsOrigin()  - unit:GetAbsOrigin()
    local blindRadian = math.atan2(blindDirection.y, blindDirection.x) * 180 
    local blindAngle = blindRadian / math.pi
    --单位朝向是0-360，相对方向是0~180,0~-180，需要换算
    if blindAngle < 0 then
        blindAngle = blindAngle + 360
    end
    local victimAngle = unit:GetAnglesAsVector().y
    local resultAngle = blindAngle - victimAngle
    resultAngle = math.abs(resultAngle)
	--print("faceAngle:"..victimAngle..">>>"..blindAngle)
	--print("resultAngle:"..resultAngle)
    if resultAngle > 180 then
        resultAngle = 360 - resultAngle
    end
	--print("resultAngle:"..resultAngle)
    if faceAngle > resultAngle then --固定角度减视野
		return true
    end
	return false
end

--持续aoe伤害执行
function durationAOEDamage(shoot, interval, damageCallbackFunc)
	local keys = shoot.keysTable
    local caster = keys.caster
    --local playerID = caster:GetPlayerID()
    --local AbilityLevel = shoot.abilityLevel
    local radius = shoot.aoe_radius--ability:GetSpecialValueFor("aoe_radius") --AOE持续作用范围
	local duration = shoot.aoe_duration
    local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	shootSoundAndParticle(shoot, "duration")
	local timeCount = 0 
    Timers:CreateTimer(0,function ()   
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
            local unitHealth = unit.energyHealth
            local lable = unit:GetUnitLabel()
            
            --只作用于敌方,非技能单位
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then  
				damageCallbackFunc(shoot, unit, interval)
            end
            --如果是技能则进行加强或减弱操作，AOE对所有队伍技能有效
            if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
                checkHitAbilityToMark(shoot, unit)
            end
        end

		timeCount = timeCount + interval
		if timeCount >= duration then
			EmitSoundOn("magic_voice_stop", shoot)
			--shoot:ForceKill(true)
			--shoot:AddNoDraw()
			return nil
		end   
        return interval
    end)  
	
	shootKill(shoot)
end

--普通持续AOE伤害实现
function damageCallback(shoot, unit, interval)
	local keys = shoot.keysTable
    local ability = keys.ability
    local duration = shoot.aoe_duration
    local damageTotal = getApplyDamageValue(shoot)
    local damage = damageTotal / (duration / interval)   
    ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end


--判断条件，角度是否触发buff
function durationAOEJudgeByAngleAndTime(shoot, faceAngle, judgeTime, callback)
	local keys = shoot.keysTable
    local caster = keys.caster
	--local ability = keys.ability
	local aoe_radius = shoot.aoe_radius --AOE爆炸范围
    local aoe_duration = shoot.aoe_duration
	local position = shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
    local interval = 0.1
    Timers:CreateTimer(aoe_duration,function ()
		shoot.isKill = 1
        for i = 1, #shoot.hitUnits  do
            local unit = shoot.hitUnits[i]
            unit.visionDownLightBallTime = 0
        end
		return nil
	end)
    Timers:CreateTimer(0,function ()   
        if shoot.isKill == 1 then
			return nil
		end
        local aroundUnits = FindUnitsInRadius(casterTeam,
                                            position,
                                            nil,
                                            aoe_radius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)
        for k,unit in pairs(aroundUnits) do
            local unitTeam = unit:GetTeam()
            --local unitHealth = unit.energyHealth
            local lable = unit:GetUnitLabel()
            --只作用于敌方,非技能单位
            if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel  then    
                checkHitUnitToMark(shoot, true, unit) --用于事后消除debuff
                local angelFlag = true 
                if faceAngle ~= nil then
                    angelFlag = setDebuffByFaceAngle(shoot, unit, faceAngle)
                end
                if judgeTime == nil then
                    judgeTime = 0
                end
                if angelFlag then
                    if unit.visionDownLightBallTime == nil then
                        unit.visionDownLightBallTime = 0
                    end
                    unit.visionDownLightBallTime = unit.visionDownLightBallTime + interval    
                    --print("vision_time:"..unit.visionDownLightBallTime)
                    if unit.visionDownLightBallTime >= judgeTime then
						callback(shoot,unit)
                    end
                end
            end
        end 
        return interval
    end)
end

--穿透类的处理
function passAOEOperation(shoot, unit, passOperationCallback)
	shootSoundAndParticle(shoot, "pass")
	passOperationCallback(shoot, unit)
end

--非持续AOE伤害以及触发效果
function boomAOEOperation(shoot, AOEOperationCallback)
	local keys = shoot.keysTable
	local caster = keys.caster
	local radius = shoot.aoe_radius --AOE爆炸范围
	shootSoundAndParticle(shoot, "boom")
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
		local unitHealth = unit.energyHealth
		local lable = unit:GetUnitLabel()
		--只作用于敌方,非技能单位
		if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
			AOEOperationCallback(shoot, unit)
		end
		--如果是技能则进行加强或减弱操作
		if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
            checkHitAbilityToMark(shoot, unit)
		end
	end 
	shootKill(shoot)
end

--扩散类AOE伤害以及触发效果
function diffuseBoomAOEOperation(shoot, AOEOperationCallback)
	local keys = shoot.keysTable
	local caster = keys.caster
	local ability = keys.ability
	local diffuseSpeed = ability:GetSpecialValueFor("diffuse_speed")
	local radius = shoot.aoe_radius --AOE爆炸范围
	local position=shoot:GetAbsOrigin()
	local casterTeam = caster:GetTeam()
	local diffuseRadius = 0
	local interval = 0.1
	shootSoundAndParticle(shoot, "boom")
    Timers:CreateTimer(0,function ()   
		diffuseRadius = diffuseRadius + diffuseSpeed * GameRules.speedConstant * interval
		--print("diffuseRadius:"..diffuseRadius)
		if diffuseRadius >= radius then
			return nil
		end
		local aroundUnits = FindUnitsInRadius(casterTeam, 
											position,
											nil,
											diffuseRadius,
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
			if casterTeam ~= unitTeam and lable ~= GameRules.skillLabel then
				AOEOperationCallback(shoot, unit)
			end
			--如果是技能则进行加强或减弱操作
			if lable == GameRules.skillLabel and unitHealth ~= 0 and unit ~= shoot then
				checkHitAbilityToMark(shoot, unit)
			end
		end 
		return interval
	end)
	shootKill(shoot)
end