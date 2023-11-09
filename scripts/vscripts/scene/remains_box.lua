require('game_init')
function openRemainsBox(keys)
    local caster = keys.caster
    local playerID = caster:GetPlayerID()
    local reward = math.random(5,15)
    if reward >= 12 then
        EmitSoundOn("scene_voice_coin_get_big", caster)
    else
        EmitSoundOn("scene_voice_coin_get_small", caster)
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

