local LAM = LibAddonMenu2
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



    table.insert(options,
            {
                type = "dropdown",
                name = "Preferred Cyro Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "pick ya poison",
                choices = {'Greyhost','Blackreach','Ravenswatch'},
                default = "Ravenswatch",
                getFunc = function() return TVS.SV.CyroCamp end,
                setFunc = function(value)
                    TVS.SV.CyroCamp = value
                end,
            })

    table.insert(options,
            {
                type = "dropdown",
                name = "Preferred IC Campaign",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "nocp or cp ic",
                choices = {'NOCP','CP'},
                default = "NOCP",
                getFunc = function() return TVS.SV.ICCamp end,
                setFunc = function(value)
                    TVS.SV.ICCamp = value
                end,
            })

    table.insert(options,
            {
                type = "checkbox",
                name = "Auto leave when telvar limit reached",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Only triggers if you kill something, gain telvar, and the limit exceeds the set amount below. Wont trigger if you withdraw from your bank or something so be careful",
                default = TVS.defaults.AutoQueueOut,
                getFunc = function() return TVS.SV.AutoQueueOut end,
                setFunc = function(value)
                    TVS.SV.AutoQueueOut = value
                end,
            })

    table.insert(options, {
        type = "editbox",
        name = "Telvar limit",
        tooltip = "If you kill a mob and your telvar gained exceeds this int, you will queue out",
        textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
        default = TVS.defaults.TelvarCap,
        getFunc = function() return TVS.SV.TelvarCap end,
        setFunc = function(text)
            TVS.SV.TelvarCap = tonumber(text)
        end,
    })

    table.insert(options,
            {
                type = "checkbox",
                name = "Group queue when queueing ",
                textType = TEXT_TYPE_NUMERIC_UNSIGNED_INT,
                tooltip = "Determines if you group queue if youre the group leader when you hit the keybind or reach your cap",
                default = TVS.defaults.GroupQueue,
                getFunc = function() return TVS.SV.GroupQueue end,
                setFunc = function(value)
                    TVS.SV.GroupQueue = value
                end,
            })

    table.insert(options, {
        type = "description",
        text = "IMPORTANT!!!! Check your controls for the keybind, its unbound by default",

    })

    -- Registering Panel and Options
    local controlPanel = LAM:RegisterAddonPanel(panelName,panelData)
    LAM:RegisterOptionControls(panelName,options)
end
