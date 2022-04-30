----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: streamer.lua
     Author: vStudio
     Developer(s): Aviril, Tron
     DOC: 19/10/2021
     Desc: Streamer Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    getCamera = getCamera,
    isElement = isElement,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    attachElements = attachElements,
    setmetatable = setmetatable,
    getTickCount = getTickCount,
    isTimer = isTimer,
    setTimer = setTimer,
    isElementOnScreen = isElementOnScreen,
    getElementDimension = getElementDimension,
    getElementInterior = getElementInterior,
    setElementDimension = setElementDimension,
    setElementInterior = setElementInterior,
    getElementVelocity = getElementVelocity
}


-------------------------
--[[ Class: Streamer ]]--
-------------------------

streamer = {
    buffer = {},
    cache = {
        clientCamera = imports.getCamera()
    },
    allocator = {
        validStreams = {"bone"}
    }
}
streamer.__index = streamer

local onEntityStream, onBoneStream, onBoneUpdate = nil, nil, nil
streamer.allocator.__validStreams = {}
for i = 1, #streamer.allocator.validStreams, 1 do
    local j = streamer.allocator.validStreams[i]
    streamer.allocator.__validStreams[j] = true
end
streamer.allocator.validStreams = streamer.allocator.__validStreams
streamer.allocator.__validStreams = nil

function streamer:create(...)
    local cStreamer = imports.setmetatable({}, {__index = self})
    if not cStreamer:load(...) then
        cStreamer = nil
        return false
    end
    return cStreamer
end

function streamer:destroy(...)
    if not self or (self == streamer) then return false end
    return self:unload(...)
end

function streamer:load(streamerInstance, streamType, occlusionInstances, syncRate)
    if not self or (self == streamer) then return false end
    if not streamerInstance or not streamType or not imports.isElement(streamerInstance) or not occlusionInstances or not occlusionInstances[1] or not imports.isElement(occlusionInstances[1]) then return false end
    local streamDimension, streamInterior = imports.getElementDimension(occlusionInstances[1]), imports.getElementInterior(occlusionInstances[1])
    self.streamer = streamerInstance
    self.streamType = streamType
    self.occlusions = occlusionInstances
    self.dimension = streamDimension
    self.interior = streamInterior
    self.syncRate = syncRate or streamerSettings.syncRate
    if streamerInstance ~= occlusionInstances[1] then
        if streamType ~= "bone" then
            imports.attachElements(streamerInstance, occlusionInstances[1])
        end
        imports.setElementDimension(streamerInstance, streamDimension)
        imports.setElementInterior(streamerInstance, streamInterior)
    end
    streamer.buffer[streamDimension] = streamer.buffer[streamDimension] or {}
    streamer.buffer[streamDimension][streamInterior] = streamer.buffer[streamDimension][streamInterior] or {}
    streamer.buffer[streamDimension][streamInterior][streamType] = streamer.buffer[streamDimension][streamInterior][streamType] or {}
    streamer.buffer[streamDimension][streamInterior][streamType][self] = {
        isStreamed = false
    }
    self:allocate()
    return true
end

function streamer:unload()
    if not self or (self == streamer) then return false end
    local streamType = self.streamType
    local streamDimension, streamInterior = imports.getElementDimension(self.occlusions[1]), imports.getElementInterior(self.occlusions[1])
    streamer.buffer[streamDimension][streamInterior][streamType][self] = nil
    self:deallocate()
    self = nil
    return true
end

function streamer:update(clientDimension, clientInterior)
    if not clientDimension and not clientInterior then return false end
    local currentDimension, currentInterior = imports.getElementDimension(localPlayer), imports.getElementInterior(localPlayer)
    clientDimension, clientInterior = clientDimension or _clientDimension, clientInterior or clientInterior
    if streamer.waterBuffer then
        imports.setElementDimension(streamer.waterBuffer, currentDimension)
        imports.setElementInterior(streamer.waterBuffer, currentInterior)
    end
    if streamer.buffer[clientDimension] and streamer.buffer[clientDimension][clientInterior] then
        for i, j in imports.pairs(streamer.buffer[clientDimension][clientInterior]) do
            if j then
                imports.setElementDimension(i.streamer, streamerSettings.unsyncDimension)
            end
        end
    end
    streamer.cache.isCameraTranslated = true
    streamer.cache.clientWorld = streamer.cache.clientWorld or {}
    streamer.cache.clientWorld.dimension = currentDimension
    streamer.cache.clientWorld.interior = currentInterior
    return true
end

