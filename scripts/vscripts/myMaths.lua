--取出n个随机技能
function getRandomArrayList(arrayList, randomNumList)

    local randomArrayList = {}
    for i = 1, #randomNumList do
        local tempNum = randomNumList[i]
        if tempNum == -1 then
            table.insert(randomArrayList,"sellOut")
        end
        --print("randomNumList",tempNum,arrayList[tempNum])
        if tempNum ~= -1 then
            table.insert(randomArrayList,arrayList[tempNum])
        end
        --print("randomNumList"..tempNum..":"..abilityNameList[tempNum])
    end
   --[[
    print("randomAbilityList------------: "..#randomAbilityList)
    for i = 1, #randomAbilityList do
        print(i ..":".. randomAbilityList[i])
    end]]
    return randomArrayList
end

--获取count个From-To的不重复的随机数组      
function getRandomNumList(from, to, count)
    local randomNum = 0
    local randomBox = {}
    local tempBox = {}
	--local count2 = count

    for  i = from , to do
       table.insert(tempBox,i)
    end
	--print("randomNum:============:",from,"-",to)
    while count > 0 do
        randomNum = math.random(1, to-from+1)
        table.insert(randomBox,tempBox[randomNum])
        table.remove(tempBox,randomNum)
        to = to - 1
        count = count -1

    end
    return randomBox
end

--合并去重
function arrayMerge(arr1,arr2)
    local result = {}
    if arr1 ~= nil and #arr1 > 0 then
        for _, value in ipairs(arr1) do
            table.insert(result, value)
        end
    end
    if arr2 ~= nil and #arr2 > 0 then
        for _, value in ipairs(arr2) do
            local isExist = false 
            for i, v in ipairs(result) do
                if v == value then
                    isExist = true
                    break
                end
            end
            
            if not isExist then
                table.insert(result, value)
            end
        end
    end
    return result
end

--是否包含
function checkContainsArrayValue(array, value)
    if array ~= nil and #array > 0 then
        for _, v in ipairs(array) do
            if v == value then
                return true
            end
        end
    end
    return false
end