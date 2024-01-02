function grassBuffWork()
    local grassEntities = Entities:FindByName(nil,"grassUnit") 
    local grassEntities2 = Entities:FindByName(nil,"grassUnit2") 
    
    local grassLocation = grassEntities:GetAbsOrigin()
    local grassLocation2 = grassEntities2:GetAbsOrigin()

    local grassArea = CreateUnitByName("grassUnit", grassLocation, true, nil, nil, DOTA_TEAM_GOODGUYS)
    grassArea:GetAbilityByIndex(0):SetLevel(1)
    
    local tempAbility = grassArea:GetAbilityByIndex(0)
    grassArea.aroundUnits = {}
    
    local searchRadius = 200
    local yinshenModifier = 'modifier_yinshen_datadriven'
    local fanyinModifier = 'modifier_fanyin_datadriven'
    local interval = 0.05
    Timers:CreateTimer(function ()
        local aroundUnits = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, 
                                            grassLocation,
                                            nil,
                                            searchRadius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)

        local aroundUnits2 = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, 
                                            grassLocation2,
                                            nil,
                                            searchRadius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)

        local allUnits = getAllUnits(aroundUnits,aroundUnits2,grassArea)
        grassArea.allUnits = allUnits
        local seeFlag = grassCheckSeeFlag(grassArea)
                      
        for _,unit in pairs(allUnits) do
            if grassArea ~= unit then
                if seeFlag then
                    if unit:HasModifier(yinshenModifier) then
                        unit:RemoveModifierByName(yinshenModifier)
                    end
                    if not unit:HasModifier(fanyinModifier) then
                        tempAbility:ApplyDataDrivenModifier(unit, unit, fanyinModifier, {Duration = -1})
                    end
                else
                    if unit:HasModifier(fanyinModifier) then
                        unit:RemoveModifierByName(fanyinModifier)
                    end
                    if not unit:HasModifier(yinshenModifier) then
                        tempAbility:ApplyDataDrivenModifier(unit, unit, yinshenModifier, {Duration = -1})
                    end
   
                end

            end
        end
        refreshGrassByArray(grassArea,yinshenModifier,fanyinModifier)
        return interval
    end)
end

function getAllUnits(units_1,units_2,caster)
    local allUnits = {}
    for _, value in ipairs(units_1) do
        local targetLabel = value:GetUnitLabel()
        if not containsArrayValue(allUnits, value) and value ~= caster and (targetLabel == GameRules.summonLabel or value:IsHero()) then
            table.insert(allUnits, value)
        end
    end
    for _, value in ipairs(units_2) do
        local targetLabel = value:GetUnitLabel()
        if not containsArrayValue(allUnits, value) and value ~= caster and (targetLabel == GameRules.summonLabel or value:IsHero())  then
            table.insert(allUnits, value)
        end
    end
    return allUnits
end

function containsArrayValue(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function grassCheckSeeFlag(grass)
    local allUnits = grass.allUnits
    local tempAbility = grass:GetAbilityByIndex(0)
    local seeFlag = false
    local tempTeam
    
    for i = 1, #allUnits, 1 do
        local nowTeam = allUnits[i]:GetTeam()
        --print(nowTeam)
        if tempTeam ~= nil and tempTeam ~= nowTeam then
            seeFlag = true
        end
        tempTeam = nowTeam
    end
    return seeFlag
end

function refreshGrassByArray(grass, yinshenModifier,fanyinModifier)
    local oldArray = {}
    oldArray = grass.aroundUnits
    local newArray = {}
    newArray = grass.allUnits
    for i = 1, #oldArray do
        local flag = true
        for j = 1, #newArray do
            if oldArray[i] == newArray[j] then
                flag = false
            end
        end
        if flag then
            if oldArray[i]:HasModifier(yinshenModifier) then
                oldArray[i]:RemoveModifierByName(yinshenModifier)
            end
            if oldArray[i]:HasModifier(fanyinModifier) then
                oldArray[i]:RemoveModifierByName(fanyinModifier)
            end
        end
    end
    grass.aroundUnits = grass.allUnits
end

function yinshenOnCreated(keys)
	local caster = keys.caster--self:GetCaster()
	local ability = keys.ability--self:GetAbility()
	--local unit = self:GetParent()
	caster:AddNewModifier(caster, ability,"modifier_invisible",{duration = -1})
    print("yinshen")
end

function yinshenOnDestroy(keys)
	local caster = keys.caster--self:GetCaster()
	--local ability = self:GetAbility()
	--local unit = self:GetParent()
	--caster:AddNewModifier(caster, ability,"modifier_invisible",{duration = -1})
    caster:RemoveModifierByName("modifier_invisible")
    print("xianshen")
end




fanyin_modifier=({})

function fanyin_modifier:CheckState()
	local state = {
        [MODIFIER_STATE_PROVIDES_VISION] = true
	}
	return state
end
