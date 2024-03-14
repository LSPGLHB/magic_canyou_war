require('shoot_init')
require('scene/game_Stone')
--魔塔初始化(主塔)（魔法石初始化）
function initMagicTower()
    if  towerMainArray ~= nil then
        for _, unit in pairs(towerMainArray[DOTA_TEAM_GOODGUYS]) do
            if unit ~= nil and unit.alive == 1 and unit:IsAlive() then
                unit:ForceKill(true)
                unit:AddNoDraw()
            end
        end

        for _, unit in pairs(towerMainArray[DOTA_TEAM_BADGUYS]) do
            if unit ~= nil and unit.alive == 1 and unit:IsAlive() then
                unit:ForceKill(true)
                unit:AddNoDraw()
            end
        end
    end

    towerDefenceSearch = {600,600,600}
    towerDefenceRadius = {850,850,850}
    towerDefenceDiffuseSpeed = {350,350,350}
    --towerDefenceDebuffEffect = {50,50,50}
    towerDefenceDebuffDuration = {5,5,5}
    towerDefenceCooldown = {7,7,7}
    towerDefenceDamage = {5,5,5}
    towerDefenceLevel = {}
    towerDefenceLevel[DOTA_TEAM_GOODGUYS] = 1
    towerDefenceLevel[DOTA_TEAM_BADGUYS] = 1

    towerScale = {0.5,0.7,0.9}
    towerSkillEneryPoint = {20,40,80}
    towerSkillDamage = {20,40,60}
    towerSkillRadius = {75,100,120}
    towerSkillCP10 = {0.7,1,1.4}
    towerLevel = {}
    towerLevel[DOTA_TEAM_GOODGUYS] = 1
    towerLevel[DOTA_TEAM_BADGUYS] = 1
    towerMainArray = {}
    towerMainArray[DOTA_TEAM_GOODGUYS] = {}
    towerMainArray[DOTA_TEAM_BADGUYS] = {}

    --魔法石初始化
    local goodMagicStoneEntities = Entities:FindByName(nil,"goodMagicStone") 
    local goodMagicStoneLocation = goodMagicStoneEntities:GetAbsOrigin()
    goodMagicStonePan = CreateUnitByName("magicStonePan", goodMagicStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    goodMagicStonePan:GetAbilityByIndex(0):SetLevel(1)
    goodMagicStonePan:SetSkin(0)
    goodMagicStone = CreateUnitByName("magicStone", goodMagicStoneLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    --goodMagicStone:AddAbility("magic_stone_good")
    goodMagicStone.name = "goodMagicStone"
    GameRules.goodMagicStone = goodMagicStone
    --goodMagicStone:SetContext("name", "magicStone", 0)
    magicStoneParticleSet(goodMagicStone,DOTA_TEAM_GOODGUYS)
    
    
    local badMagicStoneEntities = Entities:FindByName(nil,"badMagicStone")
    local badMagicStoneLocation = badMagicStoneEntities:GetAbsOrigin()
    badMagicStonePan = CreateUnitByName("magicStonePan", badMagicStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    badMagicStonePan:GetAbilityByIndex(0):SetLevel(1)
    badMagicStonePan:SetSkin(1)
    badMagicStone = CreateUnitByName("magicStone", badMagicStoneLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
    --badMagicStone:AddAbility("magic_stone_bad")
    badMagicStone.name = "badMagicStone"
    GameRules.badMagicStone = badMagicStone
    --badMagicStone:SetContext("name", "magicStone", 0)
    magicStoneParticleSet(badMagicStone,DOTA_TEAM_BADGUYS)
    

   --魔塔主塔初始化
    local towerCount = 2
    for i = 1 , towerCount , 1 do
        local towerName = "goodMagicTower"..i
        local goodMagicTowerEntities = Entities:FindByName(nil,towerName) 
        local goodMagicTowerLocation = goodMagicTowerEntities:GetAbsOrigin()
        local goodMagicTower = CreateUnitByName("magicTowerMain", goodMagicTowerLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)   
        goodMagicTower.name = towerName
        magicTowerParticleSet(goodMagicTower,DOTA_TEAM_GOODGUYS,i)
    end

    for i = 1 , towerCount , 1 do
        local towerName = "badMagicTower"..i
        local badMagicTowerEntities = Entities:FindByName(nil,towerName) 
        local badMagicTowerLocation = badMagicTowerEntities:GetAbsOrigin()
        local badMagicTower = CreateUnitByName("magicTowerMain", badMagicTowerLocation, true, nil, nil, DOTA_TEAM_BADGUYS)   
        badMagicTower.name = towerName
        magicTowerParticleSet(badMagicTower,DOTA_TEAM_BADGUYS,i)
    end

    magicTowerActiveInit(towerMainArray[DOTA_TEAM_GOODGUYS][towerCount+1])
    magicTowerActiveInit(towerMainArray[DOTA_TEAM_BADGUYS][towerCount+1])

end

function magicStoneParticleSet(magicStone,team)
    magicStone:SetSkin(team-2)
    magicStone:GetAbilityByIndex(0):SetLevel(1)
    magicStone:GetAbilityByIndex(1):SetLevel(1)
    magicStone:SetModelScale(towerScale[towerLevel[team]])
    --magicStone:SetPlayerID(10+team)
    magicStone.playerID = 10+team
    magicStone.alive = 1
    towerMainArray[team][1] = magicStone
end

function magicTowerParticleSet(magicTower,team,i)
    magicTower:SetSkin(team-1)
    magicTower:GetAbilityByIndex(0):SetLevel(1)
    magicTower:GetAbilityByIndex(1):SetLevel(1)
    magicTower:SetModelScale(towerScale[towerLevel[team]])
    --magicTower:SetPlayerID(10+team)
    magicTower.playerID = 10+team
    magicTower.alive = 1
    towerMainArray[team][i+1] = magicTower
    magicTowerIdleInit(magicTower)
    
    --local ability = magicTower:GetAbilityByIndex(0)
end

--魔塔边塔初始化(边塔)
function initMagicTowerAssistant()
    if towerAssistantArray ~= nil then
        for _, unit in pairs(towerAssistantArray[DOTA_TEAM_GOODGUYS]) do
            unit:ForceKill(true)
            unit:AddNoDraw()
        end

        for _, unit in pairs(towerAssistantArray[DOTA_TEAM_BADGUYS]) do
            unit:ForceKill(true)
            unit:AddNoDraw()
        end
    end

    towerAssistantArray = {}  
    towerAssistantArray[DOTA_TEAM_GOODGUYS] = {}
    towerAssistantArray[DOTA_TEAM_BADGUYS] = {}

    towerAssistantScale = 0.7
    towerAssistantSkillEneryPoint = 20
    towerAssistantSkillDamage = 2
    towerAssistantSkillRadius = 75
    local towerCount = 2

    for i = 1, towerCount , 1 do
        local towerNameGood = "goodMagicTowerAssistant"..i
        local goodMagicTowerAssistantEntities = Entities:FindByName(nil,towerNameGood)
        local goodMagicTowerAssistantLocation = goodMagicTowerAssistantEntities:GetAbsOrigin()
        local goodMagicTowerAssistant = CreateUnitByName("magicTowerAssistant", goodMagicTowerAssistantLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
        goodMagicTowerAssistant.name = towerNameGood
        magicTowerAssistanParticleSet(goodMagicTowerAssistant,DOTA_TEAM_GOODGUYS,i)
       
    end

    for i = 1, towerCount , 1 do
        local towerNameBad = "badMagicTowerAssistant"..i
        local badMagicTowerAssistantEntities = Entities:FindByName(nil,towerNameBad)
        local badMagicTowerAssistantLocation = badMagicTowerAssistantEntities:GetAbsOrigin()
        local badMagicTowerAssistant = CreateUnitByName("magicTowerAssistant", badMagicTowerAssistantLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        badMagicTowerAssistant.name = towerNameBad
        magicTowerAssistanParticleSet(badMagicTowerAssistant,DOTA_TEAM_BADGUYS,i)

    end

    for i = 1, towerCount, 1 do
        magicTowerAssistantActiveInit(towerAssistantArray[DOTA_TEAM_GOODGUYS][i])
        magicTowerAssistantActiveInit(towerAssistantArray[DOTA_TEAM_BADGUYS][i])
    end
end

function magicTowerAssistanParticleSet(magicTower,team,i)
    local buildModel
    if team == DOTA_TEAM_GOODGUYS then
        buildModel = "models/props_structures/radiant_tower002.vmdl"
    end
    if team == DOTA_TEAM_BADGUYS then
        buildModel = "models/props_structures/dire_tower002.vmdl"
    end
    
    magicTower.playerID = 10+team
    magicTower.alive = 1
    local ability = magicTower:GetAbilityByIndex(0)
    ability:SetLevel(1)
    magicTower:GetAbilityByIndex(1):SetLevel(1)
    ability:ApplyDataDrivenModifier( magicTower, magicTower, "modifier_magic_tower_idle_datadriven", {})
    magicTower:SetModel(buildModel)
    magicTower:SetOriginalModel(buildModel)
    towerAssistantArray[team][i] = magicTower
    --magicTowerAssistantInit(magicTower)
end


--待机初始化
function magicTowerIdleInit(magicTower)
    magicTowerInit(magicTower)
    local ability = magicTower:GetAbilityByIndex(0)
    ability:ApplyDataDrivenModifier(magicTower, magicTower, "modifier_magic_tower_idle_datadriven", {Duration = -1}) 
end

--启动主塔启动初始化
function magicTowerActiveInit(magicTower)
    magicTowerInit(magicTower)
    local fromPoint = magicTower:GetAbsOrigin()
    local ability = magicTower:GetAbilityByIndex(0)
    local team = magicTower:GetTeam()
    local towerLabel = magicTower:GetUnitLabel()
    if towerLabel == GameRules.magicTowerLabel then 
        ability:ApplyDataDrivenModifier(magicTower, magicTower, "modifier_magic_tower_active_datadriven", {Duration = -1}) 
    end
    if towerLabel == GameRules.magicStoneLabel then
        if magicTower:HasModifier("modifier_magic_stone_protect_datadriven") then
            magicTower:RemoveModifierByName("modifier_magic_stone_protect_datadriven")
        end
    end
    local interval = 700
    local goodTower = towerMainArray[DOTA_TEAM_GOODGUYS][#towerMainArray[DOTA_TEAM_GOODGUYS]]
    local badTower  = towerMainArray[DOTA_TEAM_BADGUYS][#towerMainArray[DOTA_TEAM_BADGUYS]]
    
    local keys = {}
    keys.caster = magicTower
    keys.caster.shootArray = {}
	keys.ability = ability
	keys.AbilityLevel = "d"
	keys.UnitType = "null"
	--keys.unitModel = magicListByName[magicName]['unitModel']  
    keys.hitType = 1 --//3直达不触碰,2穿透弹,1触碰爆炸
	keys.isAOE = 0
	keys.isMisfire = 1
    keys.soundCast = "scene_voice_magic_tower_cast"
    keys.soundMisfire =	"scene_voice_magic_tower_misfire"
    keys.soundBoom = "scene_voice_magic_tower_misfire"
    keys.cp = 3   

    local toPoint 
    if team == DOTA_TEAM_GOODGUYS then
        toPoint = badTower:GetAbsOrigin()
        keys.particles_cast = "particles/yangmota_xuli.vpcf"
        keys.particles_nm = "particles/yangmota_zhuta_fashu.vpcf"
        keys.particles_misfire = "particles/yangmota_zhuta_fashu_jiluo.vpcf"
        keys.particles_boom = "particles/yangmota_zhuta_fashu_jiluo.vpcf"
        keys.particles_active = "particles/yangfangzhanling.vpcf"
        
    end
    if team == DOTA_TEAM_BADGUYS then
        toPoint = goodTower:GetAbsOrigin()
        keys.particles_cast = "particles/yinmota_xuli.vpcf"
        keys.particles_nm = "particles/yinmota_zhuta_fashu_zhuangtai2.vpcf"
        keys.particles_misfire = "particles/yinmota_zhuta_fashu_jiluo.vpcf"
        keys.particles_boom = "particles/yinmota_zhuta_fashu_jiluo.vpcf"
        keys.particles_active = "particles/yinfangzhanling.vpcf"
    end
    magicTower.towerDefenceWarningParticleID = towerDefenceWarningRadius(magicTower)
    --towerActiveParticle(keys,magicTower)
    
    Timers:CreateTimer(interval,function()
        if checkMainTowerLaunchReady(magicTower,team) then
            towerCastOperation(keys)
            Timers:CreateTimer(0.8,function()
                if checkMainTowerLaunchReady(magicTower,team) then
                    EmitSoundOn(keys.soundCast,keys.caster)
                    local towerLevelTemp =  towerLevel[team]
                    local max_distance = (toPoint - fromPoint ):Length2D()
                    local direction = (toPoint - fromPoint):Normalized()
                    local shoot = CreateUnitByName("towerSkillUnit", fromPoint, true, nil, nil, team)
                    keys.hit_range = towerSkillRadius[towerLevelTemp]
                    keys.energy_point = towerSkillEneryPoint[towerLevelTemp]
                    keys.max_distance_operation = max_distance
                    keys.damage = 1
                    keys.direction = direction
                    keys.speed = 330 * GameRules.speedConstant * 0.02
                    creatTowerSkillInit(keys,shoot,magicTower)
                    shoot.cp10 = towerSkillCP10[towerLevelTemp]
                    shoot.intervalCallBack = magicTowerSkillInterval
                    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
                    ParticleManager:SetParticleControlEnt(particleID, 0 , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
                    ParticleManager:SetParticleControl(particleID, 10, Vector(shoot.cp10, 0, 0))
                    shoot.particleID = particleID
                    moveShoot(keys, shoot, magicTowerSkillBoomCallBack, nil)
                end
            end)
            return interval
        else  
            return nil
        end
    end)

    towerDefenceOperation(magicTower,team)
    
end

function checkMainTowerLaunchReady(magicTower,team)
    local flag = false
    local towerLabel = magicTower:GetUnitLabel()
    if magicTower:IsAlive() and magicTower.alive == 1 and GameRules.checkWinTeam == nil and team == magicTower:GetTeam() and ((towerLabel == GameRules.magicStoneLabel and not magicTower:HasModifier("modifier_magic_stone_protect_datadriven")) or (towerLabel == GameRules.magicTowerLabel and magicTower:HasModifier("modifier_magic_tower_active_datadriven"))) then
        flag= true
    end
    return flag
end

function towerDefenceOperation(magicTower,originalTeam)
    local towerLabel = magicTower:GetUnitLabel()
    local searchInterval = 0.1
    local delayTime = 5
    Timers:CreateTimer(delayTime,function()  
        if magicTower:IsAlive() and magicTower.alive == 1 and originalTeam == magicTower:GetTeam() and ((towerLabel == GameRules.magicStoneLabel and not magicTower:HasModifier("modifier_magic_stone_protect_datadriven")) or ((towerLabel == GameRules.magicTowerLabel or towerLabel == GameRules.magicTowerAssistantLabel)and magicTower:HasModifier("modifier_magic_tower_active_datadriven"))) then
            local nowTeam = magicTower:GetTeam()
            local defenceLevel = towerDefenceLevel[nowTeam]
            local searchRadius = towerDefenceSearch[defenceLevel]
            local keys = {}
            keys.caster = magicTower
            magicTower.keysTable = keys
            local aroundUnits = FindUnitsInRadius(nowTeam, 
                                                    magicTower:GetAbsOrigin(),
                                                    nil,
                                                    searchRadius,
                                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                                    DOTA_UNIT_TARGET_ALL,
                                                    0,
                                                    0,
                                                    false)

            for _, unit in pairs(aroundUnits) do
                if checkIsEnemyHero(magicTower,unit) then
                    local keys = {}
                    keys.caster = magicTower
                    keys.ability = magicTower:GetAbilityByIndex(1)
                    if nowTeam == DOTA_TEAM_GOODGUYS then
                        keys.particles_boom = 	"particles/items2_fx/shivas_guard_active.vpcf"
                        keys.aoeTargetDebuff =   "modifier_good_tower_defence_debuff_datadriven"
                    end
                    if nowTeam == DOTA_TEAM_BADGUYS then
                        keys.particles_boom = 	"particles/econ/events/fall_2022/shivas/shivas_guard_fall2022_active.vpcf"
                        keys.aoeTargetDebuff =   "modifier_bad_tower_defence_debuff_datadriven"
                    end
                    keys.soundBoom =			"magic_frost_blast_boom"
                    keys.soundHit =			"magic_frost_blast_hit"
                    
                    keys.diffuseSpeed = towerDefenceDiffuseSpeed[defenceLevel]
                    magicTower.keysTable = keys
                    magicTower.abilityLevel = keys.ability
                    magicTower.owner = magicTower
                    magicTower.aoe_radius = towerDefenceRadius[defenceLevel]
                    magicTower.power_lv = 0 --用于实现克制和加强
                    magicTower.power_flag = 0 --用于实现克制和加强，标记粒子效果使用
                    magicTower.hitUnits = {}--用于记录命中的目标
                    magicTower.tempHitUnits = {}
                    magicTower.hitShoot = {} -- 用于记录击中过的子弹，避免重复运算
                    magicTower.matchUnitsID ={}--记录被什么技能加强的过
                    magicTower.matchAbilityLevel ={}--记录被什么等级技能加强的过
                    towerDefenceRenderParticles(magicTower) --爆炸粒子效果生成		  
	                diffuseBoomAOEOperation(magicTower, towerDefenceCallback)
                    return towerDefenceCooldown[defenceLevel]
                end
            end  
            return searchInterval
        else
            return nil
        end
    end)
end




--副塔启动初始化
function magicTowerAssistantActiveInit(magicTower)
    magicTowerAssistantInit(magicTower)
    local fromPoint = magicTower:GetAbsOrigin()
    local ability = magicTower:GetAbilityByIndex(0)
    local team = magicTower:GetTeam()
    local towerLabel = magicTower:GetUnitLabel()
    if towerLabel == GameRules.magicTowerAssistantLabel then
        ability:ApplyDataDrivenModifier(magicTower, magicTower, "modifier_magic_tower_active_datadriven", {Duration = -1}) 
    end
    local towerNum =  tonumber(string.sub(magicTower.name, -1))
    local interval = 700
    local goodTower = towerAssistantArray[DOTA_TEAM_GOODGUYS][towerNum]
    local badTower = towerAssistantArray[DOTA_TEAM_BADGUYS][towerNum]
   
    local keys = {}
    keys.caster = magicTower
    keys.caster.shootArray = {}
	keys.ability = ability
	keys.AbilityLevel = "d"
	keys.UnitType = "null"

    keys.hitType = 1 --//3直达不触碰,2穿透弹,1触碰爆炸
	keys.isAOE = 0
	keys.isMisfire = 1

    keys.soundMisfire =	"scene_voice_magic_tower_misfire"
    keys.soundBoom = "scene_voice_magic_tower_misfire"
    keys.cp = 3

    local toPoint
    if team == DOTA_TEAM_GOODGUYS then
        toPoint = badTower:GetAbsOrigin()
        keys.soundCast = "scene_voice_magic_tower_cast"
        keys.particles_cast = "particles/yangmota_xuli.vpcf"
        keys.particles_nm = "particles/wiltexiao/fuzhuxi/yangmota_futa_fashu.vpcf"
        keys.particles_misfire = "particles/base_attacks/ranged_tower_good_explosion.vpcf"
        keys.particles_boom = "particles/base_attacks/ranged_tower_good_explosion.vpcf"

    end
    if team == DOTA_TEAM_BADGUYS then
        toPoint = goodTower:GetAbsOrigin()
        keys.soundCast = "scene_voice_magic_tower_cast"
        keys.particles_cast = "particles/yinmota_xuli.vpcf"
        keys.particles_nm = "particles/wiltexiao/fuzhuxi/yinmota_futa_fashu.vpcf"
        keys.particles_misfire = "particles/base_attacks/ranged_tower_bad_explosion.vpcf"
        keys.particles_boom = "particles/base_attacks/ranged_tower_bad_explosion.vpcf"

    end

    magicTower.towerDefenceWarningParticleID = towerDefenceWarningRadius(magicTower)

    Timers:CreateTimer(interval,function()
        if checkAssistantTowerLaunchReady(magicTower) then
            towerAssistantCastOPeration(keys)
            Timers:CreateTimer(0.8,function()
                if checkAssistantTowerLaunchReady(magicTower) then
                    EmitSoundOn(keys.soundCast,keys.caster)
                    local max_distance = (toPoint - fromPoint):Length2D()
                    local direction = (toPoint - fromPoint):Normalized()
                    local shoot = CreateUnitByName("towerSkillUnit", fromPoint, true, nil, nil, team)
                    keys.hit_range = towerAssistantSkillRadius
                    keys.energy_point = towerAssistantSkillEneryPoint
                    keys.max_distance_operation = max_distance
                    keys.damage = 1
                    keys.direction = direction
                    keys.speed = 330 * GameRules.speedConstant * 0.02
                    creatTowerSkillInit(keys,shoot,magicTower)
                    shoot.intervalCallBack = magicTowerAssistantSkillInterval
                    local particleID = ParticleManager:CreateParticle(keys.particles_nm, PATTACH_ABSORIGIN_FOLLOW , shoot)
                    ParticleManager:SetParticleControlEnt(particleID, 0 , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
                    shoot.particleID = particleID
                    moveShoot(keys, shoot, magicTowerAssistantSkillBoomCallBack, nil)
                end
            end)
            return interval
        else
            --关闭防御圈特效
            ParticleManager:DestroyParticle(magicTower.towerDefenceWarningParticleID , true)
            return nil
        end
    end)
    towerDefenceOperation(magicTower,team)
end

function checkAssistantTowerLaunchReady(magicTower)
    local flag = false
    local towerLabel = magicTower:GetUnitLabel()
    if magicTower:IsAlive() and magicTower.alive == 1 and magicTower:HasModifier("modifier_magic_tower_active_datadriven") and GameRules.checkWinTeam == nil then
        flag= true
    end
    return flag
end

function towerCastOperation(keys)
    local caster = keys.caster
    local particleID = ParticleManager:CreateParticle(keys.particles_cast, PATTACH_ABSORIGIN_FOLLOW , caster)
    local casterPos = caster:GetAbsOrigin()
    --ParticleManager:SetParticleControlEnt(particleID, 3 , caster, PATTACH_POINT_FOLLOW, nil, caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particleID, 0, Vector(casterPos.x, casterPos.y, casterPos.z))
end

function towerAssistantCastOPeration(keys)
    local caster = keys.caster
    local particleID = ParticleManager:CreateParticle(keys.particles_cast, PATTACH_ABSORIGIN_FOLLOW , caster)
    local casterPos = caster:GetAbsOrigin()
    --ParticleManager:SetParticleControlEnt(particleID, 3 , caster, PATTACH_POINT_FOLLOW, nil, caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particleID, 0, Vector(casterPos.x, casterPos.y, casterPos.z))
end

function magicTowerSkillBoomCallBack(shoot)
    magicTowerSkillBoomParticles(shoot)
    boomAOEOperation(shoot, mainBoomAOEOperationCallback)
end

function magicTowerSkillBoomParticles(shoot)
    local keys = shoot.keysTable
    EmitSoundOn(keys.soundBoom,shoot)
    local particleID = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, 3 , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particleID, 10, Vector(shoot.cp10, 0, 0))
end


function mainBoomAOEOperationCallback(shoot,unit)
    local damage = towerSkillDamage[towerLevel[shoot:GetTeam()]]
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = DAMAGE_TYPE_PURE})
end

function magicTowerAssistantSkillBoomCallBack(shoot)
    magicTowerAssistantSkillBoomParticles(shoot)
    boomAOEOperation(shoot, assistantBoomAOEOperationCallback)
end

function magicTowerAssistantSkillBoomParticles(shoot)
    local keys = shoot.keysTable
    EmitSoundOn(keys.soundBoom,shoot)
    local particleID = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_ABSORIGIN_FOLLOW , shoot)
    ParticleManager:SetParticleControlEnt(particleID, 3 , shoot, PATTACH_POINT_FOLLOW, nil, shoot:GetAbsOrigin(), true)
end

function assistantBoomAOEOperationCallback(shoot,unit)
    local damage = towerAssistantSkillDamage
    ApplyDamage({victim = unit, attacker = shoot, damage = damage, damage_type = DAMAGE_TYPE_PURE})
end

function magicTowerSkillInterval(shoot)
    local team = shoot:GetTeam()
    local position = shoot:GetAbsOrigin()
    
    local towerLevelTemp =  towerLevel[team]
    local searchRadius = towerSkillRadius[towerLevelTemp]
    local aroundUnits = FindUnitsInRadius(team, 
                                            position,
                                            nil,
                                            searchRadius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)
    for _, unit in pairs(aroundUnits) do
        local towerLabel = unit:GetUnitLabel() 
        if (towerLabel == GameRules.magicTowerLabel or towerLabel == GameRules.magicStoneLabel) and team ~= unit:GetTeam() then               
            if (towerLabel == GameRules.magicTowerLabel and unit:GetHealth() > 1) or towerLabel == GameRules.magicStoneLabel then 
                ApplyDamage({victim = unit, attacker = shoot, damage = towerSkillDamage[1], damage_type = DAMAGE_TYPE_PURE})
                if towerLabel == GameRules.magicStoneLabel and not unit:IsAlive() then
                    unit.alive = 0
                    magicStoneBroken(unit)
                end
            else
                if towerLabel == GameRules.magicTowerLabel then
                    magicTowerTransInit(unit,team)
                end
            end
            magicTowerSkillBoomParticles(shoot)
            shootKill(shoot)
        end
    end
end

function magicTowerAssistantSkillInterval(shoot)
    local team = shoot:GetTeam()
    local position = shoot:GetAbsOrigin()
    
    local towerLevelTemp =  towerLevel[team]
    local searchRadius = towerSkillRadius[towerLevelTemp]
    local aroundUnits = FindUnitsInRadius(team, 
                                            position,
                                            nil,
                                            searchRadius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)
    for _, unit in pairs(aroundUnits) do
        local towerLabel = unit:GetUnitLabel() 
        if (towerLabel == GameRules.magicTowerAssistantLabel) and team ~= unit:GetTeam() then               
            if unit:GetHealth() > 1 then
                ApplyDamage({victim = unit, attacker = shoot, damage = 1, damage_type = DAMAGE_TYPE_PURE})
            else
                local attackTower = shoot.owner
                magicTowerAssistantInit(attackTower)
                magicTowerAssistantBroken(unit)
            end
            magicTowerAssistantSkillBoomParticles(shoot)
            shootKill(shoot)
        end
    end
end

--转阵型初始化
function magicTowerTransInit(transTower,shootTeam)
    print("==================================magicTowerTransInit=======================================")
    
    local towerTeam
    if shootTeam == DOTA_TEAM_GOODGUYS then
        towerTeam = DOTA_TEAM_BADGUYS
    else
        towerTeam = DOTA_TEAM_GOODGUYS
    end
    EmitSoundOn("scene_voice_magic_tower_trans",transTower)
    transTower:SetTeam(shootTeam)
    transTower:SetSkin(shootTeam-1)
    transTower:GetAbilityByIndex(0):SetLevel(1)
    transTower:SetModelScale(towerScale[towerLevel[shootTeam]])
    --transTower:SetPlayerID(10+shootTeam)
    transTower.playerID = 10+shootTeam
    
    local addCount = #towerMainArray[shootTeam] 
    towerMainArray[shootTeam][addCount + 1] = transTower
    local oldTower =  towerMainArray[shootTeam][addCount]
    magicTowerInit(oldTower)
    magicTowerIdleInit(oldTower)

    local reduceCount = #towerMainArray[towerTeam]
    towerMainArray[towerTeam][reduceCount] = nil
    local loseTeamTower = towerMainArray[towerTeam][reduceCount - 1]

    magicTowerInit(transTower)
    magicTowerInit(loseTeamTower)


    magicTowerActiveInit(transTower)
    magicTowerActiveInit(loseTeamTower)

end

function magicTowerAssistantBroken(tower)
    magicTowerAssistantInit(tower)
    local team = tower:GetTeam()
    
    local tempModel
    local ugTeam
    local goodModel = "models/props_structures/radiant_tower002_destruction_003.vmdl"
    local badModel = "models/props_structures/dire_tower002_destruction.vmdl"
    if team == DOTA_TEAM_GOODGUYS then
        tempModel = goodModel
        ugTeam = DOTA_TEAM_BADGUYS
    end
    if team == DOTA_TEAM_BADGUYS then
        tempModel = badModel
        ugTeam = DOTA_TEAM_GOODGUYS
    end
    
    local ability = tower:GetAbilityByIndex(0)
    ability:ApplyDataDrivenModifier( tower, tower, "modifier_magic_tower_destroy_datadriven", {})
    tower:SetModel(tempModel)
    tower:SetOriginalModel(tempModel)
    magicTowerUG(ugTeam)
end

--升级
function magicTowerUG(ugTeam)
    towerLevel[ugTeam] = towerLevel[ugTeam] + 1
    for i = 1, #towerMainArray[ugTeam], 1 do
        local magicTower = towerMainArray[ugTeam][i]
        magicTower:SetModelScale(towerScale[towerLevel[ugTeam]])
    end
end


--初始化删除法阵激活的动作和特效
function magicTowerInit(caster)
    EmitSoundOn("scene_voice_stop", caster)
    caster.alive = 1
    caster:SetHealth(caster:GetMaxHealth())
    if caster:GetUnitLabel() == GameRules.magicTowerLabel then
        if caster:HasModifier("modifier_magic_tower_active_datadriven") then
            caster:RemoveModifierByName("modifier_magic_tower_active_datadriven")
        end
        if caster:HasModifier("modifier_magic_tower_idle_datadriven") then
            caster:RemoveModifierByName("modifier_magic_tower_idle_datadriven")
        end
    end
    if caster:GetUnitLabel() == GameRules.magicStoneLabel then
        caster:GetAbilityByIndex(0):ApplyDataDrivenModifier( caster, caster, "modifier_magic_stone_protect_datadriven", {})
    end
    if caster.towerDefenceWarningParticleID ~= nil then
        ParticleManager:DestroyParticle(caster.towerDefenceWarningParticleID , true)
    end
    if caster.activeParticle ~= nil then
        ParticleManager:DestroyParticle(caster.activeParticle , true)
    end
end

function magicTowerAssistantInit(caster)
    EmitSoundOn("scene_voice_stop", caster)
    if caster:HasModifier("modifier_magic_tower_active_datadriven") then
        caster:RemoveModifierByName("modifier_magic_tower_active_datadriven")
    end
    if caster:HasModifier("modifier_magic_tower_idle_datadriven") then
        caster:RemoveModifierByName("modifier_magic_tower_idle_datadriven")
    end

end

function towerDefenceRenderParticles(tower)
    local keys = tower.keysTable
    local team = tower:GetTeam()
    local defenceLevel = towerDefenceLevel[team]
    local aoe_radius = towerDefenceRadius[defenceLevel]
    local diffuseSpeed = towerDefenceDiffuseSpeed[defenceLevel] * GameRules.speedConstant
	local particleBoom = ParticleManager:CreateParticle(keys.particles_boom, PATTACH_WORLDORIGIN, tower)
	local groundPos = GetGroundPosition(tower:GetAbsOrigin(), tower)
	ParticleManager:SetParticleControl(particleBoom, 0, groundPos)
	ParticleManager:SetParticleControl(particleBoom, 1, Vector(aoe_radius, 4, diffuseSpeed))--未实现传参
end

function towerDefenceCallback(tower,unit)
    local keys = tower.keysTable
	local ability = keys.ability
    local team = tower:GetTeam()
    local defenceLevel = towerDefenceLevel[team]
    local debuffDuration = towerDefenceDebuffDuration[defenceLevel]


    local aoeTargetDebuff = keys.aoeTargetDebuff
    local isHitUnit = checkHitUnitToMark(tower, unit, nil)
    if isHitUnit then
        local damage = towerDefenceDamage[defenceLevel]
        EmitSoundOn(keys.soundHit, unit)
        ApplyDamage({victim = unit, attacker = tower, damage = damage, damage_type = DAMAGE_TYPE_PURE})

        ability:ApplyDataDrivenModifier(tower, unit, aoeTargetDebuff, {Duration = debuffDuration})
        --unit:AddNewModifier(tower,ability,aoeTargetDebuff, {Duration = debuffDuration})
    end
end


function towerDefenceWarningRadius(magicTower)
    local team = magicTower:GetTeam()
    --print("team:"..team)
    local defenceLevel = towerDefenceLevel[team]
    local defenceRadiusParticles = "particles/fangyujizhitishi.vpcf"
    local defenceRadiusParticleID = ParticleManager:CreateParticle(defenceRadiusParticles, PATTACH_ABSORIGIN_FOLLOW , magicTower)
    ParticleManager:SetParticleControlEnt(defenceRadiusParticleID, 2 , magicTower, PATTACH_POINT_FOLLOW, nil, magicTower:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(defenceRadiusParticleID, 3, Vector(towerDefenceSearch[defenceLevel], 0, 0))
    if team == DOTA_TEAM_GOODGUYS then
        ParticleManager:SetParticleControl(defenceRadiusParticleID, 4, Vector(0, 0, 0.8))
    end
    if team == DOTA_TEAM_BADGUYS then
        ParticleManager:SetParticleControl(defenceRadiusParticleID, 4, Vector(0.8, 0, 0))
    end
    return defenceRadiusParticleID
end

function towerActiveParticle(keys,magicTower)
    local particleID = ParticleManager:CreateParticle(keys.particles_active, PATTACH_POINT_FOLLOW , magicTower)
    ParticleManager:SetParticleControlEnt(particleID, 0 , magicTower, PATTACH_POINT_FOLLOW, nil, magicTower:GetAbsOrigin(), true)
    --ParticleManager:SetParticleControl(particleID, 0, magicTower:GetAbsOrigin())
    magicTower.activeParticle = particleID
end

--待机后操作
function magicTowerIdle(keys)

end

--启动后操作
function magicTowerActive(keys)

end

