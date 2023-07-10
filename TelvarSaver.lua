TVS = {}

TVS.name = "Telvar Saver"
TVS.version = "1.4.4"
TVS.author = "Ehansonn"

TVS.SavedVariablesName = "TVSVars"
TVS.SVVersion = "1.4.4"

TVS.CAMPAIGNIDS = {
    ["Ravenswatch"] = 103,
    ["Greyhost"] = 102,
    ["Blackreach"] = 101,
    ["NOCP"] = 96,
    ["CP"] = 95,
    ["Legion Zero"] = 116, -- nocp ic
    ["Dragonfire"] = 119, -- cp ic
    ["Quagmire"] = 111,
    ["Fields of regret"] = 112,
    ["Ashpit"] = 106,
    ["Evergloam"] = 105,
    ["Last visited"] = 95,
}

TVS.defaults = {
    CloseLootWindow = true,
    AutoKickOffline = true,
    midyear = false,
    LastICCamp = 95,
    AutoAcceptQueue = false,
    SkipBankDialog = false,
    BackupCamp = "Ravenswatch",
    UseBackup = false,
    AutoLootGold = false,
    AutoLootTelvar = false,
    AutoLootKeyFrags = true,
    notifications = true,
    dragable = true,
    locationx = 275,
    locationy = 150,
    BankScene = true,
    AutoDepoTelvar = false,
    AutoWithdrawTelvar = false,
    DesiredTelvarAmount = 0,
    ICCamp = "CP",
    CyroCamp = "Ravenswatch",
    AutoQueueOut = true,
    TelvarCap = 50000,
    GroupQueue = false,
}

-- Telvar Icon
TVS.TELVAR_CHAT_ICON = (zo_iconTextFormat("EsoUI/Art/currency/currency_telvar_32.dds",18,18))

TVS.SV = {}

function TVS.onLoad(eventCode, addonName)
    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_ADD_ON_LOADED)
    TVS.SV = ZO_SavedVars:NewAccountWide(TVS.SavedVariablesName, TVS.SVVersion, nil, TVS.defaults)

    -- Creating LAM2 Settings
    TVS.CreateSettingsMenu()


    -- Creating auto queue listener
    EVENT_MANAGER:RegisterForEvent(TVS.name,EVENT_CURRENCY_UPDATE, TVS.AutoQueue)

    -- Bank Scene
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_OPEN_BANK,TVS.DepositTelvar)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CLOSE_BANK,TVS.HideUi)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_BANKED_CURRENCY_UPDATE,TVS.UpdateText)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_TELVAR_STONE_UPDATE,TVS.UpdateText)

    -- Creating keybinds
    ZO_CreateStringId("SI_BINDING_NAME_QUEUETVSCAMP", "Queue into your selected campaign")
    SLASH_COMMANDS["/tvs"] = TVS.queueCamp
    SLASH_COMMANDS["/tvsdb"] = TVS.DebugStuff

    -- Update Bank Scene UI
    TVS.UpdateAnchors()
    TVS.UpdateText()

    -- Auto loot key frags
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_LOOT_UPDATED,TVS.OnLootUpdated)

    -- Bank chatter dialog skip
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CHATTER_BEGIN,TVS.SkipBank)


    TVS.UpdateLastLocation()
    --Setting the last IC camp the player visited
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_PLAYER_ACTIVATED,TVS.UpdateLastLocation)
    end

-- -------------------------------------------------------------------------------
-- Dialog skipper stuff
-- -------------------------------------------------------------------------------

-- Used from lazy writ crafter
function TVS.SkipBank()
    if (IsInImperialCity() == false) or (TVS.SV.SkipBankDialog == false) then return end

    if GetInteractionType()~=INTERACTION_BANK and GetInteractionType() == INTERACTION_CONVERSATION then
        for i= 1, GetChatterOptionCount() do
            local _, optiontype = GetChatterOption(i)
            if optiontype == CHATTER_START_BANK then
                SelectChatterOption(i)
            end
        end
    end
end


-- -------------------------------------------------------------------------------
-- Autoloot stuff
-- -------------------------------------------------------------------------------

-- Checking if we looted a key fragment. Thanks smarter auto loot
function TVS.OnLootUpdated()
    local name, interactType, actionName, owned = GetLootTargetInfo()
    if (IsInImperialCity() == false) then return end
    if (TVS.SV.AutoLootGold == true) then LootMoney() end
    if (TVS.SV.AutoLootTelvar == true) then
        if (name == "Chest") then  LootCurrency(CURT_TELVAR_STONES) end
        if (name == "Medium Tel Var Sack") or (name == "Hefty Tel Var Crate") or (name == "Light Tel Var Satchel") then
            LootCurrency(CURT_TELVAR_STONES)
            zo_callLater(function()
                if (GetNumLootItems() ~= 0) then return end
                local currentScene = SCENE_MANAGER:GetCurrentScene().name
                SCENE_MANAGER:Toggle(currentScene)
                if (tostring(currentScene) == "inventory") then
                    SCENE_MANAGER:Show("inventory")
                end
            end,100)
        end
    end
    if (TVS.SV.AutoLootKeyFrags == true) then
        local num = GetNumLootItems()
        for i = 1, num, 1 do
            local lootId, name, icon, quantity, quality, value, isQuest, isStolen, lootType = GetLootItemInfo(i)
            local link = GetLootItemLink(lootId)
            -- Keyfrag id 64487
            if (GetItemLinkItemId(link) == 64487) then
                TVS.LootItem(link,lootId,quantity)
            end
        end
    end
