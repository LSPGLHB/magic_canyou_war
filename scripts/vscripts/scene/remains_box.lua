require('game_init')
function openRemainsBox(keys)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local bingoRandom = math.random(1,100)
    if bingoRandom < 2 then 
        EmitSoundOn("scene_voice_coin_get_big", caster)
        reward = math.random(40,50)
    else
        if bingoRandom < 7 then
            reward = math.random(12,40)
            EmitSoundOn("scene_voice_coin_get_big", caster)
        else
            if bingoRandom < 20 then
                reward = math.random(8,12)
                EmitSoundOn("scene_voice_coin_get_small", caster)
            else
                if bingoRandom < 45 then
                    reward = math.random(5,8)
                    EmitSoundOn("scene_voice_coin_get_small", caster)
                else
                    reward = math.random(3,5)
                    EmitSoundOn("scene_voice_coin_get_small", caster)
                end
            end
        end
       
    end
    
    --local playerGold = PlayerResource:GetGold(playerID) + reward
    local playerGold = caster:GetGold() + reward
  
    PlayerResource:SetGold(playerID,playerGold,true)
    local hHero = PlayerResource:GetSelectedHeroEntity(playerID)
    --caster:ModifyGold(reward, true, 12)--SetGold(reward,true)
    local particlesGold = "particles/shiqujinbi.vpcf"
    local particleGoldID = ParticleManager:CreateParticle(particlesGold, PATTACH_OVERHEAD_FOLLOW, caster)
    ParticleManager:SetParticleControl(particleGoldID, 0, caster:GetAbsOrigin())
end

