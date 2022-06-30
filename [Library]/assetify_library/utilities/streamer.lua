----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: streamer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Streamer Utilities ]]--
----------------------------------------------------------------


--TODO: UPDATE
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
    getTickCount = getTickCount,
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

local streamer = class:create("streamer")
streamer.private.buffer = {}
streamer.private.cache = {
    clientCamera = imports.getCamera()
}
streamer.private.allocator = {
    validStreams = {"dummy", "bone", "light"}
}
streamer.private.allocator.__validStreams = {}
for i = 1, #streamer.private.allocator.validStreams, 1 do
    local j = streamer.private.allocator.validStreams[i]
    streamer.private.allocator.__validStreams[j] = true
end
streamer.private.allocator.validStreams = streamer.private.allocator.__validStreams
streamer.private.allocator.__validStreams = nil
local onEntityStream, onBoneStream, onBoneUpdate = nil, nil, nil

function streamer.public:create(...)
    local cStreamer = self:createInstance()
    if cStreamer and not cStreamer:load(...) then
        cStreamer:destroyInstance()
        return false
    end
    return cStreamer
end

function streamer.public:destroy(...)
    if not self or (self == streamer.public) then return false end
    return self:unload(...)
end

function streamer.public:load(streamerInstance, streamType, occlusionInstances, syncRate)
    if not self or (self == streamer.public) then return false end
    if not streamerInstance or not streamType or not imports.isElement(streamerInstance) or not occlusionInstances or not occlusionInstances[1] or not imports.isElement(occlusionInstances[1]) then return false end
    local streamDimension, streamInterior = imports.getElementDimension(occlusionInstances[1]), imports.getElementInterior(occlusionInstances[1])
    self.streamer = streamerInstance
    self.streamType = streamType
    self.occlusions = occlusionInstances
    self.dimension = streamDimension
    self.interior = streamInterior
    self.syncRate = syncRate or settings.streamer.syncRate
    if streamerInstance ~= occlusionInstances[1] then
        if streamType ~= "bone" then
            imports.attachElements(streamerInstance, occlusionInstances[1])
        end
        imports.setElementDimension(streamerInstance, streamDimension)
        imports.setElementInterior(streamerInstance, streamInterior)
    end
    streamer.private.buffer[streamDimension] = streamer.private.buffer[streamDimension] or {}
    streamer.private.buffer[streamDimension][streamInterior] = streamer.private.buffer[streamDimension][streamInterior] or {}
    streamer.private.buffer[streamDimension][streamInterior][streamType] = streamer.private.buffer[streamDimension][streamInterior][streamType] or {}
    streamer.private.buffer[streamDimension][streamInterior][streamType][self] = {
        isStreamed = false
    }
    self:allocate()
    return true
end

function streamer.public:unload()
    if not self or (self == streamer.public) or self.isUnloading then return false end
    self.isUnloading = true
    local streamType = self.streamType
    local streamDimension, streamInterior = imports.getElementDimension(self.occlusions[1]), imports.getElementInterior(self.occlusions[1])
    streamer.private.buffer[streamDimension][streamInterior][streamType][self] = nil
    self:deallocate()
    self:destroyInstance()
    return true
end

function streamer.public:update(clientDimension, clientInterior)
    if not clientDimension and not clientInterior then return false end
    local currentDimension, currentInterior = imports.getElementDimension(localPlayer), imports.getElementInterior(localPlayer)
    clientDimension, clientInterior = clientDimension or _clientDimension, clientInterior or clientInterior
    if streamer.public.waterBuffer then
        imports.setElementDimension(streamer.public.waterBuffer, currentDimension)
        imports.setElementInterior(streamer.public.waterBuffer, currentInterior)
    end
    if streamer.private.buffer[clientDimension] and streamer.private.buffer[clientDimension][clientInterior] then
        for i, j in imports.pairs(streamer.private.buffer[clientDimension][clientInterior]) do
            if j then
                imports.setElementDimension(i.streamer.public, settings.streamer.unsyncDimension)
            end
        end
    end
    streamer.private.cache.isCameraTranslated = true
    streamer.private.cache.clientWorld = streamer.private.cache.clientWorld or {}
    streamer.private.cache.clientWorld.dimension = currentDimension
    streamer.private.cache.clientWorld.interior = currentInterior
    return true
