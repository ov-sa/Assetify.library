----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: utilities: mapper.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Mapper Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    split = split,
    gettok = gettok,
    tonumber = tonumber,
    tostring = tostring,
    tocolor = tocolor,
    isElement = isElement,
    destroyElement = destroyElement,
    setmetatable = setmetatable,
    addEvent = addEvent,
    addEventHandler = addEventHandler,
    getResourceRootElement = getResourceRootElement,
    triggerEvent = triggerEvent,
    triggerClientEvent = triggerClientEvent,
    getKeyState = getKeyState,
    getPedControlState = getPedControlState,
    setElementLocation = setElementLocation,
    getElementLocation = getElementLocation,
    setElementAlpha = setElementAlpha,
    engineRequestModel = engineRequestModel,
    engineLoadTXD = engineLoadTXD,
    engineLoadDFF = engineLoadDFF,
    engineLoadCOL = engineLoadCOL,
    engineImportTXD = engineImportTXD,
    engineReplaceModel = engineReplaceModel,
    engineReplaceCOL = engineReplaceCOL,
    engineSetModelLODDistance = engineSetModelLODDistance,
    engineApplyShaderToWorldTexture = engineApplyShaderToWorldTexture,
    createObject = createObject,
    setLowLODElement = setLowLODElement,
    attachElements = attachElements,
    setElementCollisionsEnabled = setElementCollisionsEnabled,
    isMouseClicked = isMouseClicked,
    isKeyOnHold = isKeyOnHold,
    toJSON = toJSON,
    fromJSON = fromJSON,
    string = string,
    Vector3 = Vector3,
    table = table,
    file = file,
    quat = quat,
    beautify = beautify
}


-----------------------
--[[ Class: Mapper ]]--
-----------------------

mapper = {
    assetPack = "weapon",
    cacheDirectoryPath = ":assetify_library/files/cache/",
    sceneDirectoryPath = ":assetify_library/files/assets/scene/",
    cacheManifestPath = ":assetify_library/files/cache/manifest.json",
    rwAssets = {},
    separators = {
        IPL = imports.string.byte(", ")
    }
}
mapper.__index = mapper

imports.addEvent("Assetify:Mapper:onLoadScene", true)

mapper.fetchSceneCache = function(sceneName)
    local isCacheExsting = false
    for i = 1, #mapper.rwAssets[(mapper.cacheManifestPath)], 1 do
        local j = mapper.rwAssets[(mapper.cacheManifestPath)][i]
        if j == sceneName then
            isCacheExsting = i
            break
        end
    end
    if isCacheExsting then
        return mapper.cacheDirectoryPath..sceneName.."/", isCacheExsting
    end
    return false
end

mapper.fetchSceneDirectory = function(sceneName)
    if not mapper.fetchSceneCache(sceneName) then return false end
    return mapper.sceneDirectoryPath..sceneName.."/"
end

