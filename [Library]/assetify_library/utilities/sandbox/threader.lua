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
    pairs = pairs,
    error = error,
    tonumber = tonumber,
    collectgarbage = collectgarbage,
    coroutine = coroutine
}


-----------------------
--[[ Class: Thread ]]--
-----------------------

local thread = class:create("thread")
thread.private.promises = {}

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
    rate = math.max(imports.tonumber(rate) or 0, 1)
    local cThread = thread.public:create(function(self)
        while(conditionExec()) do
            self:pause()
        end
        exec()
        conditionExec, exec = nil, nil
    end)
    cThread:resume({executions = 1, frames = rate})
    return cThread
end

function thread.public:createPromise(callback, isAsync)
    if self ~= thread.public then return false end
    if not callback or (imports.type(callback) ~= "function") then return false end
    isAsync = (isAsync and true) or false
    local cThread, cHandle = nil, nil
    local isHandled = false
    local cPromise = {
        thread = cThread,
        resolve = function(...) return cHandle(true, ...) end,
        reject = function(...) return cHandle(false, ...) end
    }
    cHandle = function(isResolver, ...)
        if not thread.private.promises[cPromise] or isHandled then return false end
        isHandled = true
        assetify.timer:create(function(...)
            for i, j in imports.pairs(thread.private.promises[cPromise]) do
                thread.private.resolve(i, isResolver, ...)
            end
            thread.private.promises[cPromise] = nil
            imports.collectgarbage()
        end, 1, 1, ...)
        return true
    end
    thread.private.promises[cPromise] = {}
    if not isAsync then callback(cPromise.resolve, cPromise.reject)
    else callback(cPromise.thread, cPromise.resolve, cPromise.reject) end
    return cPromise
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
    duration = math.max(0, imports.tonumber(duration) or 0)
    if not thread.public:isInstance(self) or self.isAwaiting then return false end
    if self.sleepTimer and timer:isInstance(self.sleepTimer) then return false end
    self.isAwaiting = "sleep"
    self.sleepTimer = timer:create(function()
        self.isAwaiting = nil
        thread.private.resume(self)
    end, duration, 1)
    self:pause()
    return true
end

function thread.public:await(cPromise)
    if not thread.public:isInstance(self) or self.isAwaiting then return false end
    if not cPromise or not thread.private.promises[cPromise] then return false end
    self.isAwaiting = cPromise
    thread.private.promises[cPromise][self] = true
    thread.public:pause()
    local resolvedValues = self.resolvedValues
    self.resolvedValues = nil
    if self.isErrored then imports.error(resolvedValues)
    else return table.unpack(resolvedValues) end
end

function thread.private.resolve(cThread, isResolved, ...)
    if not thread.public:isInstance(cThread) then return false end
    if not cThread.isAwaiting or not thread.private.promises[(cThread.isAwaiting)] then return false end
    timer:create(function(...)
        cThread.isAwaiting = nil
        cThread.isErrored = not isResolved
        cThread.resolvedValues = table.pack(...)
        thread.private.resume(cThread)
    end, 1, 1, ...)
    return true
end

function async(...) return thread.public:create(...) end