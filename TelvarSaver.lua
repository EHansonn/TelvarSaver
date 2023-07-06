TVS = {}

TVS.name = "Telvar Saver"
TVS.version = "1.4.2"
TVS.author = "Ehansonn"



TVS.SavedVariablesName = "TVSVars"
TVS.SVVersion = "1.4.2"

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
    ["Evergloam"] = 105
}

TVS.alliances = {
    ['AD'] = 1,
    ['EP'] = 2,
    ['DC'] = 3
}

TVS.defaults = {
    AutoAcceptQueue = false,
    SkipBankDialog = false,
    BackupCamp = "Ravenswatch",
    UseBackup = false,
    AutoLootGold = true,
    AutoLootTelvar = true,
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
    GroupQueue = true,

}

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
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CLOSE_BANK,TVS.CloseBank)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_BANKED_CURRENCY_UPDATE,TVS.UpdateText)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_TELVAR_STONE_UPDATE,TVS.UpdateText)
    --EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CURRENCY_UPDATE,TVS.UpdateText)

    -- Creating keybinds
    ZO_CreateStringId("SI_BINDING_NAME_QUEUETVSCAMP", "Queue into your selected campaign")
    SLASH_COMMANDS["/tvs"] = TVS.queueCamp
    SLASH_COMMANDS["/tvsdb"] = TVS.DebugStuff

    -- Update Bank Scene UI
    TVS.UpdateAnchors()

    -- Auto loot key frags
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_LOOT_UPDATED,TVS.OnLootUpdated)
    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CHATTER_BEGIN,TVS.SkipBank)

end

-- -------------------------------------------------------------------------------
-- Dialog skipper stuff
-- -------------------------------------------------------------------------------


-- Used from lazy writ crafter because I cant figure this crap out because the API documentation is so painful to sift through
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

-- Checking if we looted a key fragment
function TVS.OnLootUpdated()
    if (IsInImperialCity() == false) then return end
    if (TVS.SV.AutoLootGold == true) then LootMoney() end
    if (TVS.SV.AutoLootTelvar == true) then LootCurrency(CURT_TELVAR_STONES) end

    if (TVS.SV.AutoLootKeyFrags == false) then return end

    local num = GetNumLootItems()
    --d("Loot items number : "..num)
    for i = 1, num, 1 do
        local lootId, name, icon, quantity, quality, value, isQuest, isStolen, lootType = GetLootItemInfo(i)
        local link = GetLootItemLink(lootId)
        -- Keyfrag id 64487
        if (GetItemLinkItemId(link) == 64487) then
            TVS.LootItem(link,lootId,quantity)
        end
    end
end
-- Looting the key frag
function TVS.LootItem(link, lootId, quantity)
    LootItemById(lootId)
    --d("Looted ".. tostring(quantity) .. " ".. link)
end



-- -------------------------------------------------------------------------------
-- Bank stuff
-- -------------------------------------------------------------------------------


