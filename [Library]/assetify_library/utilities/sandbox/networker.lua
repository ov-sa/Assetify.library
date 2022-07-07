----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: networker.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Networker Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    md5 = md5,
    tonumber = tonumber,
    tostring = tostring,
    isElement = isElement,
    getElementType = getElementType,
    getThisResource = getThisResource,
    getResourceName = getResourceName,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent,
    triggerRemoteEvent = (localPlayer and triggerServerEvent) or triggerClientEvent,
    triggerRemoteLatentEvent = (localPlayer and triggerLatentServerEvent) or triggerLatentClientEvent
}


------------------------
--[[ Class: Network ]]--
------------------------

local network = class:create("network", {
    identifier = imports.md5(imports.getResourceName(imports.getThisResource())),
    isServerInstance = (not localPlayer and true) or false,
    bandwidth = 1250000
})
network.private.buffer = {}
network.private.cache = {
    execSerials = {}
}

imports.addEvent("Assetify:Networker:API", true)
imports.addEventHandler("Assetify:Networker:API", root, function(serial, payload)
    if not serial or not payload or not payload.processType or (payload.isRestricted and (serial ~= network.public.identifier)) then return false end
    if payload.processType == "emit" then
        local cNetwork = network.public:fetch(payload.networkName)
        if cNetwork and not cNetwork.isCallback then
            for i, j in imports.pairs(cNetwork.handlers) do
                if i and (imports.type(i) == "function") then
                    thread:create(function(self)
                        if not j.config.isAsync then
                            i(table:unpack(payload.processArgs))
                        else
                            i(self, table:unpack(payload.processArgs))
                        end
                        j.config.subscriptionCount = (j.config.subscriptionLimit and (j.config.subscriptionCount + 1)) or false
                        if j.config.subscriptionLimit and (j.config.subscriptionCount >= j.config.subscriptionLimit) then
                            cNetwork:off(i)
                        end
                    end):resume()
                end
            end
        end
    elseif payload.processType == "emitCallback" then
        if not payload.isSignal then
            local cNetwork = network.public:fetch(payload.networkName)
            if cNetwork and cNetwork.isCallback then
                if not cNetwork or not cNetwork.isCallback or not cNetwork.handler then return false end
                payload.isSignal = true
                payload.isRestricted = true
                thread:create(function(self)
                    if not cNetwork.handler.config.isAsync then
                        payload.processArgs = {cNetwork.handler.exec(table:unpack(payload.processArgs))}
                    else
                        payload.processArgs = {cNetwork.handler.exec(self, table:unpack(payload.processArgs))}
                    end
                    if not payload.isRemote then
                        imports.triggerEvent("Assetify:Networker:API", resourceRoot, serial, payload)
                    else
                        if not payload.isReceiver or not network.public.isServerInstance then
                            if not payload.isLatent then
                                imports.triggerRemoteEvent("Assetify:Networker:API", resourceRoot, serial, payload)
                            else
                                imports.triggerRemoteLatentEvent("Assetify:Networker:API", network.public.bandwidth, false, resourceRoot, serial, payload)
                            end
                        else
                            if not payload.isLatent then
                                imports.triggerRemoteEvent(payload.isReceiver, "Assetify:Networker:API", resourceRoot, serial, payload)
                            else
                                imports.triggerRemoteLatentEvent(payload.isReceiver, "Assetify:Networker:API", network.public.bandwidth, false, resourceRoot, serial, payload)
                            end
                        end
                    end
                end):resume()
            end
        else
            if network.private.cache.execSerials[(payload.execSerial)] then
                network.private.cache.execSerials[(payload.execSerial)](table:unpack(payload.processArgs))
                network.public:deserializeExec(payload.execSerial)
            end
        end
    end
end)

function network.private:fetchArg(index, pool)
    index = imports.tonumber(index) or 1
    if not pool or (imports.type(pool) ~= "table") then return false end
    local argValue = pool[index]
    table:remove(pool, index)
    return argValue
end

function network.public:create(...)
    local cNetwork = self:createInstance()
    if cNetwork and not cNetwork:load(...) then
        cNetwork:destroyInstance()
        return false
    end
    return cNetwork
end

function network.public:destroy(...)
    if not network.public:isInstance(self) then return false end
    return self:unload(...)
end

function network.public:load(name, isCallback)
    if not network.public:isInstance(self) then return false end
    if not name or (imports.type(name) ~= "string") or network.private.buffer[name] then return false end
    self.name = name
    self.owner = network.public.identifier
    self.isCallback = (isCallback and true) or false
    if not self.isCallback then self.handlers = {} end
    network.private.buffer[name] = self
    return true
end

function network.public:unload()
    if not network.public:isInstance(self) then return false end
    network.private.buffer[(self.name)] = nil
    self:destroyInstance()
    return true
end

function network.public:fetch(name, isRemote)
    if self ~= network.public then return false end
    local cNetwork = network.private.buffer[name] or false
    if not cNetwork and isRemote then
        cNetwork = network.public:create(name)
    end
    return cNetwork
