require('shop')
function treasureBoxInit(keys)
    local caster = keys.caster
    local casterTeam = caster:GetTeam()
	local position = caster:GetAbsOrigin()
    local openBoxTime = string.format("%.1f",3.0)
    local searchRadius = 100
    local countTime = 0
    local openUnit = nil
    Timers:CreateTimer(0,function()
        local particlesName = "particles/baoxiangtexiao.vpcf"
        local particleID = ParticleManager:CreateParticle(particlesName, PATTACH_WORLDORIGIN, caster)
        caster.particleID = particleID
        ParticleManager:SetParticleControl(particleID, 1, position)
    end)


end


function getGoldCoin(keys)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local worth = keys.worth
    local holder = keys.holder
    --print('========================'..playerID)

    PlayerResource:SetGold(playerID,worth,true)

end


function initHeroOrder(keys)
    print("===initHeroOrder===")
    local caster = keys.caster
    local casterTeam = caster:GetTeam()
    local playerID = caster:GetPlayerID()
    --local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    
    


    if caster:HasAbility('hero_search_target_timer_datadriven') then
        caster:RemoveAbility('hero_search_target_timer_datadriven')
    end

    if caster:HasModifier('modifiers_hero_search_target_timer_datadriven') then
        caster:RemoveModifierByName('modifiers_hero_search_target_timer_datadriven')
    end
    local target = keys.target

    if target ~= nil  then
        local targetLabel = target:GetUnitLabel()
        print('targetLabel:'..targetLabel)
        --如果是宝箱或者商人则开启打开进程
        if targetLabel == GameRules.boxLabel or targetLabel == GameRules.shopLabel then
            playerOrderTarget[playerID] = target
            caster:AddAbility('hero_search_target_timer_datadriven'):SetLevel(1)
        end
       
    end

end


function initHeroChannelSucceeded(keys)
    print("==========initHeroChannelSucceeded========")
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local target = playerOrderTarget[playerID]
    local targetName = target:GetUnitName()
    print(target:GetUnitName())

    --如果目标是金币箱子，打开掉落金币
    if targetName == TreasureBoxGold then
        local position = target:GetAbsOrigin()
        RollDrops(target)
        --openUnit:AddAbility('get_gold_passive'):SetLevel(1)
        ParticleManager:DestroyParticle(target.particleID, true)
        local particlesGold =  "particles/shiqujinbi.vpcf"
        local particleGoldID = ParticleManager:CreateParticle(particlesGold, PATTACH_WORLDORIGIN, target)
        ParticleManager:SetParticleControl(particleGoldID, 0, position)
        target:ForceKill(true)
        target:AddNoDraw()
    end
end


function initHeroSearchTarget(keys)
    print("==========initHeroSearchTarget========")
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local target = playerOrderTarget[playerID]
    local ability = caster:GetAbilityByIndex(9) --keys.ability--打开箱子的技能

    Timers:CreateTimer(function()
        if target:IsAlive() then
            local casterLocation = caster:GetAbsOrigin()
            local targetLocation = target:GetAbsOrigin()
            local distance = (casterLocation - targetLocation ):Length2D()
            print(distance)
             --如果是箱子则启动打开进程
            if distance < 200 then
                if caster:HasAbility('hero_search_target_timer_datadriven') then
                    caster:RemoveAbility('hero_search_target_timer_datadriven')
                end
            
                if caster:HasModifier('modifiers_hero_search_target_timer_datadriven') then
                    caster:RemoveModifierByName('modifiers_hero_search_target_timer_datadriven')
                end
                local targetLabel = target:GetUnitLabel()
                if targetLabel == GameRules.boxLabel then
                    print(targetLabel)
                    Timers:CreateTimer(0,function()
                        caster:CastAbilityNoTarget(ability,playerID) --进行打开箱子操作
                    end)
                end
                if targetLabel == GameRules.shopLabel then
                    print(targetLabel)
                    OnMyUIShopOpen(playerID)
                    getPlayerShopListByRandomList(playerID, playerRandomItemNumList[playerID])
                end
                return nil
            end

            return 0.2
        end
    end)

end


