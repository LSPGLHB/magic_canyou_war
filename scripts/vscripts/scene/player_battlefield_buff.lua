require('player_power')
require('game_init')
function modifier_battlefield_vision_buff_on_created(keys)
    print("onCreated")
    refreshVisionBuff(keys,true)
end

function modifier_battlefield_vision_buff_on_destroy(keys)
    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    refreshVisionBuff(keys,false)
    local abilityName = "battlefield_vision_buff_datadriven"
    removePlayerBuffByAbilityAndModifier(hero, abilityName, "nil", "nil")
end

function refreshVisionBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local powerName = "battlefield_vision"
    local buffName = "vision"
    local vision_init_val

    if flag then
        vision_init_val = BattlefieldBuffVision[BattlefieldBuffLvl] 
        playerBattlefieldBuff[playerID][buffName] = vision_init_val --记录buff的能力值
    else
        vision_init_val = playerBattlefieldBuff[playerID][buffName]
        playerBattlefieldBuff[playerID][buffName] = 0
    end
    print("BattlefieldBuffLvl:"..BattlefieldBuffLvl)
    print("vision_init_val:"..vision_init_val)
    setPlayerPower(playerID, powerName, flag, vision_init_val)
    setPlayerBuffByNameAndBValue(keys,buffName,GameRules.playerBaseVision)
end



function modifier_battlefield_speed_buff_on_created(keys)
    print("onCreated")
    refreshSpeedBuff(keys,true)
end

function modifier_battlefield_speed_buff_on_destroy(keys)
    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    refreshSpeedBuff(keys,false)
    local abilityName = "battlefield_speed_buff_datadriven"
    removePlayerBuffByAbilityAndModifier(hero, abilityName, "nil", "nil")
end

function refreshSpeedBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()

    local powerName = "battlefield_speed"
    local buffName = "speed"
    local speed_init_val
 
    if flag then
        speed_init_val = BattlefieldBuffSpeed[BattlefieldBuffLvl] 
        playerBattlefieldBuff[playerID][buffName] = speed_init_val --记录buff的能力值
    else
        speed_init_val = playerBattlefieldBuff[playerID][buffName]
        playerBattlefieldBuff[playerID][buffName] = 0
    end
    print("BattlefieldBuffLvl:"..BattlefieldBuffLvl)
    print("speed_init_val:"..speed_init_val)
    setPlayerPower(playerID, powerName, flag, speed_init_val)
    setPlayerBuffByNameAndBValue(keys,buffName,GameRules.playerBaseSpeed)
end




function modifier_battlefield_mana_regen_buff_on_created(keys)
    print("onCreated")
    refreshManaRegenBuff(keys,true)
end

function modifier_battlefield_mana_regen_buff_on_destroy(keys)
    print("onDestroy")
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    refreshManaRegenBuff(keys,false)
    local abilityName = "battlefield_mana_regen_buff_datadriven"
    removePlayerBuffByAbilityAndModifier(hero, abilityName, "nil", "nil")
end

function refreshManaRegenBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local powerName = "battlefield_mana_regen"
    local buffName = "mana_regen"
    local mana_regen_init_val 
    
    if flag then
        mana_regen_init_val = BattlefieldBuffManaRegen[BattlefieldBuffLvl] 
        playerBattlefieldBuff[playerID][buffName] = mana_regen_init_val --记录buff的能力值
    else
        mana_regen_init_val = playerBattlefieldBuff[playerID][buffName]
        playerBattlefieldBuff[playerID][buffName] = 0
    end
    print("BattlefieldBuffLvl:"..BattlefieldBuffLvl)
    print("mana_regen_init_val:"..mana_regen_init_val)
    setPlayerPower(playerID, powerName, flag, mana_regen_init_val)
    setPlayerBuffByNameAndBValue(keys, buffName,GameRules.playerBaseManaRegen)
end








