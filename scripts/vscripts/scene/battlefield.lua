
--法阵初始化
function initBattlefield()

    if Battlefields ~= nil then
        for i = 1, #Battlefields[2],1 do
            local goodBattlefield = Battlefields[2][i]
            battlefieldDelete(goodBattlefield)
            goodBattlefield:ForceKill(true)
            Battlefields[2][i] = nil
        end

        for i = 1, #Battlefields[3],1 do
            local goodBattlefield = Battlefields[3][i]
            battlefieldDelete(goodBattlefield)
            goodBattlefield:ForceKill(true)
            Battlefields[3][i] = nil
        end
        
    end

    Battlefields = {}
    Battlefields[2] = {}    
    --LaunchGoodBattlefield = 'nil'
    for i=1, 3 ,1 do
        local fieldName = "goodBattlefield"..i

        local goodBattlefieldEntities = Entities:FindByName(nil,fieldName) 
        local goodBattlefieldLocation = goodBattlefieldEntities:GetAbsOrigin()
        local goodBattlefield = CreateUnitByName("battlefield", goodBattlefieldLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
        goodBattlefield.fieldName = fieldName
        Battlefields[2][i] = goodBattlefield
        local goodBattlefieldAbility = goodBattlefield:GetAbilityByIndex(0)
        goodBattlefieldAbility:SetLevel(1)
        goodBattlefield:SetSkin(1)
        goodBattlefieldAbility:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_flatl_datadriven", {Duration = -1}) 
        if i == 3 then
            goodBattlefield:RemoveModifierByName("modifier_battlefield_flatl_datadriven")
            goodBattlefieldAbility:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_idle_datadriven", {Duration = -1}) 
            goodBattlefieldAbility:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            --LaunchGoodBattlefield = goodBattlefield
        end
    end

    Battlefields[3] = {}
    --LaunchBadBattlefield = 'nil'
    for i=1, 3 ,1 do
        local fieldName = "badBattlefield"..i
        local badBattlefieldEntities = Entities:FindByName(nil,fieldName) 
        local badBattlefieldLocation = badBattlefieldEntities:GetAbsOrigin()
        local badBattlefield = CreateUnitByName("battlefield", badBattlefieldLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        badBattlefield.fieldName = fieldName
        Battlefields[3][i] = badBattlefield
        local badBattlefieldAbility = badBattlefield:GetAbilityByIndex(0)
        badBattlefieldAbility:SetLevel(1)
        badBattlefield:SetSkin(2)
        badBattlefieldAbility:ApplyDataDrivenModifier(badBattlefield, badBattlefield, "modifier_battlefield_flatl_datadriven", {Duration = -1}) 
        if i == 3 then
            badBattlefield:RemoveModifierByName("modifier_battlefield_flatl_datadriven")
            badBattlefieldAbility:ApplyDataDrivenModifier(badBattlefield, badBattlefield, "modifier_battlefield_idle_datadriven", {Duration = -1}) 
            badBattlefieldAbility:ApplyDataDrivenModifier(badBattlefield, badBattlefield, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            --LaunchBadBattlefield = badBattlefield
        end
    end
end


--法阵沉睡
function battlefieldFlail(keys)
    local caster = keys.caster
    battlefieldInit(caster)
end

--法阵启动
function battlefieldIdle(keys)
    local caster = keys.caster
    local casterLocation = caster:GetAbsOrigin()
    local ability = caster:GetAbilityByIndex(0)
    local refreshInterval = 20
    local casterTeam = caster:GetTeam()
    
    Timers:CreateTimer(0,function()
        print("particlesLaunch")
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

    for i=2,3,1 do
        local fieldCount = #Battlefields[i]
        if fieldCount > 0 then
            local LaunchBattlefield = Battlefields[i][fieldCount]
            local ability = LaunchBattlefield:GetAbilityByIndex(0)
            if LaunchBattlefield:HasModifier("modifier_battlefield_idle_ACT_datadriven") then
                LaunchBattlefield:RemoveModifierByName("modifier_battlefield_idle_ACT_datadriven")
            end
            ability:ApplyDataDrivenModifier(LaunchBattlefield, LaunchBattlefield, "modifier_battlefield_ability2_datadriven", {Duration = buffStay}) --此modifier会启动算法battlefieldLaunch
            ability:ApplyDataDrivenModifier(LaunchBattlefield, LaunchBattlefield, "modifier_battlefield_vision_datadriven", {Duration = buffStay})
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
    print("=================battlefieldLaunch==ininin==================")
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

            if  casterTeam == unitTeam and unit ~= caster then
                workingFlag = true
                break;
            end
        end

        
        if workingFlag == true and loadingFlag == false then
            print("==================================battlefieldLaunch===========workingFlagtrue==============")
            loadingFlag = true
            local goodTeamParticlesGetBuff = "particles/mofahen_huoqu_yang.vpcf"
            local badTeamParticlesGetBuff = "particles/mofahen_huoqu_yin.vpcf"
            local particlesGetBuff
            
        print("battlefieldIdle"..casterTeam.."================================="..DOTA_TEAM_GOODGUYS)
            if casterTeam == DOTA_TEAM_GOODGUYS then
                particlesGetBuff = "particles/mofahen_huoqu_yang.vpcf"
            end
            if casterTeam == DOTA_TEAM_BADGUYS then
                particlesGetBuff = "particles/mofahen_huoqu_yin.vpcf"
            end
            Timers:CreateTimer(0,function()
                local particleID = ParticleManager:CreateParticle(particlesGetBuff, PATTACH_ABSORIGIN_FOLLOW, caster)
                ParticleManager:SetParticleControl(particleID, 1, position)
                caster.loadingParticleID = particleID
            end)
        end
        if loadingFlag == true then
            count = count + 0.1
            print(count)
        end
        if workingFlag == false and loadingFlag == true then
            print("==================================battlefieldFlatl===========workingFlagfalse==============")
            loadingFlag = false
            ParticleManager:DestroyParticle(caster.loadingParticleID, true)
            count = 0
        end

        if string.format("%.1f",count) > string.format("%.1f",getBuffTime) then 
            battlefieldInit(caster)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            print("getBuff")
            return nil
        end

        if timerFlag == true and loadingFlag == false then
            battlefieldInit(caster)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            return nil
        end

        if caster:HasModifier("modifier_battlefield_ability2_datadriven") then
            return 0.1
        end
    end)

end

--初始化删除法阵激活的动作和特效
function battlefieldInit(caster)

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

function battlefieldDelete(caster)

    if caster.loadingParticleID ~= nil then
        print(caster.loadingParticleID)
        ParticleManager:DestroyParticle(caster.loadingParticleID, true)
    end
    if caster.idleParticleID ~= nil then
        print(caster.idleParticleID)
        ParticleManager:DestroyParticle(caster.idleParticleID, true)
    end

end