--  Bank scene to help you manage your telvar. opens menu and auto depos or withdraws if enabled
function TVS.DepositTelvar()

    if (IsInImperialCity() == false) then
        TVS.HideUi()
        return
    end

    --TVSView:SetAlpha(1)
    if (TVS.SV.BankScene == true) then
        TVS.UpdateText()
        TVSView:SetHidden(false)
    end

    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)

    if (currentTelvarOnChar > TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoDepoTelvar == true)then
        local amount = currentTelvarOnChar - TVS.SV.DesiredTelvarAmount
        DepositCurrencyIntoBank(CURT_TELVAR_STONES, amount)
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then d("|c8080ffTelvar Saver|r deposited " .. "|c8080ff" .. tostring(amount).. "|r " .. " into your bank to reach " .. tostring(TVS.SV.DesiredTelvarAmount)) end

        return
    end

    if (currentTelvarOnChar < TVS.SV.DesiredTelvarAmount) and (TVS.SV.AutoWithdrawTelvar == true) then
        local amount = TVS.SV.DesiredTelvarAmount - currentTelvarOnChar
        if (currentTelvarStonesInBank < amount)   then  if ((TVS.SV.notifications== true)) then d("Auto withdraw failed") end return end
        WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount )
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then  d("|c8080ffTelvar Saver|r attempted to withdraw ".. "|c8080ff" .. tostring(amount).. "|r " .. " from your bank to reach " .. tostring(TVS.SV.DesiredTelvarAmount) ) end

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
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then   d("|c8080ffTelvar Saver|r deposited ".. "|c8080ff" .. tostring(amount).. "|r " .. " into your bank to reach " .. tostring(value)) end

        return
    end

    if (currentTelvarOnChar < value) then
        local amount = value - currentTelvarOnChar
        if (currentTelvarStonesInBank < amount) then d("Not enough telvar to withdraw") return end
        WithdrawCurrencyFromBank(CURT_TELVAR_STONES, amount)
        TVS.UpdateText()
        if (TVS.SV.notifications == true) then   d("|c8080ffTelvar Saver|r attempted to withdraw " .. "|c8080ff" .. tostring(amount).. "|r " .. " from your bank to reach " .. tostring(value) ) end

        return
    end
end

function TVS.CloseBank()
    --TVSView:SetAlpha(0)
    TVSView:SetHidden(true)
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
        local playerInBase = TVS.InSafeZone()
        if (playerInBase == true) then return end

        local queueCyro = TVS.CAMPAIGNIDS[TVS.SV.CyroCamp]
        -- d(GetCampaignQueueState(queueCyro))
        if (GetCampaignQueueState(queueCyro) ~= 3) then return else
            if (TVS.SV.notifications == true) then   d("MAX TELVAR REACHED, queued for campaign") end

            local groupQueue = false
            if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
                groupQueue = TVS.SV.GroupQueue
            end
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

    -- GroupQueue Stuff
    local groupQueue = false
    if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
        groupQueue = TVS.SV.GroupQueue
    end


    if (IsInImperialCity() == true)  then
        if (GetCampaignQueueState(queueCyro) ~= 3)  then return else
            QueueForCampaign(queueCyro,groupQueue)
            if (TVS.SV.UseBackup == true) then TVS.QueueControl() end
            TVS.AutoQueueControl()
        end
    else if (IsInCyrodiil() == true)  or (IsInAvAZone() == false) then
        if (GetCampaignQueueState(queueIC) ~= 3)  then return else
            QueueForCampaign(queueIC,groupQueue)
            TVS.AutoQueueControl()
        end
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
            LeaveCampaignQueue(queueCyro)
            QueueForCampaign(newqueueCyro,groupQueue)
            d("Preferred campaign has a queue, queued for backup")
        end

        -- We dont care about these any more
        EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_LEFT)
    end

end

function TVS.AutoQueueControl()
    if (TVS.SV.AutoAcceptQueue == false) then
        EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
        return
    end

    EVENT_MANAGER:RegisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED,TVS.AutoAccept)
end


function TVS.AutoAccept(eventCode, id, isGroup, state)
    local groupQueue = false
    if (IsUnitGrouped('player') == true) and (IsUnitGroupLeader("player") == true) then
        groupQueue = TVS.SV.GroupQueue
    end

    if (state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING) then
        d("Entering campaign...")
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
        if (px >= zone.lowx) and (py >= zone.lowy) and (px <= zone.highx) and (py <= zone.highy)  then
            --d("Telvar Cap reached but player in base")
            return true
        end
    end
    return false

end

function TVS.DebugStuff()
    local zoneId, px, pz, py = GetUnitRawWorldPosition("player")
    d(zoneId)
    d("x: " ..px)
    d("y: " ..py)
    d("in base: " .. tostring(TVS.InSafeZone()))

end
-- Entry Point
EVENT_MANAGER:RegisterForEvent(TVS.name,EVENT_ADD_ON_LOADED,TVS.onLoad)
