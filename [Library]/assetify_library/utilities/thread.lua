----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: thread.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Thread Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    setmetatable = setmetatable,
    collectgarbage = collectgarbage,
    setTimer = setTimer,
    isTimer = isTimer,
    killTimer = killTimer,
    coroutine = {
        create = coroutine.create,
        resume = coroutine.resume,
        status = coroutine.status
    }
}


-----------------------
--[[ Class: Thread ]]--
-----------------------

thread = {
    pause = coroutine.yield
}
thread.__index = thread

function thread:create(threadFunction)

    if not threadFunction or imports.type(threadFunction) ~= "function" then return false end

    local createdThread = imports.setmetatable({}, {__index = self})
    createdThread.syncRate = {}
    createdThread.thread = imports.coroutine.create(threadFunction)
    return createdThread

end

function thread:destroy()

    if self.timer and imports.isTimer(self.timer) then
        imports.killTimer(self.timer)
    end
    self.thread = nil
    imports.collectgarbage()
    return true

end

function thread:status()

    if not self.thread then
        return "dead"
    else
        return imports.coroutine.status(self.thread)
    end

end

function thread:resume(syncRate)

    self.syncRate.executions = (syncRate and imports.tonumber(syncRate.executions)) or false
    self.syncRate.frames = (self.syncRate.executions and syncRate and imports.tonumber(syncRate.frames)) or false

    if self.syncRate.executions and self.syncRate.frames then
        self.timer = imports.setTimer(function()
            local status = self:status()
            if status == "suspended" then
                for i = 1, self.syncRate.executions, 1 do
                    status = self:status()
                    if status == "dead" then
                        print("DESTROYING 1")
                        self:destroy()
                        return
                    end
                    imports.coroutine.resume(self.thread, self)
                end
            end
            status = self:status()
            if status == "dead" then
                print("DESTROYING 2")
                self:destroy()
            end
        end, self.syncRate.frames, 0)
    else
        imports.coroutine.resume(self.thread, self)
        if self.timer and imports.isTimer(self.timer) then
            imports.killTimer(self.timer)
        end
        local status = self:status()
        if status == "dead" then
            self:destroy()
        end
    end
    return true

end