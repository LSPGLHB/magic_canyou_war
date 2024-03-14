require('game_init')
require('shoot_init')
require('player_power')
blink_flythor = ({})
blink_flythor_passive = ({})
LinkLuaModifier("blink_flythor_passive", "blink/blink_flythor.lua" ,LUA_MODIFIER_MOTION_HORIZONTAL)

function blink_flythor:GetCastRange(v,t)
    local range = getRangeByName(self,'blink')
    return range
end

function blink_flythor:GetIntrinsicModifierName()
	return "blink_flythor_passive"
end

function blink_flythor:OnSpellStart()
    local caster = self:GetCaster()
    local ability = self
    local fromParticle = "particles/shanxian_leidian_xiaoshi.vpcf"
    local toParticleFail = "particles/shanxian_leidian_chuxian_cd.vpcf"
    local toParticleCorrect = "particles/shanxian_leidian_chuxian_shuaxin.vpcf"
    local toParticle = toParticleFail
    local skillPoint = ability:GetCursorPosition()
    local casterPosition = caster:GetAbsOrigin()
    local direction = (skillPoint - casterPosition):Normalized()
    local distance = (skillPoint - casterPosition):Length2D()
    local max_distance = ability:GetSpecialValueFor("max_distance")
    local newPosition = skillPoint
    if distance > max_distance then
        newPosition = casterPosition + direction * max_distance
    end

    if flythor(caster,ability,newPosition) then
        toParticle = toParticleCorrect
    end
    EmitSoundOn("scene_voice_blink_flythor_cast", caster)
    blinkOperation(caster, ability, fromParticle, toParticle, nil)

end
function flythor(caster,ability,newPosition)

    local flag = false
    
    local casterParticle = "particles/shanxian_leidian_shuaxin_renwu.vpcf"

    local searchAoeRadius = 200
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
        if heroCheckSkill(caster,unit) and caster:GetTeam() == unit:GetTeam() and unit.unit_type == "lei" then
            flag = true
            ability:EndCooldown()
            local particleCaster = ParticleManager:CreateParticle(casterParticle, PATTACH_ABSORIGIN_FOLLOW, caster)
            ParticleManager:SetParticleControl(particleCaster, 0, caster:GetAbsOrigin())
            break
        end
    end
    return flag
end

function blink_flythor_passive:IsHidden()
    return true
end

function blink_flythor_passive:OnCreated()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkFlythorBuff(keys,true)
    end
end

function blink_flythor_passive:OnDestroy()
    if IsServer() then
        local keys = {}
        keys.caster = self:GetParent()
        keys.ability = self:GetAbility()
        refreshBlinkFlythorBuff(keys,false)
    end
end

function refreshBlinkFlythorBuff(keys,flag)
    local caster = keys.caster
    local ability = keys.ability
    local playerID = caster:GetPlayerID()
    local health_percent = ability:GetSpecialValueFor("health_percent") 
    local damage_percent = ability:GetSpecialValueFor("damage_percent")
    local range = ability:GetSpecialValueFor("range")

    setPlayerPower(playerID, "contract_health_percent_final", flag, health_percent)
    setPlayerPower(playerID, "contract_damage_d_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_c_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_b_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_damage_a_percent_final", flag, damage_percent)
    setPlayerPower(playerID, "contract_range", flag, range)

    setPlayerBuffByNameAndBValue(keys,"health",GameRules.playerBaseHealth)
    setPlayerSimpleBuff(keys,"range")

end