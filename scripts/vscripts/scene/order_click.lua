require('shop')
require('game_init')
function treasureBoxInit(keys)
    local caster = keys.caster
	local position = caster:GetAbsOrigin()
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
    --print('getGoldCoin=========='..playerID.."="..worth)
    local playerGold = PlayerResource:GetGold(playerID) + worth
    --caster:ModifyGold(worth, true, 11) 
    PlayerResource:SetGold(playerID,playerGold,true)
    showGoldWorthParticle(playerID,worth)
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
    if caster:HasModifier('modifier_channel_act_datadriven') then
        caster:RemoveModifierByName('modifier_channel_act_datadriven')
    end
    
    playerOrderTimer[playerID] = nil
    local target = keys.target
    if target ~= nil  then
        local targetLabel = target:GetUnitLabel()
        --print('targetLabel:'..targetLabel)
        --如果是则开启打开进程(宝箱/商人/法阵)
        if targetLabel == GameRules.boxLabel or targetLabel == GameRules.shopLabel or targetLabel == GameRules.battlefieldLabel or targetLabel == GameRules.remainsLabel then
            playerOrderTarget[playerID] = target
            caster:AddAbility('hero_search_target_timer_datadriven'):SetLevel(1)
        end  
    end
end
 
function initHeroOpenBoxChannelSucceeded(keys)
    print("==========initHeroOpenBoxChannelSucceeded========")
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local target = playerOrderTarget[playerID]
    local targetName = target:GetUnitName()
    --print(target:GetUnitName())
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
        target.alive = 0
        target:AddNoDraw()
    end
end


