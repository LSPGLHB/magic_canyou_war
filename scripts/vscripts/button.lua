require('shop')
require('get_magic')
require('player_status')
function initShopStats()
    Timers:CreateTimer(0,function ()
        --print("==============checkShop================")
        for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
            if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
                local player = PlayerResource:GetPlayer(playerID)
                local hero = player:GetAssignedHero()
                local position = hero:GetAbsOrigin()
                local heroTeam = hero:GetTeam()
                local searchRadius = 700
                local shopFlag = "unkown"  
                local playerGold = PlayerResource:GetGold(playerID)
                local aroundUnits = FindUnitsInRadius(heroTeam, 
                                                    position,
                                                    nil,
                                                    searchRadius,
                                                    DOTA_UNIT_TARGET_TEAM_BOTH,
										            DOTA_UNIT_TARGET_ALL,
                                                    0,
                                                    0,
                                                    false)             
                for k,unit in pairs(aroundUnits) do
                    local lable =unit:GetUnitLabel()
                    local unitTeam = unit:GetTeam()		
                    if hero ~= unit and unitTeam == heroTeam and  GameRules.shopLabel == lable then
                        shopFlag = "active"
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer( player , "checkShopLUATOJS", {
                    flag = shopFlag,
                    playerGold = playerGold
                })
            end
        end
        return 0.3
    end)
end

function openShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    --local player = PlayerResource:GetPlayer(playerID)
    OnMyUIShopOpen(playerID)
    getPlayerShopListByRandomList(playerID, playerRandomItemNumList[playerID])
end

function closeShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    OnMyUIShopClose(playerID)
end

function refreshShopJSTOLUA(index,keys)
    local playerID = keys.PlayerID
    --local player = PlayerResource:GetPlayer(playerID)
    local currentGold = PlayerResource:GetGold(playerID)
    local refreshCost = playerRefreshCost[playerID]
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    if currentGold >= refreshCost then
        --playerShopLock[playerID] = 0
        PlayerResource:SpendGold(playerID, refreshCost,0)
        currentGold = PlayerResource:GetGold(playerID)
       
	    EmitSoundOn("scene_voice_shop_refresh", hHero)
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "checkGoldLUATOJS", {
            playerGold = currentGold
        })
        playerRefreshCost[playerID] = refreshCost + GameRules.refreshCostAdd
        refreshShopListByPlayerID(playerID)
        OnMyUIShopClose(playerID)
        OnMyUIShopOpen(playerID)
        getPlayerShopListByRandomList(playerID, playerRandomItemNumList[playerID])
    else
        EmitSoundOn("scene_voice_player_disable", hHero)
        print("金币不足")
    end
end


--刷新商店商品
function refreshShopListByPlayerID(playerID)
    local gameRound = GameRules.gameRound
    local itemNameList = shopProbabilityItemByRound[gameRound]--GameRules.itemNameList
    local count = #itemNameList
    
    --print("itemNameList=====================",count)
    --print("================================================================refreshShopListByPlayerID:"..playerShopLock[playerID])
    playerRandomItemNumList[playerID] = getRandomNumList(1,count,6)

end


--打开全局信息栏
function openPlayerStatusJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    local myPlayer = PlayerResource:GetPlayer(myPlayerID)
    myPlayer.playerStatusShow = true
    OnMyUIPlayerStatusOpen( myPlayerID )
    showPlayerStatusPanel( myPlayerID )  

end

function closePlayerStatusJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    local myPlayer = PlayerResource:GetPlayer(myPlayerID)
    myPlayer.playerStatusShow = false
    OnMyUIPlayerStatusClose(myPlayerID)
end

function getRandomGoldJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    --local myPlayer = PlayerResource:GetPlayer(myPlayerID)
    --local hHero = PlayerResource:GetSelectedHeroEntity(myPlayerID)
    local min = keys.min
    local max = keys.max
    local randomGold = string.format("%.1f", math.random()) * (max-min) + min
    local playerGold = PlayerResource:GetGold(myPlayerID) + randomGold
    PlayerResource:SetGold(myPlayerID,playerGold,true)
    showGoldWorthParticle(myPlayerID,randomGold)
    --添加获取金币声音
    
end

--test
function buttonaJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openMagicListPreC(myPlayerID)
end

function buttonbJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openMagicListPreB(myPlayerID)
end

function buttoncJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openMagicListPreA(myPlayerID)
end

function buttondJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openRandomContractList(myPlayerID)
end

function buttoneJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openMagicListC(myPlayerID)
end

function buttonfJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openMagicListB(myPlayerID)
end

function buttongJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openMagicListA(myPlayerID)
end

function buttonhJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openRebuildMagicList(myPlayerID)
end

function buttoniJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openRandomTalentCList(myPlayerID)
end

function buttonjJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openRandomTalentBList(myPlayerID)
end

function buttonkJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    openRandomTalentAList(myPlayerID)
end

function buttonlJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    heroRespawn(myPlayerID)
end

function buttonmJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(myPlayerID)

    hHero:GetAbilityByIndex(0):EndCooldown()
    hHero:GetAbilityByIndex(1):EndCooldown()
    hHero:GetAbilityByIndex(2):EndCooldown()
    hHero:GetAbilityByIndex(3):EndCooldown()
    hHero:GetAbilityByIndex(4):EndCooldown()
    hHero:GetAbilityByIndex(5):EndCooldown()
    hHero:GetAbilityByIndex(6):EndCooldown()
    hHero:GetAbilityByIndex(7):EndCooldown()
    hHero:GetAbilityByIndex(8):EndCooldown()

    local abilityNameC = hHero:GetAbilityByIndex(6):GetAbilityName()
    local abilityNameB = hHero:GetAbilityByIndex(7):GetAbilityName()
    local abilityNameA = hHero:GetAbilityByIndex(8):GetAbilityName()
    local modifierNameC = "modifier_"..abilityNameC.."_buff"
    local modifierNameB = "modifier_"..abilityNameB.."_buff"
    local modifierNameA = "modifier_"..abilityNameA.."_buff"

    if hHero:HasModifier(modifierNameC) then
        hHero:RemoveModifierByName(modifierNameC)
    end
    if hHero:HasModifier(modifierNameB) then
        hHero:RemoveModifierByName(modifierNameB)
    end
    if hHero:HasModifier(modifierNameA) then
        hHero:RemoveModifierByName(modifierNameA)
    end
end


function heroRespawn(myPlayerID)
    local hHero = PlayerResource:GetSelectedHeroEntity(myPlayerID)
    if not hHero:IsAlive() then
        hHero:RespawnUnit()
    end
end

function buttonnJSTOLUA(index,keys)
    local myPlayerID = keys.PlayerID
    local hHero = PlayerResource:GetSelectedHeroEntity(myPlayerID)
    hHero:ForceKill(false)
end


