--玩家信息显示
function OnMyUIPlayerStatusOpen( playerID )
    CustomUI:DynamicHud_Create(playerID,"UIPlayerStatusPanelBG","file://{resources}/layout/custom_game/UI_player_status.xml",nil)
end

function OnMyUIPlayerStatusClose(playerID)
	CustomUI:DynamicHud_Destroy(playerID,"UIPlayerStatusPanelBG")
end

function OnMagicDetailOpen( playerID )
    CustomUI:DynamicHud_Create(playerID,"UIMagicDetailPanelBG","file://{resources}/layout/custom_game/UI_magic_detail.xml",nil)
end

function OnMagicDetailClose(playerID)
	CustomUI:DynamicHud_Destroy(playerID,"UIMagicDetailPanelBG")
end

function showPlayerStatusPanel(myPlayerID)
    --print("showPlayerStatusPanel")
    playerStatusHeroList = {}
    playerStatusTeamList = {}
    playerStatusAbilityList = {}
    playerStatusItemList = {}
    local arrayCount = 0
    for i=0,9,1  do
        playerStatusHeroList[i] = "nil"
        playerStatusTeamList[i] = 0
        playerStatusAbilityList[i]={}
        playerStatusItemList[i] ={}
        for j=0,3,1 do
            playerStatusAbilityList[i][j] = {}
            playerStatusAbilityList[i][j]['icon'] = 'nil'
        end
        for k=0,8,1 do
            playerStatusItemList[i][k] = {}
            playerStatusItemList[i][k]['icon'] = "nil"
            
        end
    end

    for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetConnectionState(playerID) ~= DOTA_CONNECTION_STATE_UNKNOWN then
            --playerStatusAbilityList[playerID] = {}
            local abilityNameList = {}
            local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
            local heroTeam = hHero:GetTeam()
            local heroName = PlayerResource:GetSelectedHeroName(playerID)     
            --local player = PlayerResource:GetPlayer(playerID)
            local hAbilityC = hHero:GetAbilityByIndex(0)
            local abilityNameC = hAbilityC:GetAbilityName()
            local hAbilityB = hHero:GetAbilityByIndex(1)
            local abilityNameB = hAbilityB:GetAbilityName()
            local hAbilityA = hHero:GetAbilityByIndex(2)
            local abilityNameA = hAbilityA:GetAbilityName()
            table.insert(abilityNameList,abilityNameC)
            table.insert(abilityNameList,abilityNameB)
            table.insert(abilityNameList,abilityNameA)
            local abilityArrayList = getAbilityListByNameList(abilityNameList)
            local itemArrayList =  getItemListByHero(hHero)
            playerStatusHeroList[playerID] = heroName
            playerStatusTeamList[playerID] = heroTeam
            arrayCount = arrayCount + 1
            for i=0, #abilityArrayList, 1 do
                playerStatusAbilityList[playerID][i] = abilityArrayList[i]
            end
            for j=0, #itemArrayList, 1 do
                playerStatusItemList[playerID][j] = itemArrayList[j]
            end

        end
    end
    local myPlayer = PlayerResource:GetPlayer(myPlayerID)

    
    CustomGameEventManager:Send_ServerToPlayer( myPlayer , "openPlayerStatusLUATOJS", {  
        playerStatusHeroList = playerStatusHeroList,
        playerStatusTeamList = playerStatusTeamList,
        playerBlinkLearn = playerBlinkLearn, --公共参数
        playerStatusAbilityList = playerStatusAbilityList,
        playerStatusItemList = playerStatusItemList,
        arrayCount = arrayCount,
        myPlayerID = myPlayerID
    })
end

