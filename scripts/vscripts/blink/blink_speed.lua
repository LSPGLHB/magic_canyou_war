require('game_init')
require('shoot_init')
require('player_power')
blink_speed = ({})
blink_speed_passive = ({})
blink_speed_land = ({})
LinkLuaModifier("blink_speed_passive", "blink/blink_speed.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("blink_speed_land", "blink/blink_speed.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function blink_speed:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink_speed:GetIntrinsicModifierName()
	return "blink_speed_passive"
end

function blink_speed:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local fromParticle = "particles/shanxian_yisu_xiaoshi.vpcf"
    local toParticle = "particles/shanxian_yisu_chuxian.vpcf"
    EmitSoundOn("scene_voice_blink_speed_cast", caster)
    local newPosition = blinkOperation(caster, ability, fromParticle, toParticle, nil)
    local duration = ability:GetSpecialValueFor("duration")
    local searchAoeRadius = ability:GetSpecialValueFor("search_radius")
    local skillCount = 0
    caster.blinkSpeedLandStackCount = 0
    local aroundUnits = FindUnitsInRadius(caster:GetTeam(), 
                                            newPosition,
                                            nil,
                                            searchAoeRadius,
                                            DOTA_UNIT_TARGET_TEAM_BOTH,
                                            DOTA_UNIT_TARGET_ALL,
                                            0,
                                            0,
                                            false)
    for _, unit in pairs(aroundUnits) do
        if heroCheckSkill(caster,unit) and caster:GetTeam() ~= unit:GetTeam() then
            skillCount = skillCount + 1
        end
    end
    caster.blinkSpeedLandStackCount = skillCount
   
    
    caster:AddNewModifier(caster, ability, "blink_speed_land", {Duration = duration})
    if skillCount > 0 then
        caster:SetModifierStackCount("blink_speed_land",caster,skillCount)
    end

    caster.shootOver = -1
end

function blink_speed_land:IsBuff()
    return true
end

function blink_speed_land:GetEffectName()
	return "particles/shanxian_shensu_beidong.vpcf"
end

function blink_speed_land:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function blink_speed_land:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkSpeedPlusBuff(keys,true)
    end
end

function blink_speed_land:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkSpeedPlusBuff(keys,false)
    end
end

function refreshBlinkSpeedPlusBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local speed_plus = ability:GetSpecialValueFor("speed_plus")
    local speed_plus_step = ability:GetSpecialValueFor("speed_plus_step") 
    local stackCount = caster:GetModifierStackCount("blink_speed_land", caster)
    local speed = speed_plus + speed_plus_step * caster.blinkSpeedLandStackCount
    setPlayerPower(playerID, "contract_speed", flag, speed)

    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)


end




function blink_speed_passive:IsHidden()
    return true
end

function blink_speed_passive:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkSpeedBuff(keys,true)
    end
end

function blink_speed_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkSpeedBuff(keys,false)
    end
end

function refreshBlinkSpeedBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local health_percent = ability:GetSpecialValueFor("health_percent") 
    local speed = ability:GetSpecialValueFor("speed")
    local range = ability:GetSpecialValueFor("range")

    setPlayerPower(playerID, "contract_health_percent_final", flag, health_percent)
    setPlayerPower(playerID, "contract_speed", flag, speed)
    setPlayerPower(playerID, "contract_range", flag, range)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerBuffByNameAndBValue(keys,"speed",GameRules.playerBaseSpeed)
    setPlayerSimpleBuff(keys,"range")

end