function initHeroCaptureChannelSucceeded(keys)
    print("==========initHeroCaptureChannelSucceeded========")
    local caster = keys.caster
    if caster.battlefieldTarget ~= nil then
        local casterTeam = caster:GetTeam()
        local targetTeam = caster.battlefieldTarget:GetTeam()
        local stoneModifierName = "modifier_magic_stone_protect_datadriven"
        --[[
        if casterTeam == targetTeam then
            casterTeam = 3
        end]]
        --print("=========================initHeroCaptureChannelSucceeded==========================")
        --print("casterTeam:"..casterTeam..",casterBattlefields:"..#Battlefields[casterTeam])
        --print("targetTeam:"..targetTeam..",targetBattlefields:"..#Battlefields[targetTeam])       
        --刷新占领方本身前线法阵成为关闭状态
        local lastCasterFrontFieldNum = #Battlefields[casterTeam]
        local lastCasterFrontField = Battlefields[casterTeam][lastCasterFrontFieldNum]
        if lastCasterFrontField~= nil then
            battlefieldInit(lastCasterFrontField)
        end

        --刷新被占领法阵为占领方成为初始关闭状态
        captrueBattlefield(caster.battlefieldTarget, casterTeam)

        --刷新被占领方次前线法阵成为开启状态
        Battlefields[casterTeam][#Battlefields[casterTeam]+1] = Battlefields[targetTeam][#Battlefields[targetTeam]]
        Battlefields[targetTeam][#Battlefields[targetTeam]] = nil

        local goodFieldCount = #Battlefields[2]
        if goodFieldCount > 0 then
            LaunchGoodBattlefield = Battlefields[2][goodFieldCount]
            updateFrontBattlefield(LaunchGoodBattlefield)
            if not goodMagicStone:HasModifier(stoneModifierName) then
                goodMagicStone:GetAbilityByIndex(0):ApplyDataDrivenModifier( goodMagicStone, goodMagicStone, stoneModifierName, {})
            end
        end
        if goodFieldCount == 0 then
            LaunchGoodBattlefield = nil
            if goodMagicStone:HasModifier("modifier_magic_stone_protect_datadriven") then
                goodMagicStone:RemoveModifierByName("modifier_magic_stone_protect_datadriven")
            end
            print("goodFieldOver")
        end

        local badFieldCount = #Battlefields[3]
        if badFieldCount > 0 then
            LaunchBadBattlefield = Battlefields[3][badFieldCount]
            updateFrontBattlefield(LaunchBadBattlefield)
            if not badMagicStone:HasModifier("modifier_magic_stone_protect_datadriven") then
                badMagicStone:GetAbilityByIndex(0):ApplyDataDrivenModifier( badMagicStone, badMagicStone, stoneModifierName, {})
            end
        end

        if badFieldCount == 0 then
            LaunchBadBattlefield = nil
            if badMagicStone:HasModifier("modifier_magic_stone_protect_datadriven") then
                badMagicStone:RemoveModifierByName("modifier_magic_stone_protect_datadriven")
            end
            print("badFieldOver")
        end 
        --print("------------------------------initHeroCaptureChannelSucceeded----------------------------")
        --print("casterTeam:"..casterTeam..",casterBattlefields:"..#Battlefields[casterTeam])
        --print("targetTeam:"..targetTeam..",targetBattlefields:"..#Battlefields[targetTeam])
    end
end

function captrueBattlefield(battlefield,team)
    battlefield:SetTeam(team)
    battlefield:SetSkin(team-1)
    battlefieldInit(battlefield)
end

--刷新为最前线法阵
function updateFrontBattlefield(battlefield)
    if battlefield ~= nil then
        print("updateFrontBattlefield:"..battlefield.fieldName)
        local battlefieldAbility = battlefield:GetAbilityByIndex(0)
        battlefield:RemoveModifierByName("modifier_battlefield_flatl_datadriven")
        battlefieldAbility:ApplyDataDrivenModifier(battlefield, battlefield, "modifier_battlefield_idle_datadriven", {Duration = -1}) 
        battlefieldAbility:ApplyDataDrivenModifier(battlefield, battlefield, "modifier_battlefield_idle_ACT_datadriven", {Duration = -1})  
    end
end

--法阵初始化
function battlefieldInit(caster)
    print("battlefieldInit:"..caster.fieldName)
    local ability = caster:GetAbilityByIndex(0)
    if caster:HasModifier("modifier_battlefield_idle_datadriven") then
        caster:RemoveModifierByName("modifier_battlefield_idle_datadriven")
    end
    if caster:HasModifier("modifier_battlefield_idle_ACT_datadriven") then
        caster:RemoveModifierByName("modifier_battlefield_idle_ACT_datadriven")
    end
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
    if caster.idleParticleID ~= nil then
        ParticleManager:DestroyParticle(caster.idleParticleID, true)
    end
    ability:ApplyDataDrivenModifier(caster, caster, "modifier_battlefield_flatl_datadriven", {Duration = -1}) 
end

function initHeroSearchTarget(keys)
    print("==========initHeroSearchTarget========")
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    local casterTeam = caster:GetTeam()
    local target = playerOrderTarget[playerID]
    local targetTeam = target:GetTeam()
    local ability = caster:GetAbilityByIndex(9) --keys.ability--打开箱子的技能
    playerOrderTimer[playerID] = 0.1
    Timers:CreateTimer(function()
        if target:IsAlive() then
            local casterLocation = caster:GetAbsOrigin()
            local targetLocation = target:GetAbsOrigin()
            local distance = (casterLocation - targetLocation ):Length2D()
            --  print(distance)
             --如果是箱子则启动打开进程
            if distance < 150 then
                if caster:HasAbility('hero_search_target_timer_datadriven') then
                    caster:RemoveAbility('hero_search_target_timer_datadriven')
                end
            
                if caster:HasModifier('modifiers_hero_search_target_timer_datadriven') then
                    caster:RemoveModifierByName('modifiers_hero_search_target_timer_datadriven')
                end
                playerOrderTimer[playerID] = nil
                local targetLabel = target:GetUnitLabel()
                --打开箱子
                if targetLabel == GameRules.boxLabel then
                    print(targetLabel)
                    caster:CastAbilityNoTarget(caster:GetAbilityByIndex(10),playerID)
                end
                --打开商店
                if targetLabel == GameRules.shopLabel then
                    print(targetLabel)
                    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "shopDoorOperationLUATOJS", {})
                end

                --抢夺法阵
                if targetLabel == GameRules.battlefieldLabel and casterTeam ~= targetTeam then
                    print(targetLabel)
                    if target:HasModifier("modifier_battlefield_idle_datadriven") then
                        caster:CastAbilityNoTarget(caster:GetAbilityByIndex(11),playerID)
                        caster.battlefieldTarget = target
                    end
                end

                --拾取遗物
                if targetLabel == GameRules.remainsLabel then
                    local itemCount = caster:GetNumItemsInInventory()
                    if itemCount <= 9 and casterTeam == targetTeam then
                        local ownerItem = CreateItem("item_remains_box", hHero, hHero)
                        caster:AddItem(ownerItem)
                        target:SetModelScale(0.01)
                        target:ForceKill(true)
                        target.alive = 0
                    else
                        print("物品栏已满或不是你队伍的")
                    end
                end

                return nil
            end
            return playerOrderTimer[playerID]
        end
    end)
end



