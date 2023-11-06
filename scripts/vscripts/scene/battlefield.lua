--法阵初始化
function initBattlefield()
    if Battlefields ~= nil  then
        local maxCountGoodBattlefields = #Battlefields[DOTA_TEAM_GOODGUYS]
        for i = 1, maxCountGoodBattlefields, 1 do
            local goodBattlefield = Battlefields[DOTA_TEAM_GOODGUYS][i]
            goodBattlefield:ForceKill(true)
            battlefieldInitAll(goodBattlefield)
            Battlefields[DOTA_TEAM_GOODGUYS][i] = nil
            --goodBattlefield:SetTeam(DOTA_TEAM_GOODGUYS)
            --battlefieldParticleSet(goodBattlefield,DOTA_TEAM_GOODGUYS,i)
        end

        local maxCountBadBattlefields = #Battlefields[DOTA_TEAM_BADGUYS]
        for i = 1, maxCountBadBattlefields, 1 do
            local badBattlefield = Battlefields[DOTA_TEAM_BADGUYS][i]
            badBattlefield:ForceKill(true)
            battlefieldInitAll(badBattlefield)
            --badBattlefield:SetTeam(DOTA_TEAM_BADGUYS)
            --battlefieldParticleSet(badBattlefield,DOTA_TEAM_BADGUYS,i)
            Battlefields[DOTA_TEAM_BADGUYS][i] = nil
        end
        --Battlefields[DOTA_TEAM_GOODGUYS] = BattlefieldsStatic[DOTA_TEAM_GOODGUYS]
        --Battlefields[DOTA_TEAM_BADGUYS] = BattlefieldsStatic[DOTA_TEAM_BADGUYS]
    end


    Battlefields = {}
    --BattlefieldsStatic = {}
    Battlefields[DOTA_TEAM_GOODGUYS] = {}
    --BattlefieldsStatic[DOTA_TEAM_GOODGUYS] = {}    
    --LaunchGoodBattlefield = 'nil'
    for i=1, 3 ,1 do
        local fieldName = "goodBattlefield"..i
        local goodBattlefieldEntities = Entities:FindByName(nil,fieldName) 
        local goodBattlefieldLocation = goodBattlefieldEntities:GetAbsOrigin()
        local goodBattlefield = CreateUnitByName("battlefield", goodBattlefieldLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
        goodBattlefield.fieldName = fieldName
        Battlefields[DOTA_TEAM_GOODGUYS][i] = goodBattlefield
        --BattlefieldsStatic[DOTA_TEAM_GOODGUYS][i] = goodBattlefield
        local goodBattlefieldAbility = goodBattlefield:GetAbilityByIndex(0)
        goodBattlefieldAbility:SetLevel(1)
        battlefieldParticleSet(goodBattlefield,DOTA_TEAM_GOODGUYS,i)   
    end

    Battlefields[DOTA_TEAM_BADGUYS] = {}
    --BattlefieldsStatic[DOTA_TEAM_BADGUYS] = {}
    --LaunchBadBattlefield = 'nil'
    for i=1, 3 ,1 do
        local fieldName = "badBattlefield"..i
        local badBattlefieldEntities = Entities:FindByName(nil,fieldName) 
        local badBattlefieldLocation = badBattlefieldEntities:GetAbsOrigin()
        local badBattlefield = CreateUnitByName("battlefield", badBattlefieldLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        badBattlefield.fieldName = fieldName
        Battlefields[DOTA_TEAM_BADGUYS][i] = badBattlefield
        --BattlefieldsStatic[DOTA_TEAM_BADGUYS][i] = badBattlefield
        local badBattlefieldAbility = badBattlefield:GetAbilityByIndex(0)
        badBattlefieldAbility:SetLevel(1)

        battlefieldParticleSet(badBattlefield,DOTA_TEAM_BADGUYS,i)
    end
 
end


--法阵沉睡
function battlefieldFlail(keys)
    local caster = keys.caster
    battlefieldInit(caster)
    Timers:CreateTimer(0,function()
        EmitSoundOn("scene_voice_battlefield_flail", caster) 
    end)
end

--法阵启动
function battlefieldIdle(keys)
    local caster = keys.caster
    local casterLocation = caster:GetAbsOrigin()
    local ability = caster:GetAbilityByIndex(0)
    local refreshInterval = 20
    local casterTeam = caster:GetTeam()
    print("=-=-=-particlesLaunch-=-=-=")
    Timers:CreateTimer(0.05,function()    
        EmitSoundOn("scene_voice_battlefield_idle", caster)
        local goodTeamParticlesLaunch = "particles/mofazhen_dizuo_1.vpcf"
        local badTeamParticlesLaunch = "particles/mofazhen_dizuo_2.vpcf"
        local particlesLaunch
        if casterTeam == DOTA_TEAM_GOODGUYS then
            particlesLaunch = goodTeamParticlesLaunch
        end
        if casterTeam == DOTA_TEAM_BADGUYS then
            particlesLaunch = badTeamParticlesLaunch
        end
        local particleID = ParticleManager:CreateParticle(particlesLaunch, PATTACH_ABSORIGIN_FOLLOW, caster)
        local groundPos = GetGroundPosition(caster:GetAbsOrigin(), caster)
        ParticleManager:SetParticleControl(particleID, 3, Vector(groundPos.x,groundPos.y,groundPos.z+10))
        caster.idleParticleID = particleID
    end)
end

--法阵定期激活
function battlefieldLaunchTimer()
    --good=2,bad=3
    for i=2,3,1 do
        local fieldCount = #Battlefields[i]
        if fieldCount > 0 then
            local LaunchBattlefield = Battlefields[i][fieldCount]
            EmitSoundOn("scene_voice_battlefield_ability2", LaunchBattlefield)
            local ability = LaunchBattlefield:GetAbilityByIndex(0)
            if LaunchBattlefield:HasModifier("modifier_battlefield_idle_ACT_datadriven") then
                LaunchBattlefield:RemoveModifierByName("modifier_battlefield_idle_ACT_datadriven")
            end
            ability:ApplyDataDrivenModifier(LaunchBattlefield, LaunchBattlefield, "modifier_battlefield_ability2_datadriven", {Duration = buffStay}) --此modifier会启动算法battlefieldLaunch
            
            local randomNum = math.random(1,100)
            if randomNum < 33 then
                ability:ApplyDataDrivenModifier(LaunchBattlefield, LaunchBattlefield, "modifier_battlefield_vision_datadriven", {Duration = buffStay})
                Battlefields[i][fieldCount].battlefieldBuff = "vision"
            end

            if randomNum > 33 and randomNum < 66 then
                ability:ApplyDataDrivenModifier(LaunchBattlefield, LaunchBattlefield, "modifier_battlefield_speed_datadriven", {Duration = buffStay})
                Battlefields[i][fieldCount].battlefieldBuff = "speed"
            end

            if randomNum > 66 then
                ability:ApplyDataDrivenModifier(LaunchBattlefield, LaunchBattlefield, "modifier_battlefield_mana_regan_datadriven", {Duration = buffStay})
                Battlefields[i][fieldCount].battlefieldBuff = "mana_regen"
            end

        end
    end
end

--法阵激活
function battlefieldLaunch(keys)
    local caster = keys.caster
    local position = caster:GetAbsOrigin()
    local casterTeam = caster:GetTeam()
    local ability = caster:GetAbilityByIndex(0)
    local workingFlag = false
    local loadingFlag = false
    local radius = 200
    local count = 0
    local getBuffTime = 3.0
    local buffStayTime = 10
    local timerFlag = false
    print("=================battlefieldLaunch==ininin==================team:"..casterTeam)
    --print(caster:GetName())
    --倒计时关闭激活
    Timers:CreateTimer(buffStayTime,function()
        timerFlag = true
    end)
    --扫描是否有人来拿buff
    Timers:CreateTimer(function()
        local aroundUnits = FindUnitsInRadius(casterTeam, 
                                                    position,
                                                    nil,
                                                    radius,
                                                    DOTA_UNIT_TARGET_TEAM_BOTH,
                                                    DOTA_UNIT_TARGET_ALL,
                                                    0,
                                                    0,
                                                    false)
        --监测是否有自己人在范围内
        for k,unit in pairs(aroundUnits) do
            workingFlag = false
            local unitTeam = unit:GetTeam()
            local unitLabel = unit:GetUnitLabel()

            if  casterTeam == unitTeam and unit ~= caster and unitLabel ~= GameRules.battlefieldLabel then
                workingFlag = true
                break;
            end
        end
        --workingFlag:法阵处于有友军状态
        --loadingFlag:已经判断
        if workingFlag == true and loadingFlag == false then
            print("==================================battlefieldLaunch===========workingFlagtrue==============")
            EmitSoundOn("scene_voice_battlefield_buff_collect", caster)
            loadingFlag = true
            local goodTeamParticlesGetBuff = "particles/mofahen_huoqu_yang.vpcf"
            local badTeamParticlesGetBuff = "particles/mofahen_huoqu_yin.vpcf"
            local particlesGetBuff
            --print("battlefieldIdle"..casterTeam.."================================="..DOTA_TEAM_GOODGUYS)
            if casterTeam == DOTA_TEAM_GOODGUYS then
                particlesGetBuff = goodTeamParticlesGetBuff
            end
            if casterTeam == DOTA_TEAM_BADGUYS then
                particlesGetBuff = badTeamParticlesGetBuff
            end
            Timers:CreateTimer(0,function()
                local particleID = ParticleManager:CreateParticle(particlesGetBuff, PATTACH_ABSORIGIN_FOLLOW, caster)
                ParticleManager:SetParticleControl(particleID, 1, position)
                caster.loadingParticleID = particleID
            end)
        end
       
        if workingFlag == false and loadingFlag == true then
            --print("==================================battlefieldFlatl===========workingFlagfalse==============")
            loadingFlag = false
            ParticleManager:DestroyParticle(caster.loadingParticleID, true)
            EmitSoundOn("scene_voice_stop", caster)
            count = 0
        end
        
        if loadingFlag == true then
            count = count + 0.1
            --print(count)
        end

        --转圈完成
        if string.format("%.1f",count) > string.format("%.1f",getBuffTime) then 
            --EmitSoundOn("scene_voice_stop", caster)
            battlefieldInit(caster)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            local buffName = caster.battlefieldBuff
            --print("getBuff:"..buffName)
            local abilityName = "battlefield_"..buffName.."_buff_datadriven"
            local modifierName = "modifier_battlefield_"..buffName.."_buff_datadriven"
            for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
                if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                    local hHero = PlayerResource:GetSelectedHeroEntity(playerID) 
                    if hHero:HasModifier(modifierName) then
                        hHero:RemoveModifierByName(modifierName)
                    end
                    if hHero:HasAbility(abilityName) then
                        hHero:RemoveAbility(abilityName)
                    end
                    hHero:AddAbility(abilityName):SetLevel(1)
                    EmitSoundOn("scene_voice_battlefield_buff_get", hHero)
                end
            end
            return nil
        end
        --当buff时间到消失，并且没有友军在获取
        if timerFlag == true and loadingFlag == false then
            --EmitSoundOn("scene_voice_stop", caster)
            battlefieldInit(caster)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            return nil
        end

        if caster:HasModifier("modifier_battlefield_ability2_datadriven") then
            return 0.1
        end

        if not caster:IsAlive() then
            return nil
        end
    end)

end

--初始化删除法阵激活的动作和特效
function battlefieldInit(caster)
    EmitSoundOn("scene_voice_stop", caster)
    if caster:HasModifier("modifier_battlefield_ability2_datadriven") then
        caster:RemoveModifierByName("modifier_battlefield_ability2_datadriven")
    end
    if caster:HasModifier("modifier_battlefield_vision_datadriven") then
        caster:RemoveModifierByName("modifier_battlefield_vision_datadriven")
    end
    if caster:HasModifier("modifier_battlefield_speed_datadriven") then
        caster:RemoveModifierByName("modifier_battlefield_speed_datadriven")
    end
    if caster:HasModifier("modifier_battlefield_mana_regan_datadriven") then
        caster:RemoveModifierByName("modifier_battlefield_mana_regan_datadriven")
    end
    if caster.loadingParticleID ~= nil then
        ParticleManager:DestroyParticle(caster.loadingParticleID, true)
    end
    
end

function battlefieldInitAll(caster)
    battlefieldInit(caster)
    if caster.idleParticleID ~= nil then
        ParticleManager:DestroyParticle(caster.idleParticleID, true)
    end
end

function battlefieldParticleSet(battlefield,team,i)
    battlefield:SetSkin(team-1)
    local battlefieldAbility = battlefield:GetAbilityByIndex(0)
    battlefieldAbility:ApplyDataDrivenModifier(battlefield, battlefield, "modifier_battlefield_flatl_datadriven", {Duration = -1}) 
    if i == 3 then
        battlefield:RemoveModifierByName("modifier_battlefield_flatl_datadriven")
        battlefieldAbility:ApplyDataDrivenModifier(battlefield, battlefield, "modifier_battlefield_idle_datadriven", {Duration = -1}) 
        battlefieldAbility:ApplyDataDrivenModifier(battlefield, battlefield, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
    end
end

