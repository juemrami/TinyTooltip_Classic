
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local DEAD = DEAD
local CopyTable = CopyTable

local addon = TinyTooltip

BigTipDB = {}
TinyTooltipCharacterDB = {}

local function ColorStatusBar(self, value)
    if (addon.db.general.statusbarColor == "auto") then
        local unit = "mouseover"
        local focus = GetMouseFocus()
        if (focus and focus.unit) then
            unit = focus.unit
        end
        local r, g, b
        if (UnitIsPlayer(unit)) then
            r, g, b = GetClassColor(select(2,UnitClass(unit)))
        else
            r, g, b = GameTooltip_UnitColor(unit)
            if (g == 0.6) then g = 0.9 end
            if (r==1 and g==1 and b==1) then r, g, b = 0, 0.9, 0.1 end
        end
        self:SetStatusBarColor(r, g, b)
    elseif (value and addon.db.general.statusbarColor == "smooth") then
        HealthBar_OnValueChanged(self, value, true)
    end
end

---@type Button
---@diagnostic disable-next-line: undefined-global
local ItemRefCloseButton = ItemRefCloseButton
LibEvent:attachEvent("VARIABLES_LOADED", function()
    --CloseButton
    if ItemRefCloseButton 
        and not C_AddOns.IsAddOnLoaded("ElvUI")
    then
				ItemRefCloseButton:SetSize(14, 14)
				ItemRefCloseButton:SetPoint("TOPRIGHT", -4, -4)
				ItemRefCloseButton:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
				ItemRefCloseButton:SetPushedTexture("Interface\\Buttons\\UI-StopButton")
				local tex = ItemRefCloseButton:GetNormalTexture()
				if tex then tex:SetVertexColor(0.9, 0.6, 0) end
    end
    --StatusBar
    local statusBar = GameTooltipStatusBar
    statusBar.bg = statusBar:CreateTexture(nil, "BACKGROUND")
    statusBar.bg:SetAllPoints()
    statusBar.bg:SetColorTexture(1, 1, 1)
    statusBar.bg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    statusBar.TextString = statusBar:CreateFontString(nil, "OVERLAY")
    statusBar.TextString:SetPoint("CENTER")
    statusBar.TextString:SetFont(NumberFontNormal:GetFont(), 11, "THINOUTLINE")
    statusBar.capNumericDisplay = true
    statusBar.lockShow = 1
    statusBar:HookScript("OnShow", function(self)
        ColorStatusBar(self)
    end)
    statusBar:HookScript("OnValueChanged", function(self, hp)
        if (hp <= 0) then
            local min, max = self:GetMinMaxValues()
            self.TextString:SetFormattedText("|cff999999%s|r |cffffcc33<%s>|r", AbbreviateLargeNumbers(max), DEAD)
        else
            TextStatusBar_UpdateTextString(self)
        end
        ColorStatusBar(self, hp)
    end)
    statusBar:HookScript("OnShow", function(self)
        if (addon.db.general.statusbarHeight == 0) then
            self:Hide()
        end
    end)
    --Variable
    addon.db = addon:MergeVariable(addon.db, BigTipDB)
    if (addon.db.general.SavedVariablesPerCharacter) then
        local db = CopyTable(addon.db)
        addon.db = addon:MergeVariable(db, TinyTooltipCharacterDB)
    end
    LibEvent:trigger("tooltip:variables:loaded")
    --Init
    LibEvent:trigger("TINYTOOLTIP_GENERAL_INIT")
    --ShadowText
    GameTooltipHeaderText:SetShadowOffset(1, -1)
    GameTooltipHeaderText:SetShadowColor(0, 0, 0, 0.9)
    GameTooltipText:SetShadowOffset(1, -1)
    GameTooltipText:SetShadowColor(0, 0, 0, 0.9)
    Tooltip_Small:SetShadowOffset(1, -1)
    Tooltip_Small:SetShadowColor(0, 0, 0, 0.9)
end)

LibEvent:attachTrigger("tooltip:cleared, tooltip:hide", function(self, tip)
    LibEvent:trigger("tooltip.style.border.color", tip, unpack(addon.db.general.borderColor))
    LibEvent:trigger("tooltip.style.background", tip, unpack(addon.db.general.background))
    if (tip.BigFactionIcon) then tip.BigFactionIcon:Hide() end
    if (tip.SetBackdrop) then tip:SetBackdrop(nil) end
end)

LibEvent:attachTrigger("tooltip:show", function(self, tip)
    if (tip ~= GameTooltip) then return end
    LibEvent:trigger("tooltip.statusbar.position", addon.db.general.statusbarPosition, addon.db.general.statusbarOffsetX, addon.db.general.statusbarOffsetY)
    local w = GameTooltipStatusBar.TextString:GetWidth() + 10
    if (GameTooltipStatusBar:IsShown() and w > tip:GetWidth()) then
        tip:SetMinimumWidth(w+2)
        tip:Show()
    end
end)