if localPlayer then
    mapper.axis = {
        validAxesTypes = {"slate", "ring"},
        validLocationIndexes = {"posX", "posY", "posZ", "rotX", "rotY", "rotZ"},
        validAxes = {
            x = {color = {255, 0, 0}, rotation = {slate = {0, 0, 90}, ring = {0, 90, 0}}},
            y = {color = {0, 255, 0}, rotation = {slate = {0, 0, 0}, ring = {90, 0, 0}}},
            z = {color = {0, 0, 255}, rotation = {slate = {90, 0, 0}, ring = {0, 0, 0}}}
        }
    }
    mapper.cache = {keys = {}}
    mapper.buffer = {
        index = {},
        element = {}
    }
    mapper.rwAssets.dict = imports.engineLoadTXD("utilities/rw/axis/dict.rw")
    mapper.rwAssets.buffer = imports.engineLoadDFF("utilities/rw/axis/slate/buffer.rw")
    mapper.rwAssets.collision = imports.engineLoadCOL("utilities/rw/axis/slate/collision.rw")
    mapper.rwAssets.slate = imports.engineRequestModel("object", 16754)
    imports.engineImportTXD(mapper.rwAssets.dict, mapper.rwAssets.slate)
    imports.engineReplaceCOL(mapper.rwAssets.collision, mapper.rwAssets.slate)
    imports.engineReplaceModel(mapper.rwAssets.buffer, mapper.rwAssets.slate, true)
    imports.engineSetModelLODDistance(mapper.rwAssets.slate, 300)
    mapper.rwAssets.buffer = imports.engineLoadDFF("utilities/rw/axis/ring/buffer.rw")
    mapper.rwAssets.collision = imports.engineLoadCOL("utilities/rw/axis/ring/collision.rw")
    mapper.rwAssets.ring = imports.engineRequestModel("object", 16754)
    imports.engineImportTXD(mapper.rwAssets.dict, mapper.rwAssets.ring)
    imports.engineReplaceCOL(mapper.rwAssets.collision, mapper.rwAssets.ring)
    imports.engineReplaceModel(mapper.rwAssets.buffer, mapper.rwAssets.ring, true)
    imports.engineSetModelLODDistance(mapper.rwAssets.ring, 300)
    mapper.rwAssets.dict, mapper.rwAssets.buffer, mapper.rwAssets.collision = nil, nil, nil
    for i = 1, #mapper.axis.validAxesTypes, 1 do
        local j = mapper.axis.validAxesTypes[i]
        mapper.axis[j] = {}
        for k, v in imports.pairs(mapper.axis.validAxes) do
            mapper.axis[j][k] = {
                instance = imports.createObject(mapper.rwAssets[j], 0, 0, 0),
                LODInstance = imports.createObject(mapper.rwAssets[j], 0, 0, 0, 0, 0, 0, true),
                shader = imports.beautify.native.createShader(shaderRW["Assetify_AxisMapper"](), 10001, 0, false, "all")
            }
            imports.setLowLODElement(mapper.axis[j][k].instance, mapper.axis[j][k].LODInstance)
            imports.attachElements(mapper.axis[j][k].LODInstance, mapper.axis[j][k].instance)
            imports.beautify.native.setShaderValue(mapper.axis[j][k].shader, "baseColor", v.color[1], v.color[2], v.color[3], 255)
            imports.engineApplyShaderToWorldTexture(mapper.axis[j][k].shader, "assetify_axis", mapper.axis[j][k].instance)
            imports.engineApplyShaderToWorldTexture(mapper.axis[j][k].shader, "assetify_axis", mapper.axis[j][k].LODInstance)
        end
    end

    function mapper:create(...)
        local cMapper = imports.setmetatable({}, {__index = self})
        local cInstance = cMapper:load(...)
        if not cInstance then
            cMapper = nil
            return false
        end
        return cMapper, cInstance
    end

    function mapper:destroy(...)
        if not self or (self == mapper) then return false end
        return self:unload(...)
    end

    function mapper:reset()
        mapper.loadedScene = false
        mapper.isSpawningDummy = false
        mapper.isTargettingDummy = false
        for i, j in imports.pairs(mapper.buffer.element) do
            if i and imports.isElement(i) then
                imports.destroyElement(i)
            end
        end
        return true
    end

    function mapper:load(assetName, dummyData, retargetFocus)
        if not self or (self == mapper) then return false end
        local cDummy = assetify.createDummy(mapper.assetPack, assetName, false, false, dummyData)
        if not cDummy then return false end
        self.id = #mapper.buffer.index + 1
        self.element = cDummy
        self.assetName = assetName
        imports.table.insert(mapper.buffer.index, self)
        mapper.buffer.element[(self.element)] = self
        imports.beautify.gridlist.setRowData(mapper.ui.sceneWnd.propLst.element, imports.beautify.gridlist.addRow(mapper.ui.sceneWnd.propLst.element), 1, "#"..(self.id).."  ━━  "..(self.assetName))
        if retargetFocus then mapper.isTargettingDummy = self.element end
        return self.element
    end

    function mapper:unload()
        if not self or (self == mapper) then return false end
        for i = self.id + 1, #mapper.buffer.index, 1 do
            mapper.buffer.index[i].id = mapper.buffer.index[i].id - 1
        end
        imports.table.remove(mapper.buffer.index, self.id)
        mapper.buffer.element[(self.element)] = nil
        imports.beautify.gridlist.removeRow(mapper.ui.sceneWnd.propLst.element, self.id)
        self = nil
        return true
    end

    function mapper:enable(state)
        mapper.isEnabled = state
        mapper.ui.enable(mapper.isEnabled)
        return true
    end
    
    mapper.render = function(renderData)
        if renderData.renderType == "input" then
            mapper.cache.keys.mouse = imports.isMouseClicked()
            mapper.cache.keys.mouseLMBHold = (mapper.cache.keys.mouse ~= "mouse1") and imports.isKeyOnHold("mouse1")
        elseif renderData.renderType == "render" then
            mapper.ui.toolWnd.renderUI()
            mapper.ui.notif.renderUI()
            mapper.translationMode = (mapper.isTargettingDummy and (mapper.translationMode or {})) or false
            local translationIndex, isCursorTranslation = false, false
            if mapper.translationMode then
                mapper.translationMode.element = mapper.isTargettingDummy
                mapper.translationMode.type = mapper.translationMode.type or 1
                mapper.translationMode.axis = mapper.translationMode.axis or "x"
                mapper.translationMode.posX, mapper.translationMode.posY, mapper.translationMode.posZ, mapper.translationMode.rotX, mapper.translationMode.rotY, mapper.translationMode.rotZ = imports.getElementLocation(mapper.translationMode.element, "ZYX")
                if not CLIENT_MTA_WINDOW_ACTIVE then
                    local isSlateTranslation = mapper.axis.validAxesTypes[(mapper.translationMode.type)] == "slate"
                    translationIndex = ((mapper.translationMode.axis == "x") and ((isSlateTranslation and "posX") or "rotX")) or ((mapper.translationMode.axis == "y") and ((isSlateTranslation and "posY") or "rotY")) or ((mapper.translationMode.axis == "z") and ((isSlateTranslation and "posZ") or "rotZ")) or false
                    if translationIndex then
                        local translationSpeed, translationValue = (imports.getKeyState(availableControls.speedUp) and availableControlSpeeds.fast) or (imports.getKeyState(availableControls.speedDown) and availableControlSpeeds.slow) or availableControlSpeeds.normal, nil
                        if camera.isCursorVisible then
                            if mapper.cache.keys.mouseLMBHold then
                                isCursorTranslation = true
                                translationValue = CLIENT_CURSOR_OFFSET[2]
                                mapper.cache.prevCursorY = mapper.cache.prevCursorY or translationValue
                                translationValue = translationValue - mapper.cache.prevCursorY
                                if isSlateTranslation then
                                    translationValue = translationValue*CLIENT_MTA_RESOLUTION[2]*0.75
                                else
                                    translationValue = (translationValue*360)%360
                                end
                            end                            
                        end
                        local __translationIndex = "__"..translationIndex
                        if not isCursorTranslation then
                            translationValue = ((imports.getKeyState(availableControls.valueUp) and translationSpeed) or (imports.getKeyState(availableControls.valueDown) and -translationSpeed) or 0)
                            if isSlateTranslation then
                                translationValue = translationValue*0.75
                                mapper.translationMode[translationIndex] = mapper.translationMode[translationIndex] + translationValue
                            else
                                mapper.translationMode[translationIndex] = translationValue
                            end
                            mapper.translationMode[__translationIndex] = nil
                        else
                            local __translationIndex = "__"..translationIndex
                            mapper.translationMode[__translationIndex] = mapper.translationMode[__translationIndex] or {
                                native = mapper.translationMode[translationIndex]
                            }
                            if mapper.translationMode[__translationIndex].speed ~= translationSpeed then
                                mapper.translationMode[__translationIndex].speed = translationSpeed
                                mapper.translationMode[__translationIndex].previous = mapper.translationMode[__translationIndex].current or 0
                                mapper.translationMode[__translationIndex].offset = translationValue
                            end
                            mapper.translationMode[__translationIndex].__current = mapper.translationMode[__translationIndex].current or 0
                            mapper.translationMode[__translationIndex].current = mapper.translationMode[__translationIndex].previous + (translationValue - mapper.translationMode[__translationIndex].offset)*translationSpeed
                            if isSlateTranslation then
                                mapper.translationMode[translationIndex] = mapper.translationMode[__translationIndex].native + mapper.translationMode[__translationIndex].current
                            else
                                mapper.translationMode[translationIndex] = mapper.translationMode[__translationIndex].current - mapper.translationMode[__translationIndex].__current
                            end
                        end
                        if not isSlateTranslation then
                            local translationValues = {}
                            for i = 4, #mapper.axis.validLocationIndexes, 1 do
                                local j = mapper.axis.validLocationIndexes[i]
                                if translationIndex == j then
                                    translationValues[j] = mapper.translationMode[j]
                                else
                                    translationValues[j] = 0
                                end
                            end
                            local _, _, _, __rotX, __rotY, __rotZ = imports.getElementLocation(mapper.translationMode.element, "ZYX")
                            local rotQuat = imports.quat.new(imports.quat.fromEuler(__rotX, __rotY, __rotZ))
                            local __rotQuat = imports.quat.fromVectorAngle(imports.Vector3(1, 0, 0), translationValues.rotX)*imports.quat.fromVectorAngle(imports.Vector3(0, 1, 0), translationValues.rotY)*imports.quat.fromVectorAngle(imports.Vector3(0, 0, 1), translationValues.rotZ) 
                            rotQuat = __rotQuat*rotQuat
                            mapper.translationMode.rotX, mapper.translationMode.rotY, mapper.translationMode.rotZ = imports.quat.toEuler(rotQuat[1], rotQuat[2], rotQuat[3], rotQuat[4])
                        end
                        imports.setElementLocation(mapper.translationMode.element, mapper.translationMode.posX, mapper.translationMode.posY, mapper.translationMode.posZ, mapper.translationMode.rotX, mapper.translationMode.rotY, mapper.translationMode.rotZ, "ZYX")
                    end
                end
            end
            for i = 1, #mapper.axis.validAxesTypes, 1 do
                local j = mapper.axis.validAxesTypes[i]
                local typeAlpha = (not mapper.translationMode and 0) or ((mapper.axis.validAxesTypes[(mapper.translationMode.type)] ~= j) and 0) or nil
                for k, v in imports.pairs(mapper.axis.validAxes) do
                    local axisAlpha = typeAlpha or ((mapper.translationMode.axis == k) and 100) or 10
                    local isCollisionEnabled = axisAlpha > 0
                    if mapper.translationMode then
                        imports.setElementLocation(mapper.axis[j][k].instance, mapper.translationMode.posX, mapper.translationMode.posY, mapper.translationMode.posZ, v.rotation[j][1], v.rotation[j][2], v.rotation[j][3])
                    end
                    imports.setElementAlpha(mapper.axis[j][k].instance, axisAlpha)
                    imports.setElementAlpha(mapper.axis[j][k].LODInstance, axisAlpha)
                    imports.setElementCollisionsEnabled(mapper.axis[j][k].instance, isCollisionEnabled)
                    imports.setElementCollisionsEnabled(mapper.axis[j][k].LODInstance, isCollisionEnabled)
                end
            end
            mapper.cache.prevCursorY = (isCursorTranslation and mapper.cache.prevCursorY) or false
            if mapper.translationMode and not translationIndex then
                for i = 1, #mapper.axis.validLocationIndexes, 1 do
                    local j = mapper.axis.validLocationIndexes[i]
                    mapper.translationMode[("__"..j)] = nil
                end
            end
        end
    end

    mapper.controlKey = function(button, state)
        if CLIENT_MTA_WINDOW_ACTIVE or state then return false end
        if button == availableControls.switchTranslation then
            local selectedMode = mapper.translationMode.type + 1
            mapper.translationMode.type = (mapper.axis.validAxesTypes[selectedMode] and selectedMode) or 1
        elseif button == availableControls.switchAxis then
            if mapper.translationMode then
                local selectedAxis, validAxes = 0, {}
                for i, j in imports.pairs(mapper.axis.validAxes) do
                    imports.table.insert(validAxes, i)
                    if mapper.translationMode.axis == i then
                        selectedAxis = #validAxes
                    end
                end
                mapper.translationMode.axis = validAxes[(selectedAxis + 1)] or validAxes[1]
            end
        elseif button == availableControls.cloneObject then
            if mapper.isTargettingDummy then
                local posX, posY, posZ, rotX, rotY, rotZ = imports.getElementLocation(mapper.isTargettingDummy)
                if mapper:create(mapper.buffer.element[(mapper.isTargettingDummy)].assetName, {
                    position = {x = posX, y = posY, z = posZ},
                    rotation = {x = rotX, y = rotY, z = rotZ}
                }, true) then
                    imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Prop succesfully cloned. ["..(mapper.buffer.element[(mapper.isTargettingDummy)].assetName).."]", availableColors.success)
                end
            end
        elseif button == availableControls.deleteObject then
            if mapper.isTargettingDummy then
                local assetName = mapper.buffer.element[(mapper.isTargettingDummy)].assetName
                imports.destroyElement(mapper.isTargettingDummy)
                imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Prop succesfully destroyed. ["..assetName.."]", availableColors.success)
            end
        end
    end

    mapper.controlClick = function(button, state, _, _, worldX, worldY, worldZ, targetElement)
        if state == "down" then return false end
        if button == "left" then
            if mapper.isSpawningDummy then
                if not mapper.isSpawningDummy.isScheduled then
                    mapper.isSpawningDummy.isScheduled = true
                    mapper.isTargettingDummy = false
                else
                    if mapper:create(mapper.isSpawningDummy.assetName, {
                        position = {x = worldX, y = worldY, z = worldZ},
                        rotation = {x = 0, y = 0, z = 0}
                    }, true) then
                        imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Prop succesfully spawned. ["..(mapper.isSpawningDummy.assetName).."]", availableColors.success)
                    end
                    mapper.isSpawningDummy = false
                end
            else
                local isAxisClicked = false
                mapper.clickTick = CLIENT_CURRENT_TICK
                if mapper.translationMode then
                    for i = 1, #mapper.axis.validAxesTypes, 1 do
                        local j = mapper.axis.validAxesTypes[i]
                        for k, v in imports.pairs(mapper.axis.validAxes) do
                            if (targetElement == mapper.axis[j][k].instance) or (targetElement == mapper.axis[j][k].LODInstance) then
                                isAxisClicked = true
                                mapper.translationMode.axis = k
                                break
                            end
                        end
                        if isAxisClicked then break end
                    end
                end
                if not isAxisClicked then
                    mapper.isTargettingDummy = (targetElement and mapper.buffer.element[targetElement] and targetElement) or false
                end
            end
        end
    end

    imports.addEventHandler("Assetify:Mapper:onLoadScene", root, function(sceneName, sceneData)
        local sceneCache, sceneIndex = mapper.fetchSceneCache(sceneName)
        if not sceneData then
            mapper.loadedScene = sceneIndex
        else
            local sceneIPLPath = sceneCache.."scene.ipl"
            if sceneData.ipl then
                mapper:reset()
                mapper:enable(false)
                mapper.loadedScene = sceneIndex
                thread:create(function(cThread)
                    imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Scene loading; Kindly wait... ["..sceneIPLPath.."]", availableColors.info)
                    local unparsedDatas = imports.split(sceneData.ipl, "\n")
                    for i = 1, #unparsedDatas, 1 do
                        local assetName = imports.string.gsub(imports.tostring(imports.gettok(unparsedDatas[i], 2, mapper.separators.IPL)), " ", "")
                        local posX, posY, posZ = imports.tonumber(imports.gettok(unparsedDatas[i], 4, mapper.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 5, mapper.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 6, mapper.separators.IPL))
                        local rotX, rotY, rotZ = imports.quat.toEuler(imports.tonumber(imports.gettok(unparsedDatas[i], 10, mapper.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 7, mapper.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 8, mapper.separators.IPL)), imports.tonumber(imports.gettok(unparsedDatas[i], 9, mapper.separators.IPL)))
                        mapper:create(assetName, {
                            position = {x = posX, y = posY, z = posZ},
                            rotation = {x = rotX, y = rotY, z = rotZ}
                        })
                        thread.pause()
                    end
                    mapper:enable(true)
                    imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Scene successfully loaded. ["..sceneIPLPath.."]", availableColors.success)
                end):resume({
                    executions = downloadSettings.buildRate,
                    frames = 1
                })
            else
                imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Scene failed to load. (Corrupted IPL) ["..sceneIPLPath.."]", availableColors.error)
            end
        end
    end)

    imports.addEvent("Assetify:Mapper:onRecieveCacheManifest", true)
    imports.addEventHandler("Assetify:Mapper:onRecieveCacheManifest", root, function(manifestData)
        local preLoadedScene = mapper.loadedScene and mapper.rwAssets[(mapper.cacheManifestPath)][(mapper.loadedScene)]
        mapper.rwAssets[(mapper.cacheManifestPath)] = manifestData
        mapper.ui.sceneListWnd.refreshUI()
        if preLoadedScene and not mapper.fetchSceneCache(preLoadedScene) then mapper:reset() end
    end)

    imports.addEventHandler("onClientElementDestroy", root, function()
        if mapper.isLibraryStopping or not mapper.buffer.element[source] then return false end
        if mapper.isTargettingDummy == source then mapper.isTargettingDummy = false end
        mapper.buffer.element[source]:destroy()
    end)
