function TVS.HideUi()
    TVSView:SetHidden(true)
end

function TVS.ShowUi()
    TVS.UpdateText()
    TVSView:SetHidden(false)
end

function TVS.SetHidden()
    TVS.HideUi()
    TVS.SV.BankScene = false
end

function TVS.UpdateText()
    local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
    local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
    TVSViewCurrentTextValue:SetText(TVS.TELVAR_CHAT_ICON ..": |c8080ff" .. tostring(currentTelvarOnChar) .."|r"  )
    TVSViewBankTextValue:SetText(TVS.TELVAR_CHAT_ICON ..": |c8080ff" .. tostring(currentTelvarStonesInBank) .."|r" )
    TVSViewButtonDepo1k:SetAlpha(1)
    TVSViewButtonDepo10k:SetAlpha(1)
    -- Checking if the player has enough telvar to actually use the buttons.
    if (currentTelvarStonesInBank < 10000) and (currentTelvarOnChar -currentTelvarOnChar < 10000) and (currentTelvarOnChar < 10000) then TVSViewButtonDepo10k:SetAlpha(.5) end
    if (currentTelvarStonesInBank < 1000) and (currentTelvarOnChar -currentTelvarOnChar < 1000) and (currentTelvarOnChar < 1000) then TVSViewButtonDepo1k:SetAlpha(.5) end

end

function TVS.SaveLocation()
    TVS.SV.locationx = TVSView:GetLeft()
    TVS.SV.locationy = TVSView:GetTop()
end

function TVS.UpdateAnchors()
    TVSView:ClearAnchors()
    TVSView:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,TVS.SV.locationx,TVS.SV.locationy)
    TVSView:SetMovable(TVS.SV.dragable)
end

function TVS.UpdateUi()
    TVS.UpdateAnchors()
end