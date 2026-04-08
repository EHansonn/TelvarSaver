local LAM = LibAddonMenu2
TelVarSaver = TelVarSaver or {}
local TVS = TelVarSaver
-- Creating LAM2 MENU --
function TVS.CreateSettingsMenu()
	local panelName = "Telvar Saver"
	local panelData = {
		type = "panel",
		name = TVS.name,
		displayName = panelName,
		author = TVS.author,
		version = TVS.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local options = {}

	table.insert(options, {
		type = "description",
		text = "Check your controls for the keybind, its unbound by default",
	})
	table.insert(options, {
		type = "checkbox",
		name = "Chat Notifications",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "",
		default = TVS.defaults.notifications,
		getFunc = function() return TVS.SV.notifications end,
		setFunc = function(value) TVS.SV.notifications = value end,
	})
	table.insert(options, {
		type = "checkbox",
		name = "Disable keybind in PVE",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Prevents accidental queueing if you accidentally hit the key in a PVE zone",
		default = TVS.defaults.DisableKeybindInPVE,
		getFunc = function() return TVS.SV.DisableKeybindInPVE end,
		setFunc = function(value) TVS.SV.DisableKeybindInPVE = value end,
	})
	table.insert(options, {
		type = "header",
		name = "Campaign Options",
	})
	local function GetDynamicCampaignChoices(requireIC)
		local names = {}
		local values = {}

		local n = GetNumSelectionCampaigns()
		for i = 1, n do
			local id = GetSelectionCampaignId(i)
			if (type(id) == "number") and (IsImperialCityCampaign(id) == requireIC) then
				if DoesPlayerMeetCampaignRequirements(id) == true then
					table.insert(names, GetCampaignName(id))
					table.insert(values, id)
				end
			end
		end

		return names, values
	end

	local cyroChoices, cyroChoiceValues = GetDynamicCampaignChoices(false)
	local icChoices, icChoiceValues = GetDynamicCampaignChoices(true)
	local function GetAlternativeICCampaignId(excludedId, fallbackId)
		for _, id in ipairs(icChoiceValues) do
			if id ~= excludedId then return id end
		end
		if fallbackId ~= excludedId then return fallbackId end
		return nil
	end

	table.insert(options, {
		type = "dropdown",
		name = "Home Campaign",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Your primary IC campaign. If your current campaign is not home, TelvarSaver will queue this one first.",
		choices = icChoices,
		choicesValues = icChoiceValues,
		default = TVS.defaults.ICCamp,
		getFunc = function() return TVS.GetHomeCampaignId() end,
		setFunc = function(value)
			TVS.SV.ICCamp = value
			if TVS.SV.ICCamp == TVS.SV.EscapeCamp then
				local newEscape = GetAlternativeICCampaignId(TVS.SV.ICCamp, TVS.defaults.EscapeCamp)
				if newEscape ~= nil then
					TVS.SV.EscapeCamp = newEscape
					LAM.util.ShowConfirmationDialog(
						"Campaigns must be different",
						"Home Campaign cannot match Escape Campaign. Escape was changed automatically.",
						function() end
					)
				else
					LAM.util.ShowConfirmationDialog(
						"No alternate IC campaign",
						"Only one eligible IC campaign is available right now, so Home/Escape cannot be separated.",
						function() end
					)
				end
			end
		end,
	})

	table.insert(options, {
		type = "dropdown",
		name = "Escape Campaign",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Used when you are already in Home Campaign and Smart IC queue picker is disabled.",
		choices = icChoices,
		choicesValues = icChoiceValues,
		default = TVS.defaults.EscapeCamp,
		getFunc = function() return TVS.GetEscapeICCampaignId() end,
		setFunc = function(value)
			TVS.SV.EscapeCamp = value
			if TVS.SV.EscapeCamp == TVS.SV.ICCamp then
				local newHome = GetAlternativeICCampaignId(TVS.SV.EscapeCamp, TVS.defaults.ICCamp)
				if newHome ~= nil then
					TVS.SV.ICCamp = newHome
					LAM.util.ShowConfirmationDialog(
						"Campaigns must be different",
						"Escape Campaign cannot match Home Campaign. Home was changed automatically.",
						function() end
					)
				else
					LAM.util.ShowConfirmationDialog(
						"No alternate IC campaign",
						"Only one eligible IC campaign is available right now, so Home/Escape cannot be separated.",
						function() end
					)
				end
			end
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Smart IC queue picker",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "When leaving Imperial City, dynamically pick the best campaign using the live campaign list (eligibility, Tel Var restriction, and lowest queue wait time).",
		default = TVS.defaults.SmartQueuePicker,
		getFunc = function() return TVS.SV.SmartQueuePicker end,
		setFunc = function(value) TVS.SV.SmartQueuePicker = value end,
	})
	table.insert(options, {
		type = "checkbox",
		name = "Allow Cyrodiil campaigns (Smart Queue)",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "If off, Smart Queue will only consider Imperial City campaigns. If on, it may pick Cyrodiil campaigns too (based on lowest queue wait time), as long as your current Tel Var amount does not prevent queuing for that campaign.",
		default = TVS.defaults.AllowCyrodiilCampaigns,
		getFunc = function() return TVS.SV.AllowCyrodiilCampaigns end,
		setFunc = function(value) TVS.SV.AllowCyrodiilCampaigns = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto accept queue",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Do you want the queue to auto accept? Unneeded if you already have kill counter's auto accept enabled.",
		default = TVS.defaults.AutoAcceptQueue,
		getFunc = function() return TVS.SV.AutoAcceptQueue end,
		setFunc = function(value)
			EVENT_MANAGER:UnregisterForEvent(TVS.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
			TVS.SV.AutoAcceptQueue = value
		end,
	})
	table.insert(options, {
		type = "description",
		text = "Backup campaign queueing has been removed (Smart IC queue picker supersedes it).",
	})

	table.insert(options, {
		type = "description",
		text = "Midyear mayhem setting has been removed. Campaign lists are now dynamic and update based on what's currently available.",
	})

	table.insert(options, {
		type = "header",
		name = "Time/Life Savers",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto leave when telvar limit reached",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Only triggers if you gain telvar, and the limit exceeds the set amount below. Wont trigger if you withdraw from your bank or something so be careful",
		default = TVS.defaults.AutoQueueOut,
		getFunc = function() return TVS.SV.AutoQueueOut end,
		setFunc = function(value) TVS.SV.AutoQueueOut = value end,
	})

	table.insert(options, {
		type = "editbox",
		name = "Telvar limit",
		tooltip = "If you kill a mob or player and your telvar gained exceeds this int, you will queue out",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		default = TVS.defaults.TelvarCap,
		getFunc = function() return TVS.SV.TelvarCap end,
		setFunc = function(text)
			local value = tonumber(text)
			if value <= 0 then value = 1 end
			TVS.SV.TelvarCap = value
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Group queue ",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if you group queue if youre the group leader when you hit the keybind or reach your cap",
		default = TVS.defaults.GroupQueue,
		getFunc = function() return TVS.SV.GroupQueue end,
		setFunc = function(value) TVS.SV.GroupQueue = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto kick offline (IMPORTANT) ",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "To group queue you need to have no offline members in your group. By having this disabled, you will not be able to queue if you have an offline person in your group",
		default = TVS.defaults.AutoKickOffline,
		getFunc = function() return TVS.SV.AutoKickOffline end,
		setFunc = function(value) TVS.SV.AutoKickOffline = value end,
	})
	table.insert(options, {
		type = "checkbox",
		name = "Auto loot imperial fragments",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the addon will auto loot imperial fragments when opening a loot menu",
		default = TVS.defaults.AutoLootKeyFrags,
		getFunc = function() return TVS.SV.AutoLootKeyFrags end,
		setFunc = function(value) TVS.SV.AutoLootKeyFrags = value end,
	})
	table.insert(options, {
		type = "checkbox",
		name = "Auto loot gold in IC",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the addon will auto loot gold when opening a loot menu",
		default = TVS.defaults.AutoLootGold,
		getFunc = function() return TVS.SV.AutoLootGold end,
		setFunc = function(value) TVS.SV.AutoLootGold = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto loot telvar (containers and chests) in IC",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the addon will auto loot telvar when opening a loot menu",
		default = TVS.defaults.AutoLootTelvar,
		getFunc = function() return TVS.SV.AutoLootTelvar end,
		setFunc = function(value) TVS.SV.AutoLootTelvar = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Skip bank dialog in IC",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Will skip the bank dialog if youre in IC.",
		default = TVS.defaults.SkipBankDialog,
		getFunc = function() return TVS.SV.SkipBankDialog end,
		setFunc = function(value) TVS.SV.SkipBankDialog = value end,
	})

	table.insert(options, {
		type = "header",
		name = "Auto Deposits and Withdraw from bank",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto deposit telvar into bank",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "If your current carried telvar exceeds your desired amount, deposit the excess",
		default = TVS.defaults.AutoDepoTelvar,
		getFunc = function() return TVS.SV.AutoDepoTelvar end,
		setFunc = function(value) TVS.SV.AutoDepoTelvar = value end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Auto withdraw telvar from bank",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "If your current carried telvar is below your desired amount, withdraw the amount to reach it",
		default = TVS.defaults.AutoWithdrawTelvar,
		getFunc = function() return TVS.SV.AutoWithdrawTelvar end,
		setFunc = function(value) TVS.SV.AutoWithdrawTelvar = value end,
	})

	table.insert(options, {
		type = "editbox",
		name = "Desired carried Telvar ",
		tooltip = "The amount you want to carry (for auto depos and withdraws)",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		default = TVS.defaults.DesiredTelvarAmount,
		getFunc = function() return TVS.SV.DesiredTelvarAmount end,
		setFunc = function(text)
			local amount = tonumber(text)
			-- If you really really really want to take out more than 10k for some reason with this addon, remove the if statement at your own risk
			if (amount < 0) or (amount > 10000) then
				amount = 0
				d("Invalid amount. Must be between 0 and 10000")
			end
			TVS.SV.DesiredTelvarAmount = amount
		end,
	})

	table.insert(options, {
		type = "header",
		name = "Bank Menu",
	})

	table.insert(options, {
		type = "checkbox",
		name = "Bank Scene",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "Determines if the bank scene shows up or not",
		default = TVS.defaults.BankScene,
		getFunc = function() return TVS.SV.BankScene end,
		setFunc = function(value)
			if value == false then TVS.CloseBank() end
			TVS.SV.BankScene = value
		end,
	})

	table.insert(options, {
		type = "checkbox",
		name = "Dragable",
		textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
		tooltip = "",
		default = TVS.defaults.dragable,
		getFunc = function() return TVS.SV.dragable end,
		setFunc = function(value)
			TVS.SV.dragable = value
			TVS.UpdateAnchors()
		end,
	})

	table.insert(options, {
		type = "button",
		name = "reset position to defaults",
		func = function()
			TVS.SV.locationy = TVS.defaults.locationy
			TVS.SV.locationx = TVS.defaults.locationx
			TVS.UpdateAnchors()
		end,
	})

	table.insert(options, {
		type = "button",
		name = "reset ALL SETTINGS",
		func = function()
			LAM.util.ShowConfirmationDialog("Reset all settings to defaults?", "Requires a UI reload", function()
				zo_callLater(function()
					-- lol
					TVS.SV.locationy = TVS.defaults.locationy
					TVS.SV.locationx = TVS.defaults.locationx
					TVS.UpdateAnchors()

					TVS.SV.AutoKickOffline = TVS.defaults.AutoKickOffline
					TVS.SV.LastICCamp = TVS.defaults.LastICCamp
					TVS.SV.AutoAcceptQueue = TVS.defaults.AutoAcceptQueue
					TVS.SV.SkipBankDialog = TVS.defaults.SkipBankDialog
					TVS.SV.AutoLootGold = TVS.defaults.AutoLootGold
					TVS.SV.AutoLootTelvar = TVS.defaults.AutoLootTelvar
					TVS.SV.AutoLootKeyFrags = TVS.defaults.AutoLootKeyFrags
					TVS.SV.notifications = TVS.defaults.notifications
					TVS.SV.dragable = TVS.defaults.dragable
					TVS.SV.locationx = TVS.defaults.locationx
					TVS.SV.locationy = TVS.defaults.locationy
					TVS.SV.BankScene = TVS.defaults.BankScene
					TVS.SV.AutoDepoTelvar = TVS.defaults.AutoDepoTelvar
					TVS.SV.AutoWithdrawTelvar = TVS.defaults.AutoWithdrawTelvar
					TVS.SV.DesiredTelvarAmount = TVS.defaults.DesiredTelvarAmount
					TVS.SV.ICCamp = TVS.defaults.ICCamp
					TVS.SV.EscapeCamp = TVS.defaults.EscapeCamp
					TVS.SV.AutoQueueOut = TVS.defaults.AutoQueueOut
					TVS.SV.TelvarCap = TVS.defaults.TelvarCap
					TVS.SV.GroupQueue = TVS.defaults.GroupQueue
					TVS.SV.DisableKeybindInPVE = TVS.defaults.DisableKeybindInPVE
					ReloadUI()
				end, 100)
			end)
		end,
	})

	-- Registering Panel and Options
	local controlPanel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, options)
end
