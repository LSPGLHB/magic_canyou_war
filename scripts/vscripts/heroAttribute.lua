function OnMyUIHeroAttributeOpen( playerID )
    CustomUI:DynamicHud_Create(playerID,"UIHeroAttributePanelBG","file://{resources}/layout/custom_game/UI_hero_attribute.xml",nil)
end                                     

function OnMyUIHeroAttributeClose(playerID)
	CustomUI:DynamicHud_Destroy(playerID,"UIHeroAttributePanelBG")
end

function showHeroAttributePanel(playerID) 
    local heroPower = {}
    local arryCount = 1
    local tempAttribute = PlayerPower[playerID]

    for name, value in pairs(tempAttribute) do
        local indexStr = string.find(name, "_") + 1
        local indexFlag = string.find(name, "flag")
        --print("indexStr:"..indexStr)
        local tempName = string.sub(name, indexStr)
        local newFlag = true
        
        if value ~= 0 and indexFlag == nil then
            for i = 1 , #heroPower , 1 do
                --print("name1:"..heroPower[i]["name"].."=="..tempName)
                if heroPower[i]["name"] == tempName then
                    heroPower[i]["value"] = heroPower[i]["value"] + value
                    newFlag = false
                    break
                end
            end
            if newFlag then
                heroPower[arryCount] = {}
                heroPower[arryCount]["name"] = tempName
                heroPower[arryCount]["value"] = value
                --print("name:"..name.."=="..value)
                arryCount = arryCount + 1
            end
        end
    end
    --print("arryCount:"..arryCount)
    local myPlayer = PlayerResource:GetPlayer(playerID)
    CustomGameEventManager:Send_ServerToPlayer( myPlayer , "openHeroAttributeLUATOJS", {  
        heroPower = heroPower,
        arryCount = arryCount
    })
end