function streamer:allocate()
    if not self or (self == streamer) then return false end
    if not streamer.allocator.validStreams[(self.streamType)] then return false end
    streamer.allocator[(self.syncRate)] = streamer.allocator[(self.syncRate)] or {}
    streamer.allocator[(self.syncRate)][(self.streamType)] = streamer.allocator[(self.syncRate)][(self.streamType)] or {}
    streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] = streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or {}
    streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] = streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] or {}
    local streamBuffer = streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)]
    if self.streamType == "bone" then
        if self.syncRate <= 0 then
            if not streamer.allocator[(self.syncRate)][(self.streamType)].cTimer then
                streamer.allocator[(self.syncRate)][(self.streamType)].cTimer = true
                imports.addEventHandler("onClientPedsProcessed", root, onBoneUpdate)
            end
        else
            if not streamer.allocator[(self.syncRate)][(self.streamType)].cTimer or not imports.isTimer(streamer.allocator[(self.syncRate)][(self.streamType)].cTimer) then
                streamer.allocator[(self.syncRate)][(self.streamType)].cTimer = imports.setTimer(onBoneUpdate, self.syncRate, 0, streamer.allocator[(self.syncRate)][(self.streamType)])
            end
        end
        streamBuffer[self] = streamer.buffer[(self.dimension)][(self.interior)][(self.streamType)][self]
    end
    return true
end

function streamer:deallocate()
    if not self or (self == streamer) then return false end
    if not streamer.allocator.validStreams[(self.streamType)] then return false end
    if not streamer.allocator[(self.syncRate)] or not streamer.allocator[(self.syncRate)][(self.streamType)] or not streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or not streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] then return false end
    local isAllocatorVoid = true
    streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)][self] = nil
    for i, j in imports.pairs(streamer.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)]) do
        isAllocatorVoid = false
        break
    end
    if isAllocatorVoid then
        if self.streamType == "bone" then
            if self.syncRate <= 0 then
                if streamer.allocator[(self.syncRate)][(self.streamType)].cTimer then
                    imports.removeEventHandler("onClientPedsProcessed", root, onBoneUpdate)
                    streamer.allocator[(self.syncRate)][(self.streamType)].cTimer = nil
                end
            else
                if streamer.allocator[(self.syncRate)][(self.streamType)].cTimer and imports.isTimer(streamer.allocator[(self.syncRate)][(self.streamType)].cTimer) then
                    imports.destroyElement(streamer.allocator[(self.syncRate)][(self.streamType)].cTimer)
                    streamer.allocator[(self.syncRate)][(self.streamType)].cTimer = nil
                end
            end
        end
    end
    return true
end

onEntityStream = function(streamBuffer)
    if not streamBuffer then return false end
    for i, j in imports.pairs(streamBuffer) do
        if j then
            j.isStreamed = false
            for k = 1, #i.occlusions, 1 do
                local v = i.occlusions[k]
                if imports.isElementOnScreen(v) then
                    j.isStreamed = true
                    break
                end
            end
            imports.setElementDimension(i.streamer, (j.isStreamed and streamer.cache.clientWorld.dimension) or streamerSettings.unsyncDimension)
        end
    end
    return true
end

onBoneStream = function(streamBuffer)
    if not streamBuffer then return false end
    for i, j in imports.pairs(streamBuffer) do
        if j and j.isStreamed then
            bone.buffer.element[(i.streamer)]:update()
        end
    end
    bone.cache.streamTick = imports.getTickCount()
    return true
end

onBoneUpdate = function(streamBuffer)
    streamBuffer = streamBuffer or (streamer.allocator[0] and streamer.allocator[0]["bone"]) or false
    local clientDimension, clientInterior = streamer.cache.clientWorld.dimension, streamer.cache.clientWorld.interior
    if streamBuffer and streamBuffer[clientDimension] and streamBuffer[clientDimension][clientInterior] then
        onBoneStream(streamBuffer[clientDimension][clientInterior])
    end
end

imports.addEventHandler("onAssetifyLoad", root, function()
    streamer:update(imports.getElementDimension(localPlayer))
    imports.setTimer(function()
        if streamer.cache.isCameraTranslated then return false end
        local velX, velY, velZ = imports.getElementVelocity(streamer.cache.clientCamera)
        streamer.cache.isCameraTranslated = ((velX ~= 0) and true) or ((velY ~= 0) and true) or ((velZ ~= 0) and true) or false
    end, streamerSettings.cameraSyncRate, 0)
    imports.setTimer(function()
        if not streamer.cache.isCameraTranslated then return false end
        local clientDimension, clientInterior = streamer.cache.clientWorld.dimension, streamer.cache.clientWorld.interior
        if streamer.buffer[clientDimension] and streamer.buffer[clientDimension][clientInterior] then
            for i, j in imports.pairs(streamer.buffer[clientDimension][clientInterior]) do
                onEntityStream(j)
            end
        end
        if streamer.buffer[-1] and streamer.buffer[-1][clientInterior] then
            for i, j in imports.pairs(streamer.buffer[-1][clientInterior]) do
                onEntityStream(j)
            end
        end
        streamer.cache.isCameraTranslated = false
    end, streamerSettings.syncRate, 0)
end)