end

function network.public:serializeExec(exec)
    if self ~= network.public then return false end
    if not exec or (imports.type(exec) ~= "function") then return false end
    local cSerial = imports.md5(network.public.identifier..":"..imports.tostring(exec))
    network.private.cache.execSerials[cSerial] = exec
    return cSerial
end

function network.public:deserializeExec(serial)
    if self ~= network.public then return false end
    network.private.cache.execSerials[serial] = nil
    return true
end

function network.public:on(exec, config)
    if not network.public:isInstance(self) then return false end
    if not exec or (imports.type(exec) ~= "function") then return false end
    config = (config and (imports.type(config) == "table") and config) or {}
    config.isAsync = (config.isAsync and true) or false
    config.subscriptionLimit = (not self.isCallback and imports.tonumber(config.subscriptionLimit)) or false
    config.subscriptionLimit = (config.subscriptionLimit and math.max(1, config.subscriptionLimit)) or config.subscriptionLimit
    config.subscriptionCount = (config.subscriptionLimit and 0) or false
    if self.isCallback then
        if not self.handler then
            self.handler = {exec = exec, config = config}
            return true
        end
    else
        if not self.handlers[exec] then
            self.handlers[exec] = {config = config}
            return true
        end
    end
    return false
end

function network.public:off(exec)
    if not network.public:isInstance(self) then return false end
    if not exec or (imports.type(exec) ~= "function") then return false end
    if self.isCallback then
        if self.handler and (self.handler == exec) then
            self.handler = nil
            return true
        end
    else
        if self.handlers[exec] then
            self.handlers[exec] = nil
            return true
        end
    end
    return false
end

function network.public:emit(...)
    if not self then return false end
    local cArgs = table:pack(...)
    local payload = {
        isRemote = false,
        isRestricted = false,
        processType = "emit",
        networkName = false
    }
    if self == network.public then
        payload.networkName, payload.isRemote = network.private:fetchArg(_, cArgs), network.private:fetchArg(_, cArgs)
        if payload.isRemote then
            payload.isLatent = network.private:fetchArg(_, cArgs)
            if network.public.isServerInstance then
                payload.isReceiver = network.private:fetchArg(_, cArgs)
                payload.isReceiver = (payload.isReceiver and imports.isElement(payload.isReceiver) and (imports.getElementType(payload.isReceiver) == "player") and payload.isReceiver) or false
            end
        end
    else
        payload.isRestricted = true
        payload.networkName = self.name
    end
    payload.processArgs = cArgs
    if not payload.isRemote then
        imports.triggerEvent("Assetify:Networker:API", resourceRoot, network.public.identifier, payload)
    else
        if payload.isReceiver then
            if not payload.isLatent then
                imports.triggerRemoteEvent(payload.isReceiver, "Assetify:Networker:API", resourceRoot, network.public.identifier, payload)
            else
                imports.triggerRemoteLatentEvent(payload.isReceiver, "Assetify:Networker:API", network.public.bandwidth, false, resourceRoot, network.public.identifier, payload)
            end
        else
            if not payload.isLatent then
                imports.triggerRemoteEvent("Assetify:Networker:API", resourceRoot, network.public.identifier, payload)
            else
                imports.triggerRemoteLatentEvent("Assetify:Networker:API", network.public.bandwidth, false, resourceRoot, network.public.identifier, payload)
            end
        end
    end
    return true
end

function network.public:emitCallback(cThread, ...)
    if not self or not cThread or not thread:isInstance(cThread) then return false end
    local cThread = cThread
    local cArgs, cExec = table:pack(...), function(...) return cThread:resolve(...) end
    local payload = {
        isRemote = false,
        isRestricted = false,
        processType = "emitCallback",
        networkName = false,
        execSerial = network.public:serializeExec(cExec)
    }
    if self == network.public then
        payload.networkName, payload.isRemote = network.private:fetchArg(_, cArgs), network.private:fetchArg(_, cArgs)
        if payload.isRemote then
            payload.isLatent = network.private:fetchArg(_, cArgs)
            if not network.public.isServerInstance then
                payload.isReceiver = localPlayer
            else
                payload.isReceiver = network.private:fetchArg(_, cArgs)
                payload.isReceiver = (payload.isReceiver and imports.isElement(payload.isReceiver) and (imports.getElementType(payload.isReceiver) == "player") and payload.isReceiver) or false
            end
        end
    else
        payload.isRestricted = true
        payload.networkName = self.name
    end
    payload.processArgs = cArgs
    if not payload.isRemote then
        return function() imports.triggerEvent("Assetify:Networker:API", resourceRoot, network.public.identifier, payload) end
    else
        if not payload.isLatent then
            return function() imports.triggerRemoteEvent("Assetify:Networker:API", resourceRoot, network.public.identifier, payload) end
        else
            return function() imports.triggerRemoteLatentEvent("Assetify:Networker:API", network.public.bandwidth, false, resourceRoot, network.public.identifier, payload) end
        end
    end
end