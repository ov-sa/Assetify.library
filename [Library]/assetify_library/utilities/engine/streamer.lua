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
    tonumber = tonumber,
    getCamera = getCamera,
    isElement = isElement,
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    getTickCount = getTickCount,
    isElementOnScreen = isElementOnScreen,
    getElementCollisionsEnabled = getElementCollisionsEnabled,
    setElementCollisionsEnabled = setElementCollisionsEnabled,
    getElementPosition = getElementPosition,
    getElementDimension = getElementDimension,
    setElementDimension = setElementDimension,
    getElementInterior = getElementInterior,
    setElementInterior = setElementInterior,
    getElementVelocity = getElementVelocity
}


-------------------------
--[[ Class: Streamer ]]--
-------------------------

local streamer = class:create("streamer")
streamer.private.allocator = {
    validStreams = {
        ["dummy"] = {desyncOccclusionsOnPause = true},
        ["bone"] = {skipAttachment = true, dynamicStreamAllocation = true},
        ["light"] = {desyncOccclusionsOnPause = true}
    }
}
streamer.private.ref = {}
streamer.private.buffer = {}
streamer.private.cache = {
    clientCamera = getCamera()
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
    self.streamer, self.isStreamerCollidable = streamerInstance, imports.getElementCollisionsEnabled(streamerInstance)
    self.streamType, self.occlusions = streamType, occlusionInstances
    self.dimension, self.interior = imports.getElementDimension(occlusionInstances[1]), imports.getElementInterior(occlusionInstances[1])
    self.syncRate = settings.streamer.streamRate
    self:resume()
    return true
end

function streamer.public:unload()
    if not streamer.public:isInstance(self) then return false end
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self] = nil
    self:pause()
    self:destroyInstance()
    return true
end

function streamer.public:resume()
    if not streamer.public:isInstance(self) or self.isResumed then return false end
    if self.streamer ~= self.occlusions[1] then
        if not streamer.private.allocator.validStreams[(self.streamType)] or not streamer.private.allocator.validStreams[(self.streamType)].skipAttachment then
            attacher:attachElements(self.streamer, self.occlusions[1])
        end
        imports.setElementDimension(self.streamer, self.dimension)
        imports.setElementInterior(self.streamer, self.interior)
    end
    for i = 1, #self.occlusions do
        local j = self.occlusions[i]
        streamer.private.ref[j] = streamer.private.ref[j] or {}
        streamer.private.ref[j][self] = true
        if streamer.private.allocator.validStreams[(self.streamType)] and streamer.private.allocator.validStreams[(self.streamType)].desyncOccclusionsOnPause then
            imports.setElementDimension(j, self.dimension)
        end
    end
    self.isResumed = true
    imports.setElementCollisionsEnabled(self.streamer, self.isStreamerCollidable)
    streamer.private.buffer[(self.dimension)] = streamer.private.buffer[(self.dimension)] or {}
    streamer.private.buffer[(self.dimension)][(self.interior)] = streamer.private.buffer[(self.dimension)][(self.interior)] or {}
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)] = streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)] or {}
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self] = true
    self:allocate()
    return true
end

function streamer.public:pause()
    if not streamer.public:isInstance(self) or not self.isResumed then return false end
    self:deallocate()
    self.isResumed = false
    streamer.private.buffer[(self.dimension)][(self.interior)][(self.streamType)][self] = nil
    if self.streamer ~= self.occlusions[1] then
        if not streamer.private.allocator.validStreams[(self.streamType)] or not streamer.private.allocator.validStreams[(self.streamType)].skipAttachment then
            attacher:detachElements(self.streamer)
        end
        imports.setElementDimension(self.streamer, settings.streamer.unsyncDimension)
    end
    for i = 1, #self.occlusions do
        local j = self.occlusions[i]
        streamer.private.ref[j][self] = nil
        if streamer.private.allocator.validStreams[(self.streamType)] and streamer.private.allocator.validStreams[(self.streamType)].desyncOccclusionsOnPause then
            imports.setElementDimension(j, settings.streamer.unsyncDimension)
        end
    end
    return true
end

function streamer.private:update(destreamBuffer)
    if destreamBuffer then
        for i, j in imports.pairs(destreamBuffer) do
            if j then
                for k, v in imports.pairs(j) do
                    if k then
                        k.isStreamed = nil
                        imports.setElementDimension(k.streamer, settings.streamer.unsyncDimension)
                    end
                end
            end
        end
        return true
    end
    local clientDimension, clientInterior = imports.getElementDimension(localPlayer), imports.getElementInterior(localPlayer)
    if streamer.public.waterBuffer then
        imports.setElementDimension(streamer.public.waterBuffer, clientDimension)
        imports.setElementInterior(streamer.public.waterBuffer, clientInterior)
    end
    if streamer.private.cache.clientWorld then
        local __clientDimension, __clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
        if (__clientDimension ~= -1) and streamer.private.buffer[__clientDimension] and streamer.private.buffer[__clientDimension][__clientInterior] then
            streamer.private:update(streamer.private.buffer[__clientDimension][__clientInterior])
        end
        if streamer.private.buffer[-1] then
            if (__clientInterior ~= clientInterior) and streamer.private.buffer[-1][__clientInterior] then streamer.private:update(streamer.private.buffer[-1][__clientInterior]) end
            if streamer.private.buffer[-1][clientInterior] then streamer.private.buffer[-1][clientInterior].isForcedUpdate = true end
        end
    end
    streamer.private.cache.isCameraTranslated = true
    streamer.private.cache.clientWorld = streamer.private.cache.clientWorld or {}
    streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior = clientDimension, clientInterior
    return true
