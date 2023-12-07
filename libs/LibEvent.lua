
---------------------------------
-- 事件 (Event) Author: M
---------------------------------

local MAJOR, MINOR = "LibEvent.7000", 1
---@class LibEvent.7000
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end
---@type table<WowEvent, function[]>, table<string, function[]>
lib.events, lib.triggers = {}, {}

local frame = CreateFrame("Frame", nil, UIParent)

frame:SetScript("OnEvent", function(self, event, ...)
    ---@cast event string
    if (not lib.events[event]) then return end
    for k, v in pairs(lib.events[event]) do
        v(v, ...)
    end
end)

---模擬觸發bliz事件 (Simulate triggering Blizzard event)
---@param event string
---@vararg any
function lib:event(event, ...)
    if (not lib.events[event]) then return end
    for k, v in pairs(lib.events[event]) do
        v(v, ...)
    end
end

--- 添加Blizzard事件回调 (Add Blizzard event callback)
---@param event string Event to listen for.
---@param func function Callback function for event.
---@return LibEvent.7000
function lib:addEventListener(event, func)
    for e in string.gmatch(event, "([^,%s]+)") do
        if (not self.events[e]) then
            self.events[e] = {}
            frame:RegisterEvent(e)
        end
        table.insert(self.events[e], func)
    end
    return self
end

---刪除bliz事件回調 (Delete Blizzard event callback)
---Remove a callback from a specific event. Or remove a specific callback from all events.
---@param event string Event for callback to be removed.
---@param func function func ref to be removed.
---@return LibEvent.7000
---@overload fun(func: function): LibEvent.7000
function lib:removeEventListener(event, func)
    if (type(event) == "function") then
        for _, funcs in pairs(self.events) do
            for k, v in pairs(funcs) do
                if (v == event) then
                    funcs[k] = nil
                end
            end
        end
    elseif (self.events[event]) then
        for k, v in pairs(self.events[event]) do
            if (v == func) then
                self.events[event][k] = nil
            end
        end
    end
    return self
end

---一次性bliz事件回調 One-time Blizzard event callback
---@param event string Event to listen for.
---@param func function One-time invoked callback for event.
---@return LibEvent.7000
function lib:addEventListenerOnce(event, func)
    return self:addEventListener(event, function(this, ...)
        func(this, ...)
        lib:removeEventListener(event, this)
    end)
end

---添加觸發事件 多個用逗號分隔 (Add trigger event, separated by commas)
---@param event string Trigger Event(s) to listen for. Multiple events can be separated by commas.
---@param func function Callback function for the event(s).
function lib:addTriggerListener(event, func)
    for e in string.gmatch(event, "([^,%s]+)") do
        if (not self.triggers[e]) then
            self.triggers[e] = {}
        end
        table.insert(self.triggers[e], func)
    end
    return self
end

---刪除事件回調 (Delete event callback)
---Remove a callback from a specific Trigger. Or remove a specific callback from all Triggers.
---@param event string Event for callback to be removed.
---@param func function func ref to be removed.
---@return LibEvent.7000
---@overload fun(func: function): LibEvent.7000
function lib:removeTriggerListener(event, func)
    if (type(event) == "function") then
        for _, funcs in pairs(self.triggers) do
            for k, v in pairs(funcs) do
                if (v == event) then
                    funcs[k] = nil
                end
            end
        end
    elseif (self.triggers[event]) then
        for k, v in pairs(self.triggers[event]) do
            if (v == func) then
                self.triggers[event][k] = nil
            end
        end
    end
    return self
end

---刪除事件回調 (Delete all event callback)
---Remove all callbacks from a specific Trigger.
---@param event string Trigger event.
function lib:removeAllTriggers(event)
    self.triggers[event] = nil
    return self
end

---一次性觸發事件 (One-time trigger event)
---@param event string Trigger Event.
---@param func function One-time invoked callback for the event.
function lib:addTriggerListenerOnce(event, func)
    return self:addTriggerListener(event, function(this, ...)
        func(this, ...)
        lib:removeTriggerListener(event, this)
    end)
end

---觸發事件 (Trigger event)
---@param event string Trigger Event.
---@vararg any Event arguments.
function lib:trigger(event, ...)
    if (not self.triggers[event]) then return end
    for k, v in pairs(self.triggers[event]) do
        v(v, ...)
    end
end

--函數別名 (Function alias)
lib.attachEvent = lib.addEventListener
lib.attachEventOnce = lib.addEventListenerOnce
lib.detachEvent = lib.removeEventListener
lib.attachTrigger = lib.addTriggerListener
lib.attachTriggerOnce = lib.addTriggerListenerOnce
lib.detachTrigger = lib.removeTriggerListener
lib.detachAllTriggers = lib.removeAllTriggers
