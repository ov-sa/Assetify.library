----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: threader.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Threader Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    coroutine = coroutine,
    math = math
}


-----------------------
--[[ Class: Thread ]]--
-----------------------

local thread = class:create("thread")

function thread.public:create(exec)
    if not exec or (imports.type(exec) ~= "function") then return false end
    local cThread = self:createInstance()
    if cThread then
        cThread.syncRate = {}
        cThread.thread = imports.coroutine.create(exec)
    end
    return cThread
end

function thread.public:createHeartbeat(conditionExec, exec, rate)
    if self ~= thread.public then return false end
    if not conditionExec or not exec or (imports.type(conditionExec) ~= "function") or (imports.type(exec) ~= "function") then return false end
    rate = imports.math.max(imports.tonumber(rate) or 0, 1)
    local cThread = thread.public:create(function(self)
        while(conditionExec()) do
            self:pause()
        end
        exec()
        conditionExec, exec = nil, nil
    end)
    cThread:resume({
        executions = 1,
        frames = rate
    })
    return cThread
end

function thread.public:destroy()
    if not thread.public:isInstance(self) then return false end
    if self.intervalTimer and timer:isInstance(self.intervalTimer) then self.intervalTimer:destroy() end
    if self.sleepTimer and timer:isInstance(self.sleepTimer) then self.sleepTimer:destroy() end
    self:destroyInstance()
    return true
end

function thread.public:status()
    if not thread.public:isInstance(self) then return false end
    return imports.coroutine.status(self.thread)
end

function thread.public:pause()
    return imports.coroutine.yield()
end

function thread.private.resume(cThread, abortTimer)
    if not thread.public:isInstance(cThread) or cThread.isAwaiting then return false end
    if abortTimer then
        if cThread.intervalTimer and timer:isInstance(cThread.intervalTimer) then cThread.intervalTimer:destroy() end
        cThread.syncRate.executions, cThread.syncRate.frames = false, false 
    end
    if cThread:status() == "dead" then cThread:destroy(); return false end
    if cThread:status() == "suspended" then imports.coroutine.resume(cThread.thread, cThread) end
    if cThread:status() == "dead" then cThread:destroy() end
    return true
end

function thread.public:resume(syncRate)
    if not thread.public:isInstance(self) then return false end
    syncRate = (syncRate and (imports.type(syncRate) == "table") and syncRate) or false
    local executions, frames = (syncRate and imports.tonumber(syncRate.executions)) or false, (syncRate and imports.tonumber(syncRate.frames)) or false
    if not executions or not frames then return thread.private.resume(self, true) end
    if self.intervalTimer and timer:isInstance(self.intervalTimer) then self.intervalTimer:destroy() end
    self.syncRate.executions, self.syncRate.frames = executions, frames
    timer:create(function(...)
        if not self.isAwaiting then
            for i = 1, self.syncRate.executions, 1 do
                thread.private.resume(self)
                if not thread.public:isInstance(self) then break end
            end
        end
        if thread.public:isInstance(self) then
            self.intervalTimer = timer:create(function()
                if self.isAwaiting then return false end
                for i = 1, self.syncRate.executions, 1 do
                    thread.private.resume(self)
                    if not thread.public:isInstance(self) then break end
                end
            end, self.syncRate.frames, 0)
        end
    end, 1, 1)
    return true
end

function thread.public:sleep(duration)
    duration = imports.math.max(0, imports.tonumber(duration) or 0)
    if not thread.public:isInstance(self) or self.isAwaiting then return false end
    if self.sleepTimer and timer:isInstance(self.sleepTimer) then return false end
    self.isAwaiting = "sleep"
    self.sleepTimer = timer:create(function()
        self.isAwaiting = nil
        self:resume()
    end, duration, 1)
    self:pause()
    return true
end

function thread.public:await(exec)
    if not thread.public:isInstance(self) then return false end
    if not exec or (imports.type(exec) ~= "function") then return exec end
    self.isAwaiting = "promise"
    exec(self)
    thread.public:pause()
    local resolvedValues = self.awaitingValues
    self.awaitingValues = nil
    return table:unpack(resolvedValues)
end

function thread.public:resolve(...)
    if not thread.public:isInstance(self) then return false end
    if not self.isAwaiting or (self.isAwaiting ~= "promise") then return false end
    timer:create(function(...)
        self.isAwaiting = nil
        self.awaitingValues = table:pack(...)
        thread.private.resume(self)
    end, 1, 1, ...)
    return true
end

function async(...) return thread.public:create(...) end