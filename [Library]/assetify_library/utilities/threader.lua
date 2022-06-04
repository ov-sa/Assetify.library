----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: threader.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Threader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    unpack = unpack,
    tonumber = tonumber,
    setmetatable = setmetatable,
    collectgarbage = collectgarbage,
    setTimer = setTimer,
    isTimer = isTimer,
    killTimer = killTimer,
    coroutine = coroutine,
    math = math
}


-----------------------
--[[ Class: Thread ]]--
-----------------------

thread = {
    buffer = {}
}
thread.__index = thread

function thread:isInstance(cThread)
    if not self then return false end
    if self == thread then return (cThread.isThread and true) or false end
    return (self.isThread and true) or false
end

function thread:create(exec)
    if not exec or imports.type(exec) ~= "function" then return false end
    local cThread = imports.setmetatable({}, {__index = self})
    cThread.isThread = true
    cThread.syncRate = {}
    cThread.thread = imports.coroutine.create(exec)
    thread.buffer[cThread] = true
    return cThread
end

function thread:destroy()
    if not self or (self == thread) then return false end
    if self.timer and imports.isTimer(self.timer) then
        imports.killTimer(self.timer)
    end
    thread.buffer[self] = nil
    self = nil
    imports.collectgarbage()
    return true
end

function thread:status()
    if not self or (self == thread) then return false end
    if not self.thread then
        return "dead"
    else
        return imports.coroutine.status(self.thread)
    end
end

function thread:pause()
    return imports.coroutine.yield()
end

function thread:resume(syncRate)
    if not self or (self == thread) then return false end
    self.syncRate.executions = (syncRate and imports.tonumber(syncRate.executions)) or false
    self.syncRate.frames = (self.syncRate.executions and syncRate and imports.tonumber(syncRate.frames)) or false
    if self.syncRate.executions and self.syncRate.frames then
        self.timer = imports.setTimer(function()
            local status = self:status()
            if status == "suspended" then
                for i = 1, self.syncRate.executions, 1 do
                    status = self:status()
                    if status == "dead" then
                        self:destroy()
                        return
                    end
                    imports.coroutine.resume(self.thread, self)
                end
            end
            status = self:status()
            if status == "dead" then
                self:destroy()
            end
        end, self.syncRate.frames, 0)
    else
        if self.timer and imports.isTimer(self.timer) then
            imports.killTimer(self.timer)
        end
        local status = self:status()
        if status == "suspended" then
            imports.coroutine.resume(self.thread, self)
        end
        status = self:status()
        if status == "dead" then
            self:destroy()
        end
    end
    return true
end

function thread:sleep(duration)
    duration = imports.math.max(0, imports.tonumber(duration) or 0)
    if not self or (self == thread) then return false end
    if self.timer and imports.isTimer(self.timer) then return false end
    self.timer = imports.setTimer(function()
        self:resume()
    end, duration, 1)
    self:pause()
    return true
end

function thread:await(exec)
    if not self or (self == thread) then return false end
    if not exec or imports.type(exec) ~= "function" then return self:resolve(exec) end
    self.isScheduled = true
    exec(self)
    thread:pause()
    local resolvedValues = self.scheduledValues
    self.scheduledValues = nil
    return imports.unpack(resolvedValues)
end

function thread:resolve(...)
    if not self or (self == thread) then return false end
    if not self.isScheduled then return false end
    self.scheduledValues = {...}
    local self = self
    imports.setTimer(function()
        self:resume()
    end, 1, 1)
    return true
end

function async(...) return thread:create(...) end