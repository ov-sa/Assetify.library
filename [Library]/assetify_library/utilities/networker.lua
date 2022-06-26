----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: networker.lua
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
    triggerRemoteLatentEvent = (localPlayer and triggerLatentServerEvent) or triggerLatentClientEvent,
    json = json,
    table = table
}


------------------------
--[[ Class: Network ]]--
------------------------

network = class.create("network", {
    identifier = imports.md5(imports.getResourceName(imports.getThisResource())),
    isServerInstance = (not localPlayer and true) or false,
    bandwidth = 1250000,
    buffer = {},
    cache = {
        execSerials = {}
    }
})

imports.addEvent("Assetify:Network:API", true)
imports.addEventHandler("Assetify:Network:API", root, function(serial, payload)
    if not serial or not payload or not payload.processType or (payload.isRestricted and (serial ~= network.identifier)) then return false end
    if payload.processType == "emit" then
        local cNetwork = network:fetch(payload.networkName)
        if cNetwork and not cNetwork.isCallback then
            for i, j in imports.pairs(cNetwork.handlers) do
                if i and (imports.type(i) == "function") then
                    thread:create(function(self)
                        if not j.isAsync then
                            i(imports.table.unpack(payload.processArgs))
                        else
                            i(self, imports.table.unpack(payload.processArgs))
                        end
                    end):resume()
                end
            end
        end
    elseif payload.processType == "emitCallback" then
        if not payload.isSignal then
            local cNetwork = network:fetch(payload.networkName)
            if cNetwork and cNetwork.isCallback then
                if not cNetwork or not cNetwork.isCallback or not cNetwork.handler then return false end
                payload.isSignal = true
                payload.isRestricted = true
                thread:create(function(self)
                    if not cNetwork.handler.isAsync then
                        payload.processArgs = {cNetwork.handler.exec(imports.table.unpack(payload.processArgs))}
                    else
                        payload.processArgs = {cNetwork.handler.exec(self, imports.table.unpack(payload.processArgs))}
                    end
                    if not payload.isRemote then
                        imports.triggerEvent("Assetify:Network:API", resourceRoot, serial, payload)
                    else
                        if not payload.isReceiver or not network.isServerInstance then
                            if not payload.isLatent then
                                imports.triggerRemoteEvent("Assetify:Network:API", resourceRoot, serial, payload)
                            else
                                imports.triggerRemoteLatentEvent("Assetify:Network:API", network.bandwidth, false, resourceRoot, serial, payload)
                            end
                        else
                            if not payload.isLatent then
                                imports.triggerRemoteEvent(payload.isReceiver, "Assetify:Network:API", resourceRoot, serial, payload)
                            else
                                imports.triggerRemoteLatentEvent(payload.isReceiver, "Assetify:Network:API", network.bandwidth, false, resourceRoot, serial, payload)
                            end
                        end
                    end
                end):resume()
            end
        else
            if network.cache.execSerials[(payload.execSerial)] then
                network.cache.execSerials[(payload.execSerial)](imports.table.unpack(payload.processArgs))
                network:deserializeExec(payload.execSerial)
            end
        end
    end
end)

network.fetchArg = function(index, pool)
    index = imports.tonumber(index) or 1
    if not pool or (imports.type(pool) ~= "table") then return false end
    local argValue = pool[index]
    imports.table.remove(pool, index)
    return argValue
end

function network:create(...)
    local cNetwork = self:createInstance()
    if cNetwork and not cNetwork:load(...) then
        cNetwork:destroyInstance()
        return false
    end
    return cNetwork
end

function network:destroy(...)
    if not self or (self == network) then return false end
    return self:unload(...)
end

function network:load(name, isCallback)
    if not self or (self == network) then return false end
    if not name or (imports.type(name) ~= "string") or network.buffer[name] then return false end
    self.name = name
    self.owner = network.identifier
    self.isCallback = (isCallback and true) or false
    if not self.isCallback then self.handlers = {} end
    network.buffer[name] = self
    return true
end

function network:unload()
    if not self or (self == network) then return false end
    network.buffer[(self.name)] = nil
    self:destroyInstance()
    return true
end

function network:fetch(name, isRemote)
    if not self or (self ~= network) then return false end
    local cNetwork = network.buffer[name] or false
    if not cNetwork and isRemote then
        cNetwork = network:create(name)
    end
    return cNetwork