end
-- Looting the key frag
function TVS.LootItem(link, lootId, quantity)
    LootItemById(lootId)
end



-- -------------------------------------------------------------------------------
-- Bank stuff
-- -------------------------------------------------------------------------------

--  Bank scene to help you manage your telvar. opens menu and auto depos or withdraws if enabled
function TVS.DepositTelvar()
    if (IsInImperialCity() == false) then TVS.HideUi() return end
    if (TVS.SV.BankScene == true) then TVS.ShowUi() end

    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

    if (currentTelvarOnChar > TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoDepoTelvar == true)then
        local amount = currentTelvarOnChar - TVS.SV.DesiredTelvarAmount
        DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
        TVS.dtvs("auto deposited " .. "|c8080ff" .. tostring(amount).. "|r " .. TVS.TELVAR_CHAT_ICON)
        return
    end

    if (currentTelvarOnChar < TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoWithdrawTelvar == true) then
        local amount = TVS.SV.DesiredTelvarAmount - currentTelvarOnChar
        if (currentTelvarStonesInBank < amount)  then TVS.dtvs("Auto withdraw failed") return end
        WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount )
        TVS.dtvs("auto withdrew " .. "|c8080ff" .. tostring(amount).. "|r " .. TVS.TELVAR_CHAT_ICON)
        return
    end
end

-- Buttons in bank scene, withdraws or depos when clicked
function TVS.TelvarButton(value)
    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

    if (currentTelvarOnChar > value) then
        local amount = currentTelvarOnChar - value
        DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
        TVS.dtvs("deposited " .. "|c8080ff" .. tostring(amount).. "|r " .. TVS.TELVAR_CHAT_ICON)
        return
    end

    if (currentTelvarOnChar < value) then
        local amount = value - currentTelvarOnChar

        if (currentTelvarStonesInBank < amount) then TVS.dtvs("Not enough telvar to withdraw") return end
        WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount)
        TVS.UpdateText()
        TVS.dtvs("withdrew " .. "|c8080ff" .. tostring(amount).. "|r " .. TVS.TELVAR_CHAT_ICON )
        return
    end
end

-- -------------------------------------------------------------------------------
-- Queue stuff
-- -------------------------------------------------------------------------------

-- For when you gain telvar and exceed your cap
function TVS.AutoQueue(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
    if (TVS.SV.AutoQueueOut == false) then return end
    if not IsInImperialCity() then return end
    if currencyType ~= CURT_TELVAR_STONES then return end
    if currencyLocation ~= CURRENCY_LOCATION_CHARACTER then return end
    if reason ~= CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER and reason ~= CURRENCY_CHANGE_REASON_LOOT then return end

    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    if (currentTelvarOnChar >= TVS.SV.TelvarCap) then
        if (TVS.InSafeZone() == true) then return end
        local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]
        if (GetCampaignQueueState(queueCyro) ~= 3) then return else
            TVS.dtvs("MAX TELVAR REACHED, queued for campaign [" .. TVS.SV.CyroCamp .. "]")
            TVS.UpdateLastLocation()
            local groupQueue = TVS.GetGroupQueue()
            if (groupQueue) then if (TVS.AutoKickOfflinePlayers(queueCyro) ~= 0) then return end end

            QueueForCampaign(queueCyro,groupQueue)
            if (TVS.SV.UseBackup == true) then TVS.QueueControl() end
            TVS.AutoQueueControl()
        end
    end
end

-- For the keybind button press
function TVS.queueCamp()
    local queueIC = TVS.CAMPAIGNIDS[TVS.SV.ICCamp]
    local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]
    if (TVS.SV.ICCamp == "Last visited") then queueIC = TVS.SV.LastICCamp end

    local groupQueue = TVS.GetGroupQueue()



    if (IsInImperialCity() == true)  then
        if (GetCampaignQueueState(queueCyro) ~= 3)  then return else
            if (groupQueue) then if (TVS.AutoKickOfflinePlayers(queueCyro) ~= 0) then return end end

            TVS.dtvs("Queued for cyro campaign [" .. TVS.SV.CyroCamp .. "]")

            TVS.UpdateLastLocation()

            QueueForCampaign(queueCyro,groupQueue)
            if (TVS.SV.UseBackup == true) then TVS.QueueControl() end
            TVS.AutoQueueControl()
        end
    elseif (IsInCyrodiil() == true)  or (IsInAvAZone() == false) then
        if (GetCampaignQueueState(queueIC) ~= 3)  then return else
            if (groupQueue) then if (TVS.AutoKickOfflinePlayers(queueIC) ~= 0) then return end end

            TVS.dtvs("Queued for IC campaign [" .. TVS.SV.ICCamp .. "]")

            QueueForCampaign(queueIC,groupQueue)
            TVS.AutoQueueControl()
        end
    end
