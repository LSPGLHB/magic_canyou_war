function magicStoneBroken(magicStone)
    local team = magicStone:GetTeam()
    if team == DOTA_TEAM_BADGUYS then
        vpcfFile = "particles/yinmofashibaozha.vpcf"
    end
    if team == DOTA_TEAM_GOODGUYS then
        vpcfFile = "particles/yangmofashibaozha.vpcf"
    end
    local postion = magicStone:GetAbsOrigin()
    local particleID = ParticleManager:CreateParticle(vpcfFile, PATTACH_WORLDORIGIN, magicStone)
	ParticleManager:SetParticleControl(particleID, 0, postion)
    EmitSoundOn("scene_voice_magic_stone_broken",magicStone)
    
end