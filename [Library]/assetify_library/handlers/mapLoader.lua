----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: handlers: mapLoader.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Map Loader ]]--
----------------------------------------------------------------


-------------------
--[[ Variables ]]--
-------------------

local resourceImports = {
    primitiveLight = exports.dl_primitive3dlight:getDLExports()
}
local loadedClientMap = {
    mapData = false,
    modelIDs = {},
    models = {txd = {}, dff = {}, col = {}},
    objects = {}
}


----------------------------------------
--[[ Function: Retrieves Loaded Map ]]--
----------------------------------------

function _getLoadedMap()

    if not loadedClientMap.mapData then return false end

    return loadedClientMap.mapData

end


--------------------------------------
--[[ Functions: Unloads/Loads Map ]]--
--------------------------------------

function _unloadMap()

    if not loadedClientMap.mapData then return false end

    for i, j in ipairs(loadedClientMap.objects) do
        if j and isElement(j) then
            j:destroy()
        end
    end
    for i, j in pairs(loadedClientMap.models) do
        for k, v in ipairs(j) do
            if v and isElement(v) then
                v:destroy()
            end
        end
        j = {}
    end
    for i, j in ipairs(loadedClientMap.modelIDs) do
        engineFreeModel(j)
    end
    loadedClientMap.modelIDs = {}
    loadedClientMap.objects = {}
    loadedClientMap.mapData = false
    return true

end

local function syncMapWeather()

    if not loadedClientMap.mapData then return false end

    --setWeather(loadedClientMap.mapData.mapWeather)
    --setTime(loadedClientMap.mapData.mapTime[1], loadedClientMap.mapData.mapTime[2])
    return true

end
Timer(syncMapWeather, 30000, 0)

function _loadMap(mapType, mapDimension)

    mapDimension = tonumber(mapDimension)
    if not mapType or not serverMaps[mapType] or not mapDimension or mapDimension < 0 then return false end
    if loadedClientMap.mapData and (loadedClientMap.mapData.mapType == mapType) and (loadedClientMap.mapData.mapDimension == mapDimension) then return false end

    unloadMap()
    loadedClientMap.mapData = {
        mapType = mapType,
        mapDimension = mapDimension,
        mapWeather = serverMaps[mapType].mapWeather,
        mapTime = serverMaps[mapType].mapTime
    }
    syncMapWeather()
    local mapTXDPath = ":mod_loader/files/maps/"..mapType.."/"..(serverMaps[mapType].objects.txdPath)
    if mapTXDPath and File.exists(mapTXDPath) then
        if not loadedClientMap.models.txd[mapTXDPath] then
            loadedClientMap.models.txd[mapTXDPath] = EngineTXD(mapTXDPath)
        end
    end
    for i, j in pairs(serverMaps[mapType].lights) do
        if i == "lightManager" then
            if i == "lightManager" then
                if j["pointlight"] then
                    for k, v in ipairs(j["pointlight"]) do
                        --local createdLight = exports.dl_lightmanager:createPointLight(v.position.x, v.position.y, v.position.z, v.color.r, v.color.g, v.color.b, v.color.a, v.attenuation, v.generateNormals, v.skipNormals, mapDimension)
                        --TODO: STORE IT :)
                    end
                end
                if j["spotlight"] then
                    for k, v in ipairs(j["spotlight"]) do
                        --local createdLight = exports.dl_lightmanager:createSpotLight(v.position.x, v.position.y, v.position.z, v.color.r, v.color.g, v.color.b, v.color.a, v.direction.x, v.direction.y, v.direction.z, v.fallOff, v.theta, v.phi, v.attenuation, mapDimension)
                        --TODO: STORE IT :)
                    end
                end
            end
        end
    end
    for i, j in ipairs(serverMaps[mapType].objects) do
        local generatedModelID = engineRequestModel("object")
        if generatedModelID then
            if loadedClientMap.models.txd[mapTXDPath] and isElement(loadedClientMap.models.txd[mapTXDPath]) then
                loadedClientMap.models.txd[mapTXDPath]:import(generatedModelID)
            end
            local objectDFFPath = ":mod_loader/files/maps/"..mapType.."/dff/"..(j.dffPath)
            local objectCOLPath = ":mod_loader/files/maps/"..mapType.."/col/"..(j.colPath)
            if objectDFFPath and File.exists(objectDFFPath) then
                if not loadedClientMap.models.dff[objectDFFPath] then
                    loadedClientMap.models.dff[objectDFFPath] = EngineDFF(objectDFFPath)
                end
                if loadedClientMap.models.dff[objectDFFPath] and isElement(loadedClientMap.models.dff[objectDFFPath]) then
                    loadedClientMap.models.dff[objectDFFPath]:replace(generatedModelID)
                end
            end
            if objectCOLPath and File.exists(objectCOLPath) then
                if not loadedClientMap.models.col[objectCOLPath] then
                    loadedClientMap.models.col[objectCOLPath] = EngineCOL(objectCOLPath)
                end
                if loadedClientMap.models.col[objectCOLPath] and isElement(loadedClientMap.models.col[objectCOLPath]) then
                    loadedClientMap.models.col[objectCOLPath]:replace(generatedModelID)
                end
            end
            Engine.setModelLODDistance(generatedModelID, 300)
            local createdObject = Object(generatedModelID, j.position.x, j.position.y, j.position.z, j.rotation.x, j.rotation.y, j.rotation.z)
            createdObject:setScale(j.scale)
            createdObject:setAlpha(j.alpha)
            createdObject:setFrozen(j.frozen)
            createdObject:setDoubleSided(j.doublesided)
            createdObject:setCollisionsEnabled(j.collisions)
            createdObject:setDimension(mapDimension)
            table.insert(loadedClientMap.modelIDs, generatedModelID)
            table.insert(loadedClientMap.objects, createdObject)
        end
    end
    return true

end


-----------------------------------------
--[[ Event: On Client Resource Start ]]--
-----------------------------------------

addEventHandler("onClientResourceStart", resource, function()

    for i = 550, 19999 do
        removeWorldModel(i, 10000, 0, 0, 0)
    end
    setOcclusionsEnabled(false)
    setWaterLevel(-5000)

end)