end

function network:serializeExec(exec)
    if not self or (self ~= network) then return false end
    if not exec or (imports.type(exec) ~= "function") then return false end
    local cSerial = imports.md5(network.identifier..":"..imports.tostring(exec))
    network.cache.execSerials[cSerial] = exec
    return cSerial
end

function network:deserializeExec(serial)
    if not self or (self ~= network) then return false end
    network.cache.execSerials[serial] = nil
    return true
end

function network:on(exec, isAsync)
    if not self or (self == network) then return false end
    if not exec or (imports.type(exec) ~= "function") then return false end
    isAsync = (isAsync and true) or false
    if self.isCallback then
        if not self.handler then
            self.handler = {exec = exec, isAsync = isAsync}
            return true
        end
    else
        if not self.handlers[exec] then
            self.handlers[exec] = {isAsync = isAsync}
            return true
        end
    end
    return false
end

function network:off(exec)
    if not self or (self == network) then return false end
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

function network:emit(...)
    if not self then return false end
    local cArgs = imports.table.pack(...)
    local payload = {
        isRemote = false,
        isRestricted = false,
        processType = "emit",
        networkName = false
    }
    if self == network then
        payload.networkName, payload.isRemote = network.fetchArg(_, cArgs), network.fetchArg(_, cArgs)
        if payload.isRemote then
            payload.isLatent = network.fetchArg(_, cArgs)
            if network.isServerInstance then
                payload.isReceiver = network.fetchArg(_, cArgs)
                payload.isReceiver = (payload.isReceiver and imports.isElement(payload.isReceiver) and (imports.getElementType(payload.isReceiver) == "player") and payload.isReceiver) or false
            end
        end
    else
        payload.isRestricted = true
        payload.networkName = self.name
    end
    payload.processArgs = cArgs
    if not payload.isRemote then
        imports.triggerEvent("Assetify:Network:API", resourceRoot, network.identifier, payload)
    else
        if payload.isReceiver then
            if not payload.isLatent then
                imports.triggerRemoteEvent(payload.isReceiver, "Assetify:Network:API", resourceRoot, network.identifier, payload)
            else
                imports.triggerRemoteLatentEvent(payload.isReceiver, "Assetify:Network:API", network.bandwidth, false, resourceRoot, network.identifier, payload)
            end
        else
            if not payload.isLatent then
                imports.triggerRemoteEvent("Assetify:Network:API", resourceRoot, network.identifier, payload)
            else
                imports.triggerRemoteLatentEvent("Assetify:Network:API", network.bandwidth, false, resourceRoot, network.identifier, payload)
            end
        end
    end
    return true
end

function network:emitCallback(cThread, ...)
    if not self or not cThread or (thread:getType(cThread) ~= "thread") then return false end
    local cThread = cThread
    local cArgs, cExec = imports.table.pack(...), function(...) return cThread:resolve(...) end
    local payload = {
        isRemote = false,
        isRestricted = false,
        processType = "emitCallback",
        networkName = false,
        execSerial = network:serializeExec(cExec)
    }
    if self == network then
        payload.networkName, payload.isRemote = network.fetchArg(_, cArgs), network.fetchArg(_, cArgs)
        if payload.isRemote then
            payload.isLatent = network.fetchArg(_, cArgs)
            if not network.isServerInstance then
                payload.isReceiver = localPlayer
            else
                payload.isReceiver = network.fetchArg(_, cArgs)
                payload.isReceiver = (payload.isReceiver and imports.isElement(payload.isReceiver) and (imports.getElementType(payload.isReceiver) == "player") and payload.isReceiver) or false
            end
        end
    else
        payload.isRestricted = true
        payload.networkName = self.name
    end
    payload.processArgs = cArgs
    if not payload.isRemote then
        return function() imports.triggerEvent("Assetify:Network:API", resourceRoot, network.identifier, payload) end
    else
        if not payload.isLatent then
            return function() imports.triggerRemoteEvent("Assetify:Network:API", resourceRoot, network.identifier, payload) end
        else
            return function() imports.triggerRemoteLatentEvent("Assetify:Network:API", network.bandwidth, false, resourceRoot, network.identifier, payload) end
        end
    end
end