end

function streamer.public:allocate()
    if not self or (self == streamer.public) then return false end
    if not streamer.private.allocator.validStreams[(self.streamType)] then return false end
    streamer.private.allocator[(self.syncRate)] = streamer.private.allocator[(self.syncRate)] or {}
    streamer.private.allocator[(self.syncRate)][(self.streamType)] = streamer.private.allocator[(self.syncRate)][(self.streamType)] or {}
    streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] = streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or {}
    streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] = streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] or {}
    local streamBuffer = streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)]
    if self.streamType == "bone" then
        if self.syncRate <= 0 then
            if not streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer then
                streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = true
                imports.addEventHandler("onClientPedsProcessed", root, onBoneUpdate)
            end
        else
            if not streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer or not timer:isInstance(streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer) then
                streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = timer:create(onBoneUpdate, self.syncRate, 0, self.syncRate, self.streamType)
            end
        end
        streamBuffer[self] = streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self]
    end
    return true
end

function streamer.public:deallocate()
    if not self or (self == streamer.public) then return false end
    if not streamer.private.allocator.validStreams[(self.streamType)] then return false end
    if not streamer.private.allocator[(self.syncRate)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] then return false end
    local isAllocatorVoid = true
    streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)][self] = nil
    for i, j in imports.pairs(streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)]) do
        isAllocatorVoid = false
        break
    end
    if isAllocatorVoid then
        if self.streamType == "bone" then
            if self.syncRate <= 0 then
                if streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer then
                    imports.removeEventHandler("onClientPedsProcessed", root, onBoneUpdate)
                    streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = nil
                end
            else
                if streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer then
                    streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer:destroyInstance()
                    streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = nil
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
            imports.setElementDimension(i.streamer, (j.isStreamed and streamer.private.cache.clientWorld.dimension) or settings.streamer.unsyncDimension)
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

onBoneUpdate = function(syncRate, streamType)
    local streamBuffer = (syncRate and streamType and streamer.private.allocator[syncRate][streamType]) or false
    streamBuffer = streamBuffer or (streamer.private.allocator[0] and streamer.private.allocator[0]["bone"]) or false
    local clientDimension, clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
    if streamBuffer and streamBuffer[clientDimension] and streamBuffer[clientDimension][clientInterior] then
        onBoneStream(streamBuffer[clientDimension][clientInterior])
    end
    return true
end

network:fetch("Assetify:onLoad"):on(function()
    streamer.public:update(imports.getElementDimension(localPlayer))
    timer:create(function()
        if streamer.private.cache.isCameraTranslated then return false end
        local velX, velY, velZ = imports.getElementVelocity(streamer.private.cache.clientCamera)
        streamer.private.cache.isCameraTranslated = ((velX ~= 0) and true) or ((velY ~= 0) and true) or ((velZ ~= 0) and true) or false
    end, settings.streamer.cameraSyncRate, 0)
    timer:create(function()
        if not streamer.private.cache.isCameraTranslated then return false end
        local clientDimension, clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
        if streamer.private.buffer[clientDimension] and streamer.private.buffer[clientDimension][clientInterior] then
            for i, j in imports.pairs(streamer.private.buffer[clientDimension][clientInterior]) do
                onEntityStream(j)
            end
        end
        if streamer.private.buffer[-1] and streamer.private.buffer[-1][clientInterior] then
            for i, j in imports.pairs(streamer.private.buffer[-1][clientInterior]) do
                onEntityStream(j)
            end
        end
        streamer.private.cache.isCameraTranslated = false
    end, settings.streamer.syncRate, 0)
end)