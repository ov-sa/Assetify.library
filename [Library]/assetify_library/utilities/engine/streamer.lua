----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: streamer.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
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
streamer.private.allocator = {
    validStreams = {
        ["dummy"] = {},
        ["bone"] = {skipAttachment = true},
        ["light"] = {}
    }
}
streamer.private.buffer = {}
streamer.private.cache = {
    clientCamera = imports.getCamera()
}

function streamer.public:create(...)
    local cStreamer = self:createInstance()
    if cStreamer and not cStreamer:load(...) then
        cStreamer:destroyInstance()
        return false
    end
    return cStreamer
end

function streamer.public:destroy(...)
    if not streamer.public:isInstance(self) then return false end
    return self:unload(...)
end

function streamer.public:load(streamerInstance, streamType, occlusionInstances, syncRate)
    if not streamer.public:isInstance(self) then return false end
    if not streamerInstance or not streamType or not imports.isElement(streamerInstance) or not occlusionInstances or not occlusionInstances[1] or not imports.isElement(occlusionInstances[1]) then return false end
    local streamDimension, streamInterior = imports.getElementDimension(occlusionInstances[1]), imports.getElementInterior(occlusionInstances[1])
    self.streamer = streamerInstance
    self.streamType, self.occlusions = streamType, occlusionInstances
    self.dimension, self.interior = streamDimension, streamInterior
    self.syncRate = syncRate or settings.streamer.syncRate
    if streamerInstance ~= occlusionInstances[1] then
        if not streamer.private.allocator.validStreams[streamType] or not streamer.private.allocator.validStreams[streamType].skipAttachment then
            imports.attachElements(streamerInstance, occlusionInstances[1])
        end
        imports.setElementDimension(streamerInstance, streamDimension)
        imports.setElementInterior(streamerInstance, streamInterior)
    end
    streamer.private.buffer[streamDimension] = streamer.private.buffer[streamDimension] or {}
    streamer.private.buffer[streamDimension][streamInterior] = streamer.private.buffer[streamDimension][streamInterior] or {}
    streamer.private.buffer[streamDimension][streamInterior][streamType] = streamer.private.buffer[streamDimension][streamInterior][streamType] or {}
    streamer.private.buffer[streamDimension][streamInterior][streamType][self] = {isStreamed = false}
    self:allocate()
    return true
end

function streamer.public:unload()
    if not streamer.public:isInstance(self) then return false end
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
imports.addEventHandler("onClientElementDimensionChange", localPlayer, function(dimension) streamer.public:update(dimension) end)
imports.addEventHandler("onClientElementInteriorChange", localPlayer, function(interior) streamer.public:update(_, interior) end)

function streamer.public:allocate()
    if not streamer.public:isInstance(self) then return false end
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
                imports.addEventHandler("onClientPedsProcessed", root, streamer.private.onBoneUpdate)
            end
        else
            if not streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer or not timer:isInstance(streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer) then
                streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = timer:create(streamer.private.onBoneUpdate, self.syncRate, 0, self.syncRate, self.streamType)
            end
        end
        streamBuffer[self] = streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self]
    end
    return true
end

function streamer.public:deallocate()
    if not streamer.public:isInstance(self) then return false end
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
            if streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer then
                if self.syncRate <= 0 then
                    imports.removeEventHandler("onClientPedsProcessed", root, streamer.private.onBoneUpdate)
                else
                    streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer:destroy()
                end
            end
            streamer.private.allocator[(self.syncRate)][(self.streamType)].cTimer = nil
        end
    end
    return true
end

streamer.private.onEntityStream = function(streamBuffer)
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

streamer.private.onBoneStream = function(streamBuffer)
    if not streamBuffer then return false end
    for i, j in imports.pairs(streamBuffer) do
        if j and j.isStreamed then
            bone.update(bone.buffer.element[(i.streamer)])
        end
    end
    bone.cache.streamTick = imports.getTickCount()
    return true
end

streamer.private.onBoneUpdate = function(syncRate, streamType)
    local streamBuffer = (syncRate and streamType and streamer.private.allocator[syncRate][streamType]) or false
    streamBuffer = streamBuffer or (streamer.private.allocator[0] and streamer.private.allocator[0]["bone"]) or false
    local clientDimension, clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
    if streamBuffer and streamBuffer[clientDimension] and streamBuffer[clientDimension][clientInterior] then
        streamer.private.onBoneStream(streamBuffer[clientDimension][clientInterior])
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
                streamer.private.onEntityStream(j)
            end
        end
        if streamer.private.buffer[-1] and streamer.private.buffer[-1][clientInterior] then
            for i, j in imports.pairs(streamer.private.buffer[-1][clientInterior]) do
                streamer.private.onEntityStream(j)
            end
        end
        streamer.private.cache.isCameraTranslated = false
    end, settings.streamer.syncRate, 0)
end)