function getAbilityListByNameList(nameList)
    local abilityList = GameRules.customAbilities
    local abilityArrayList = {}
    for i = 1 , #nameList , 1 do
        abilityArrayList[i] = {}
        for key, value in pairs(abilityList) do         
            if( key == nameList[i] ) then
                abilityArrayList[i]['name'] = key
                local c = 0
                for k,v in pairs(value) do
                    
                    if(k == "AbilityTextureName") then
                        abilityArrayList[i]['icon'] = v
                        c= c+1
                    end
                    --[[
                    if k == "AbilityLevel" then			
                        abilityArrayList[i]['AbilityLevel'] = v
                        c= c+1
                    end
                    if k == "UnitType" then
                        abilityArrayList[i]['UnitType']  = v
                        c= c+1
                    end]]
                    if k == "AbilityCooldown" then
                        abilityArrayList[i]['AbilityCooldown']  = v
                        c = c + 1
                    end
                    if k == "AbilityManaCost" then
                        abilityArrayList[i]['AbilityManaCost']  = v
                        c = c + 1
                    end
                    if k == "AbilitySpecial" then
                        local attributeCount = 1
                        abilityAttribute = {}
                        for x, y_table in pairs(v) do	
                            for ability_name,ability_val in pairs(y_table) do
                                if ability_name ~= 'var_type' then
                                    abilityAttribute[attributeCount] = {}
                                    abilityAttribute[attributeCount]["name"] = ability_name
                                    abilityAttribute[attributeCount]["value"] = ability_val
                                    
                                end
                            end
                            abilityAttribute["attributeCount"] = attributeCount
                            attributeCount = attributeCount + 1
                        end
                        abilityArrayList[i]['abilityAttribute'] = abilityAttribute
                        c = c + 1
                    end
                    if c == 4 then
                        break
                    end
                end
            end
        end
    end
    return abilityArrayList
end

function getItemListByHero(hHero)
    local itemList = GameRules.itemList
    local itemArrayList = {}
    for i = 0 , 5 , 1 do
        itemArrayList[i] = {}
        local item = hHero:GetItemInSlot(i-1)--物品栏从0开始
        if (item~=nil) then
            
            local itemName = item:GetName()
           -- print("itemName",itemName)
            for key, value in pairs(itemList) do
                if(key == itemName) then
                    --print("key",key)
                    
                    for k, v in pairs(value) do
                        if(k == "AbilityTextureName") then
                            --print("IconSrc",v)
                            itemArrayList[i]['icon']  = v
                        end
                    end
                end
            end
        end
    end
    return itemArrayList
end

--重做此处为指定阶段刷新
function refreshPlayerStatus(playerID)
    local player = PlayerResource:GetPlayer(playerID)
    Timers:CreateTimer(0,function ()
        if(player.playerStatusShow) then
            OnMyUIPlayerStatusClose(playerID)
            OnMyUIPlayerStatusOpen( playerID )
            showPlayerStatusPanel( playerID )
            return 1
        end
        return nil
    end)   
end


function getContractDetailByNumJSTOLUA(index,keys)
    local num  = keys.num
    local playerContractName =  playerContractNameList[num]
    print("getContractDetailByNumJSTOLUA:"..playerContractName)
end

function getMagicDetailByNumJSTOLUA(index,keys)
    local num  = keys.num
    local grid = keys.grid
    local playerID = keys.playerID
    local magicPanelPosition = keys.magicPanelPosition
    --print("num:"..num.."---grid:"..grid)
    local magicName =  playerStatusAbilityList[num][grid]['name']
    --local magicIcon = playerStatusAbilityList[num][grid]['icon']
    local magicCD = playerStatusAbilityList[num][grid]['AbilityCooldown']
    local magicMC = playerStatusAbilityList[num][grid]['AbilityManaCost']
    local magicAttribute = playerStatusAbilityList[num][grid]['abilityAttribute']
    --local attributeCount = #magicAttribute
    local classNameY = "magicDetailPostionY"..num
    local classNameX = "magicDetailPostionX"..grid
    --print("getMagicDetailByNumJSTOLUA:"..playerStatusAbilityName)
    --magicListByName[playerStatusAbilityName]
    local myPlayer = PlayerResource:GetPlayer(playerID)
    OnMagicDetailOpen(playerID)
    CustomGameEventManager:Send_ServerToPlayer( myPlayer , "openMagicDetailLUATOJS", {  
       magicName = magicName,
       magicIcon = magicIcon,
       magicCD = magicCD,
       magicMC = magicMC,
       magicAttribute = magicAttribute,
       classNameY = classNameY,
       classNameX = classNameX
    })
end

function getMagicDetailCloseJSTOLUA(index,keys)
    local playerID = keys.playerID
    OnMagicDetailClose(playerID)
end


function getItemDetailByNumJSTOLUA(index,keys)
    local num  = keys.num
    local grid = keys.grid
    --print("num:"..num.."---grid:"..grid)
    local playerStatusItemName=  playerStatusItemList[num][grid]   
    --print("getMagicDetailByNumJSTOLUA:"..playerStatusItemName)
    local itemNameList = GameRules.itemNameList
	local itemCostList = GameRules.itemCostList
	local itemTextureNameList = GameRules.itemTextureNameList
	local itemAttributeList = GameRules.itemAttributeList

end