end

function streamer.public:allocate()
    if not streamer.public:isInstance(self) or not self.isResumed or self.isAllocated then return false end
    if not streamer.private.allocator.validStreams[(self.streamType)] then return false end
    self.isAllocated = true
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
    if not streamer.public:isInstance(self) or not self.isResumed or not self.isAllocated then return false end
    if not streamer.private.allocator.validStreams[(self.streamType)] then return false end
    if not streamer.private.allocator[(self.syncRate)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)] or not streamer.private.allocator[(self.syncRate)][(self.streamType)][(self.dimension)][(self.interior)] then return false end
    local isAllocatorVoid = true
    self.isAllocated = false
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

streamer.private.onEntityStream = function(streamBuffer, isStreamAltered)
    if not streamBuffer then return false end
    for i, j in imports.pairs(streamBuffer) do
        if j then
            local isStreamed = false
            for k = 1, #i.occlusions, 1 do
                local v = i.occlusions[k]
                if imports.isElementOnScreen(v) then
                    isStreamed = true
                    break
                end
            end
            isStreamAltered = isStreamAltered or (isStreamed ~= i.isStreamed)
            if isStreamAltered then imports.setElementDimension(i.streamer, (isStreamed and i.dimension) or settings.streamer.unsyncDimension) end
            if streamer.private.allocator.validStreams[(i.streamType)] and streamer.private.allocator.validStreams[(i.streamType)].dynamicStreamAllocation then
                if not isStreamed then
                    if isStreamAltered then
                        i:deallocate()
                    end
                else
                    local viewDistance = math.findDistance3D(streamer.private.cache.cameraLocation.x, streamer.private.cache.cameraLocation.y, streamer.private.cache.cameraLocation.z, imports.getElementPosition(i.streamer)) - settings.streamer.streamDelimiter[1]
                    local syncRate = ((viewDistance <= 0) and 0) or math.min(settings.streamer.streamRate, math.round(((viewDistance/settings.streamer.streamDelimiter[2])*settings.streamer.streamRate)/settings.streamer.streamDelimiter[3])*settings.streamer.streamDelimiter[3])
                    if syncRate ~= i.syncRate then
                        i:deallocate()
                        i.syncRate = syncRate
                        i:allocate()
                    end
                end
            end
            i.isStreamed = isStreamed
        end
        if settings.streamer.syncCoolDownRate then streamer.private.cache.clientThread:sleep(settings.streamer.syncCoolDownRate) end
    end
    return true
end

streamer.private.onBoneStream = function(streamBuffer)
    if not streamBuffer then return false end
    attacher.bone.cache.streamTick = imports.getTickCount()
    for i, j in imports.pairs(streamBuffer) do
        if j and i.isStreamed then
            attacher.bone.update(attacher.bone.buffer.element[(i.streamer)])
        end
    end
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
    streamer.private:update()
    thread:createHeartbeat(function()
        if not streamer.private.cache.isCameraTranslated then
            local velX, velY, velZ = imports.getElementVelocity(streamer.private.cache.clientCamera)
            streamer.private.cache.isCameraTranslated = ((velX ~= 0) and true) or ((velY ~= 0) and true) or ((velZ ~= 0) and true) or false
        end
        return true
    end, function() end, settings.streamer.cameraRate)

    streamer.private.cache.clientThread = thread:createHeartbeat(function()
        if streamer.private.cache.isCameraTranslated then
            streamer.private.cache.cameraLocation = streamer.private.cache.cameraLocation or {}
            streamer.private.cache.cameraLocation.x, streamer.private.cache.cameraLocation.y, streamer.private.cache.cameraLocation.z = imports.getElementPosition(streamer.private.cache.clientCamera)
            local clientDimension, clientInterior = streamer.private.cache.clientWorld.dimension, streamer.private.cache.clientWorld.interior
            if streamer.private.buffer[clientDimension] and streamer.private.buffer[clientDimension][clientInterior] then
                for i, j in imports.pairs(streamer.private.buffer[clientDimension][clientInterior]) do
                    streamer.private.onEntityStream(j)
                end
            end
            if streamer.private.buffer[-1] and streamer.private.buffer[-1][clientInterior] then
                local isForcedUpdate = streamer.private.buffer[-1][clientInterior].isForcedUpdate
                streamer.private.buffer[-1][clientInterior].isForcedUpdate = nil
                for i, j in imports.pairs(streamer.private.buffer[-1][clientInterior]) do
                    streamer.private.onEntityStream(j, isForcedUpdate)
                end
            end
            streamer.private.cache.isCameraTranslated = false
        end
        return true
    end, function() end, settings.streamer.syncRate)
end)


---------------------
--[[ API Syncers ]]--
---------------------

imports.addEventHandler("onClientElementDimensionChange", localPlayer, function(dimension) streamer.private:update() end)
imports.addEventHandler("onClientElementInteriorChange", localPlayer, function(interior) streamer.private:update() end)