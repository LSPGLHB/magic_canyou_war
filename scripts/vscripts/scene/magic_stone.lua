function magicStoneGoodDestroy(keys)
    print("magicStoneGoodDestroy")
    if GameRules.checkWinTeam == nil then
        GameRules.checkWinTeam = DOTA_TEAM_BADGUYS
    end
end


function magicStoneBadDestroy(keys)
    print("magicStoneBadDestroy")
    if GameRules.checkWinTeam == nil then
        GameRules.checkWinTeam = DOTA_TEAM_GOODGUYS
    end
end