end
-- Checking to see if the preferred camp has a queue
function TVS.QueueControl()
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED,TVS.CheckQueue)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_LEFT,TVS.QueueExit)
end
-- We left the queue
function TVS.QueueExit()
    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_LEFT)
end
-- Queueing for backup incase of queue
function TVS.CheckQueue()
    local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]

    if (GetCampaignQueuePosition(queueCyro) > 0) then
        local newqueueCyro = TVS.CAMPAIGNIDS[TVS.SV.BackupCamp]
        if (newqueueCyro ~= queueCyro) then
            local groupQueue = TVS.GetGroupQueue()
            LeaveCampaignQueue(queueCyro)
            QueueForCampaign(newqueueCyro,groupQueue)
            TVS.dtvs("Preferred campaign has a queue, queued for backup [" .. TVS.SV.BackupCamp .. "]")
        end

        -- We dont care about these any more
        EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_LEFT)
    end
end

-- Auto queue stuff
function TVS.AutoQueueControl()
    if (TVS.SV.AutoAcceptQueue == false) then
        EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
        return
    end
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED,TVS.AutoAccept)
end


function TVS.AutoAccept(eventCode, id, isGroup, state)
    local groupQueue = TVS.GetGroupQueue()

    if (state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING) then
        TVS.dtvs("Entering campaign")
        ConfirmCampaignEntry(id, groupQueue, true)
    end
end

-- a bunch of squares that accurately contains the IC safe zones
-- x increases to the right on the map
-- y increases going down on the map
TVS.SafeZones = {
    [1] = {lowx = 263010, lowy=177811, highx=277158, highy=183151}, --right side of AD base
    [2] = {lowx = 259061, lowy=173749, highx=263010, highy=183151}, -- left side of AD base
    [3] = {lowx = 162000, lowy=17400, highx=181900, highy=25000}, -- top of EP
    [4] = {lowx = 179500 , lowy=25000, highx=181900, highy= 29500}, -- bottom of EP
    [5] = {lowx = 1400 , lowy=155800, highx=5420, highy= 171000}, -- middle of DC
    [6] = {lowx = 1400 , lowy=168700, highx=11000, highy=172000 }, -- bottom of DC
    [7] = {lowx = 1400 , lowy=153580, highx=6700, highy=159320 }, -- top of DC
}

-- Checking if the player is currently within any of the safe zones since midyear boxes give the CURRENCY_CHANGE_REASON_LOOT code
function TVS.InSafeZone()
    local zoneId, px, pz, py = GetUnitRawWorldPosition("player")
    if (zoneId ~= 643) then return false end
    for i,zone in ipairs(TVS.SafeZones) do
        if (px >= zone.lowx) and (py >= zone.lowy) and (px <= zone.highx) and (py <= zone.highy)  then return true end
    end
    return false

end

-- Checking if we should group queue or not
function TVS.GetGroupQueue()
    local groupQueue = false
    if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then groupQueue = TVS.SV.GroupQueue end
    return groupQueue
end

-- If the player is in a group, is group leader, and has an offline member in the group,
-- Kick them and then queue again after x ms
function TVS.AutoKickOfflinePlayers(campaignID)
    if (TVS.SV.AutoKickOffline == false) or (TVS.GetGroupQueue() == false) then return 0 end
    local size = GetGroupSize()
    local count = 0
    if size < 1 then return count end

    for player = 1, size do
        if not (IsUnitOnline(GetGroupUnitTagByIndex(player))) then
            GroupKick(GetGroupUnitTagByIndex(player))
            count = count + 1
            TVS.dtvs("Kicking " .. GetUnitName(GetGroupUnitTagByIndex(player)))
        end
    end

    if (count > 0) then
        zo_callLater(function()
            local newGroupQueue = TVS.GetGroupQueue()
            QueueForCampaign(campaignID,newGroupQueue)
            if (TVS.SV.UseBackup == true) then TVS.QueueControl() end
            TVS.AutoQueueControl()
            TVS.dtvs("Removed offline players and queued for campaign")
        end,200)
    end
    return count
end

-- -------------------------------------------------------------------------------
-- misc stuff
-- -------------------------------------------------------------------------------

function TVS.UpdateLastLocation()
    if (IsInImperialCity() == false) then return end

    TVS.SV.LastICCamp = GetCurrentCampaignId()
end


function TVS.dtvs(value)
    if (TVS.SV.notifications == false) then return end
    if (value == nil) then return end

    d("|c8080ffTel Var Saver:|r " .. value)
end

function TVS.DebugStuff()
    local currentScene = SCENE_MANAGER:GetCurrentScene().name
    SCENE_MANAGER:Toggle(currentScene)
end

-- Entry Point
EVENT_MANAGER:RegisterForEvent(TVS.name,EVENT_ADD_ON_LOADED,TVS.onLoad)
