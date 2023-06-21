TVS = {}

TVS.name = "Telvar Saver"
TVS.version = "1.0"
TVS.author = "Ehansonn"

TVS.SavedVariablesName = "TVSVars"
TVS.SVVersion = "1.0"
TVS.BackupCamp = "Blackreach"
TVS.CAMPAIGNIDS = {
    ["Ravenswatch"] = 103,
    ["Greyhost"] = 102,
    ["Blackreach"] = 101,
    ["NOCP"] = 96,
    ["CP"] = 95
}

TVS.defaults = {
    ICCAMP = "NOCP",
    CyroCamp = "Ravenswatch",
    AutoQueueOut = true,
    TelvarCap = 50000,
    GroupQueue = true,

}

TVS.SV = {}
TVS.inAva  =nil

function TVS.onLoad(eventCode, addonName)
    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_ADD_ON_LOADED)
    TVS.SV = ZO_SavedVars:NewAccountWide(TVS.SavedVariablesName, TVS.SVVersion, nil, TVS.defaults)


    TVS.CreateSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_COMBAT_EVENT, TVS.CombatEvent)


    ZO_CreateStringId("SI_BINDING_NAME_QUEUEEGTCAMP", "Queue into ravenwatch")
    SLASH_COMMANDS["/TVS"] = TVS.queueCamp
end

function TVS.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,sourceUnitId, targetUnitId, abilityId)
    TVS.AutoQueue(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,sourceUnitId, targetUnitId, abilityId)
end

function TVS.AutoQueue(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,sourceUnitId, targetUnitId, abilityId)
    -- Triggers when you kill something 
    if result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP then
        if ((TVS.SV.AutoQueue == false) or (IsInImperialCity() == false)) then
            return
        else
            local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
            if (currentTelvarOnChar >= TVS.SV.TelvarCap) then
                local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]
                -- d(GetCampaignQueueState(queueCyro))
                if (GetCampaignQueueState(queueCyro) ~= 3) then return else
                    d("MAX TELVAR REACHED, queued for campaign")
                    local groupQueue = false
                    if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
                        groupQueue = TVS.SV.GroupQueue
                    end
                    QueueForCampaign(queueCyro,GroupQueue)
                end
            end
        end
    end
end


function TVS.queueCamp()

    local queueIC = TVS.CAMPAIGNIDS[TVS.SV.ICCamp]
    local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]

    -- Backup incase GH or BR has a queue
    if (GetCampaignQueuePosition(queueCyro) > 0) then
        queueCyro = TVS.CAMPAIGNIDS["Ravenswatch"]
    end

    -- GroupQueue Stuff
    local groupQueue = false
    if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
        groupQueue = TVS.SV.GroupQueue
    end

  
    if (IsInImperialCity() == true)  then
        if (GetCampaignQueueState(queueCyro) ~= 3)  then return else
            QueueForCampaign(queueCyro,groupQueue)
        end
    else if (IsInCyrodiil() == true)  or (IsInAvAZone() == false) then
        if (GetCampaignQueueState(queueIC) ~= 3)  then return else
            QueueForCampaign(queueIC,groupQueue)
        end
    end
    end
end

-- Entry Point
EVENT_MANAGER:RegisterForEvent(TVS.name,EVENT_ADD_ON_LOADED,TVS.onLoad)
