
--法阵初始化
function createBattlefield()
    
    
    GoodBattlefields = {}
    LaunchGoodBattlefield = 'nil'
    
    for i=1, 3 ,1 do
        local fieldName = "goodBattlefield"..i

        local goodBattlefieldEntities = Entities:FindByName(nil,fieldName) 
        local goodBattlefieldLocation = goodBattlefieldEntities:GetAbsOrigin()
        local goodBattlefield = CreateUnitByName("battlefield", goodBattlefieldLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)

        GoodBattlefields[i] = goodBattlefield
        local goodBattlefieldAbility = goodBattlefield:GetAbilityByIndex(0)
        goodBattlefieldAbility:SetLevel(1)
        goodBattlefield:SetSkin(1)
        goodBattlefieldAbility:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_flatl_datadriven", {Duration = -1}) 
        if i == 3 then
            goodBattlefield:RemoveModifierByName("modifier_battlefield_flatl_datadriven")
            goodBattlefieldAbility:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_idle_datadriven", {Duration = -1}) 
            goodBattlefieldAbility:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            LaunchGoodBattlefield = goodBattlefield
            --[[
            Timers:CreateTimer(0,function()
                local particleID = ParticleManager:CreateParticle(particlesLaunch, PATTACH_ABSORIGIN_FOLLOW, goodBattlefield)
                ParticleManager:SetParticleControl(particleID, 3, goodBattlefieldLocation)
            end)]]
        end
        --ability:ApplyDataDrivenModifier(goodBattlefield, goodBattlefield, "modifier_battlefield_vision_datadriven", {Duration = -1})  
    end

    BadBattlefields = {}
    LaunchBadBattlefield = 'nil'
    for i=1, 3 ,1 do
        local fieldName = "badBattlefield"..i
        local badBattlefieldEntities = Entities:FindByName(nil,fieldName) 
        local badBattlefieldLocation = badBattlefieldEntities:GetAbsOrigin()
        local badBattlefield = CreateUnitByName("battlefield", badBattlefieldLocation, true, nil, nil, DOTA_TEAM_BADGUYS)
        BadBattlefields[i] = badBattlefield
        local badBattlefieldAbility = badBattlefield:GetAbilityByIndex(0)
        badBattlefieldAbility:SetLevel(1)
        badBattlefield:SetSkin(2)
        badBattlefieldAbility:ApplyDataDrivenModifier(badBattlefield, badBattlefield, "modifier_battlefield_flatl_datadriven", {Duration = -1}) 
        if i == 3 then
            badBattlefield:RemoveModifierByName("modifier_battlefield_flatl_datadriven")
            badBattlefieldAbility:ApplyDataDrivenModifier(badBattlefield, badBattlefield, "modifier_battlefield_idle_datadriven", {Duration = -1}) 
            badBattlefieldAbility:ApplyDataDrivenModifier(badBattlefield, badBattlefield, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            LaunchBadBattlefield = badBattlefield
            --[[
            Timers:CreateTimer(0,function()
                local particleID = ParticleManager:CreateParticle(particlesLaunch, PATTACH_ABSORIGIN_FOLLOW, BadBattlefield)
                ParticleManager:SetParticleControl(particleID, 3, badBattlefieldLocation)
            end)]]
        end
    end
end

--法阵启动
function battlefieldIdle(keys)
    local caster = keys.caster
    local casterLocation = caster:GetAbsOrigin()
    local ability = caster:GetAbilityByIndex(0)
    local refreshInterval = 20
    local buffStay = 10
    local particlesLaunch = "particles/mofazhen_dizuo_1.vpcf"

    Timers:CreateTimer(refreshInterval,function()
        caster:RemoveModifierByName("modifier_battlefield_idle_ACT_datadriven")
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_ability2_datadriven", {Duration = buffStay}) 
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_vision_datadriven", {Duration = buffStay})

        local particleID = ParticleManager:CreateParticle(particlesLaunch, PATTACH_ABSORIGIN_FOLLOW, caster)
        local groundPos = GetGroundPosition(caster:GetAbsOrigin(), caster)
        ParticleManager:SetParticleControl(particleID, 3, Vector(groundPos.x,groundPos.y,groundPos.z+10))
        caster.buffParticleID = particleID
        Timers:CreateTimer(buffStay,function()
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
            ParticleManager:DestroyParticle(particleID, true)
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 

        end)



        return refreshInterval
    end)
end


function battlefieldLaunch(keys)
    local caster = keys.caster
    local position = caster:GetAbsOrigin()
    local casterTeam = caster:GetTeam()
    local ability = caster:GetAbilityByIndex(0)
    local workingFlag = false
    local loadingFlag = false
    local radius = 200
    local count = 0
    local getBuffTime = 3.1
    print("=================battlefieldLaunch==ininin==================")
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
            local particlesGetBuff = "particles/mofahen_huoqu_yang.vpcf"
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

        if string.format("%.1f",count) == string.format("%.1f",getBuffTime) then 
            ParticleManager:DestroyParticle(caster.buffParticleID, true)
            ParticleManager:DestroyParticle(caster.loadingParticleID, true)
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
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1}) 
            print("getBuff")
            return nil
        end

        if caster:HasModifier("modifier_battlefield_ability2_datadriven") then
            return 0.1
        end
    end)

end