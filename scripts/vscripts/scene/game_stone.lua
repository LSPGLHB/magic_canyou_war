function magicStoneBroken(magicStone)
    local team = magicStone:GetTeam()
    local vpcfFile
    if team == DOTA_TEAM_GOODGUYS then
        vpcfFile = "particles/yangmofashibaozha.vpcf"
    end
    if team == DOTA_TEAM_BADGUYS then
        vpcfFile = "particles/yinmofashibaozha.vpcf"
    end
    
    local postion = magicStone:GetAbsOrigin()
    local particleID = ParticleManager:CreateParticle(vpcfFile, PATTACH_WORLDORIGIN, magicStone)
	ParticleManager:SetParticleControl(particleID, 0, postion)
    EmitSoundOn("scene_voice_magic_stone_broken",magicStone)
    
end

function samsaraStonePiece(stone)
    local team = stone:GetTeam()
    local vpcfFile
    if team == DOTA_TEAM_GOODGUYS then
        vpcfFile = "particles/yanglunhuisuipiantexiao.vpcf"
    end
    if team == DOTA_TEAM_BADGUYS then
        vpcfFile = "particles/yinlunhuisuipiantexiao.vpcf"
    end
    local postion = stone:GetAbsOrigin()
    local particleID = ParticleManager:CreateParticle(vpcfFile, PATTACH_WORLDORIGIN, stone)
	ParticleManager:SetParticleControl(particleID, 1, postion)
    stone.particleID = particleID
    EmitSoundOn("scene_voice_samsara_stone_break", stone)
end