else
    mapper.rwAssets[(mapper.cacheManifestPath)] = imports.file.read(mapper.cacheManifestPath)
    mapper.rwAssets[(mapper.cacheManifestPath)] = (mapper.rwAssets[(mapper.cacheManifestPath)] and imports.fromJSON(mapper.rwAssets[(mapper.cacheManifestPath)])) or {}
    imports.addEvent("Assetify:Mapper:onSaveScene", true)
    imports.addEvent("Assetify:Mapper:onDeleteScene", true)
    imports.addEvent("Assetify:Mapper:onGenerateScene", true)

    mapper.syncCacheManifest = function(player)
        return imports.triggerClientEvent(player, "Assetify:Mapper:onRecieveCacheManifest", player, mapper.rwAssets[(mapper.cacheManifestPath)])
    end

    mapper.loadScene = function(player, sceneName, isActive)
        local sceneCache = mapper.fetchSceneCache(sceneName)
        if not sceneCache then return false end
        local sceneData = false
        if not isActive then
            sceneData = {
                ipl = imports.file.read(sceneCache.."scene.ipl")
            }
        end
        imports.triggerClientEvent(player, "Assetify:Mapper:onLoadScene", player, sceneName, sceneData)
        return true
    end

    imports.addEventHandler("Assetify:Mapper:onLoadScene", root, function(sceneName)
        if not mapper.loadScene(source, sceneName) then
            imports.triggerClientEvent(source, "Assetify:Mapper:onLoadScene", source, "Scene failed to load. ["..sceneName.."]", availableColors.error)
        end
    end)

    imports.addEventHandler("Assetify:Mapper:onSaveScene", root, function(sceneName, sceneIPL)
        local sceneCache = false
        if sceneName then
            sceneCache = mapper.fetchSceneCache(sceneName)
            if not sceneCache then return false end
        else
            sceneName, isNameValidated = #mapper.rwAssets[(mapper.cacheManifestPath)] + 1, false
            while (not isNameValidated) do
                if not mapper.fetchSceneCache(sceneName) then
                    isNameValidated = true
                else
                    sceneName = sceneName + 1
                end
            end
            sceneName = imports.tostring(sceneName)
            imports.table.insert(mapper.rwAssets[(mapper.cacheManifestPath)], sceneName)
            imports.file.write(mapper.cacheManifestPath, imports.toJSON(mapper.rwAssets[(mapper.cacheManifestPath)]))
            mapper.syncCacheManifest(source)
            mapper.loadScene(source, sceneName, true)
            sceneCache = mapper.fetchSceneCache(sceneName)
        end
        local sceneIPLPath = sceneCache.."scene.ipl"
        imports.file.write(sceneIPLPath, sceneIPL)
        imports.triggerClientEvent(source, "Assetify:Mapper:onNotification", source, "Scene successfully saved. ["..sceneIPLPath.."]", availableColors.success)
    end)

    imports.addEventHandler("Assetify:Mapper:onDeleteScene", root, function(sceneName)
        local sceneCache, sceneIndex = mapper.fetchSceneCache(sceneName)
        if not sceneCache then return false end
        imports.table.remove(mapper.rwAssets[(mapper.cacheManifestPath)], sceneIndex)
        imports.file.write(mapper.cacheManifestPath, imports.toJSON(mapper.rwAssets[(mapper.cacheManifestPath)]))
        local sceneIPLPath = sceneCache.."scene.ipl"
        if imports.file.exists(sceneIPLPath) then
            imports.file.delete(sceneIPLPath)
        end
        mapper.syncCacheManifest(source)
        imports.triggerClientEvent(source, "Assetify:Mapper:onNotification", source, "Scene successfully deleted. ["..sceneIPLPath.."]", availableColors.success)
    end)

    imports.addEventHandler("Assetify:Mapper:onGenerateScene", root, function(sceneName)
        local sceneDirectory = mapper.fetchSceneDirectory(sceneName)
        if not sceneDirectory then return false end
        local sceneCache = mapper.fetchSceneCache(sceneName)
        local sceneIPL = imports.file.read(sceneCache.."scene.ipl")
        if sceneIPL then
            imports.file.write(sceneDirectory.."scene.ipl", sceneIPL)
            imports.triggerClientEvent(source, "Assetify:Mapper:onNotification", source, "Scene successfully generated. ["..sceneDirectory.."]", availableColors.success)
        end
    end)

    imports.addEventHandler("onPlayerResourceStart", root, function(resourceElement)
        if imports.getResourceRootElement(resourceElement) == resourceRoot then
            mapper.syncCacheManifest(source)
        end
    end)
end