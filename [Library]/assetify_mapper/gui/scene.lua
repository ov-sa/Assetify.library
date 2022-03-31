----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: gui: scene.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Scene UI Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tocolor = tocolor,
    isElement = isElement,
    destroyElement = destroyElement,
    addEventHandler = addEventHandler,
    triggerEvent = triggerEvent,
    triggerServerEvent = triggerServerEvent,
    getElementLocation = getElementLocation,
    string = string,
    quat = quat,
    beautify = beautify
}


-------------------
--[[ Variables ]]--
-------------------

mapper.ui = {
    margin = 5,
    bgColor = imports.tocolor(6, 6, 6, 255),
    propWnd = {
        startX = 0, startY = 0,
        width = 265, height = 339,
        propLst = {
            text = imports.string.upper("Assets"),
            height = 300
        },
        spawnBtn = {
            text = "Spawn Asset",
            startY = 300 + 5,
            height = 24
        }
    },

    sceneWnd = {
        startX = 0, startY = 339,
        width = 265, height = 418,
        propLst = {
            text = imports.string.upper("Props"),
            height = 321
        },
        viewBtn = {
            text = "View Scenes",
            startY = 321 + 5 + 5,
            height = 24
        },
        resetBtn = {
            text = "Reset Scene",
            startY = 321 + 5 + 5 + 24 + 5,
            height = 24
        },
        saveBtn = {
            text = "Save Scene",
            startY = 321 + 5 + 5 + 24 + 5 + 24 + 5,
            height = 24
        }
    },

    sceneListWnd = {
        width = 450, height = 297,
        sceneLst = {
            text = imports.string.upper("Scenes"),
            height = 171
        },
        loadBtn = {
            text = "Load Scene",
            startY = 171 + 5,
            height = 24
        },
        deleteBtn = {
            text = "Delete Scene",
            startY = 171 + 5 + 24 + 5,
            height = 24
        },
        generateBtn = {
            text = "Generate Scene",
            startY = 171 + 5 + 24 + 5 + 24 + 5,
            height = 24
        },
        closeBtn = {
            text = "Close",
            startY = 171 + 5 + 24 + 5 + 24 + 5 + 24 + 5,
            height = 24
        }
    }
}

mapper.ui.propWnd.createUI = function()
    mapper.ui.propWnd.element = imports.beautify.card.create(mapper.ui.propWnd.startX, mapper.ui.propWnd.startY, mapper.ui.propWnd.width, mapper.ui.propWnd.height)
    imports.beautify.setUIVisible(mapper.ui.propWnd.element, true)
    mapper.ui.propWnd.propLst.element = imports.beautify.gridlist.create(mapper.ui.margin, mapper.ui.margin, mapper.ui.propWnd.width - (mapper.ui.margin*2), mapper.ui.propWnd.propLst.height, mapper.ui.propWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.propWnd.propLst.element, true)
    imports.beautify.gridlist.addColumn(mapper.ui.propWnd.propLst.element, mapper.ui.propWnd.propLst.text, mapper.ui.propWnd.width - (mapper.ui.margin*3))
    for i = 1, #Assetify_Props, 1 do
        local j = Assetify_Props[i]
        local rowIndex = imports.beautify.gridlist.addRow(mapper.ui.propWnd.propLst.element)
        imports.beautify.gridlist.setRowData(mapper.ui.propWnd.propLst.element, rowIndex, 1, j)
    end
    imports.beautify.gridlist.setSelection(mapper.ui.propWnd.propLst.element, 1)
    mapper.ui.propWnd.spawnBtn.element = imports.beautify.button.create(mapper.ui.propWnd.spawnBtn.text, mapper.ui.margin, mapper.ui.margin + mapper.ui.propWnd.spawnBtn.startY, "default", mapper.ui.propWnd.width - (mapper.ui.margin*2), mapper.ui.propWnd.spawnBtn.height, mapper.ui.propWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.propWnd.spawnBtn.element, true)
    imports.beautify.render.create(function()
        imports.beautify.native.drawRectangle(0, 0, mapper.ui.propWnd.width, mapper.ui.propWnd.height, mapper.ui.bgColor, false)
    end, {
        elementReference = mapper.ui.propWnd.element,
        renderType = "preViewRTRender"
    })

    imports.addEventHandler("onClientUIClick", mapper.ui.propWnd.spawnBtn.element, function()
        local assetSelection = imports.beautify.gridlist.getSelection(mapper.ui.propWnd.propLst.element)
        if not assetSelection then return false end
        local assetName = imports.beautify.gridlist.getRowData(mapper.ui.propWnd.propLst.element, assetSelection, 1)
        if not assetName then return false end
        mapper.isSpawningDummy = {assetName = assetName}
    end)
end

mapper.ui.sceneWnd.createUI = function()
    mapper.ui.sceneWnd.element = imports.beautify.card.create(mapper.ui.sceneWnd.startX, mapper.ui.sceneWnd.startY, mapper.ui.sceneWnd.width, mapper.ui.sceneWnd.height)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.element, true)
    mapper.ui.sceneWnd.propLst.element = imports.beautify.gridlist.create(mapper.ui.margin, mapper.ui.margin, mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.propLst.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.propLst.element, true)
    imports.beautify.gridlist.addColumn(mapper.ui.sceneWnd.propLst.element, mapper.ui.sceneWnd.propLst.text, mapper.ui.sceneWnd.width - (mapper.ui.margin*3))
    mapper.ui.sceneWnd.viewBtn.element = imports.beautify.button.create(mapper.ui.sceneWnd.viewBtn.text, mapper.ui.margin, mapper.ui.sceneWnd.viewBtn.startY, "default", mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.viewBtn.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.viewBtn.element, true)
    mapper.ui.sceneWnd.resetBtn.element = imports.beautify.button.create(mapper.ui.sceneWnd.resetBtn.text, mapper.ui.margin, mapper.ui.sceneWnd.resetBtn.startY, "default", mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.resetBtn.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.resetBtn.element, true)
    mapper.ui.sceneWnd.saveBtn.element = imports.beautify.button.create(mapper.ui.sceneWnd.saveBtn.text, mapper.ui.margin, mapper.ui.sceneWnd.saveBtn.startY, "default", mapper.ui.sceneWnd.width - (mapper.ui.margin*2), mapper.ui.sceneWnd.saveBtn.height, mapper.ui.sceneWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneWnd.saveBtn.element, true)
    imports.beautify.render.create(function()
        imports.beautify.native.drawRectangle(0, 0, mapper.ui.sceneWnd.width, mapper.ui.sceneWnd.height, mapper.ui.bgColor, false)
    end, {
        elementReference = mapper.ui.sceneWnd.element,
        renderType = "preViewRTRender"
    })

    imports.addEventHandler("onClientUIClick", mapper.ui.sceneWnd.viewBtn.element, function()
        mapper.ui.sceneListWnd.createUI()
    end)
    imports.addEventHandler("onClientUIClick", mapper.ui.sceneWnd.resetBtn.element, function()
        if mapper:reset() then
            imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Scene successfully resetted.", availableColors.success)
        end
    end)
    imports.addEventHandler("onClientUIClick", mapper.ui.sceneWnd.saveBtn.element, function()
        thread:create(function(cThread)
            local sceneIPL = ""
            for i = 1, #mapper.buffer.index, 1 do
                local j = mapper.buffer.index[i]
                local posX, posY, posZ, rotX, rotY, rotZ = imports.getElementLocation(j.element)
                local rotW = 0
                rotW, rotX, rotY, rotZ = imports.quat.fromEuler(rotX, rotY, rotZ)
                sceneIPL = sceneIPL..(i - 1)..", "..(j.assetName)..", 0, "..posX..", "..posY..", "..posZ..", "..rotX..", "..rotY..", "..rotZ..", "..rotW..", -1\n"
                thread.pause()
            end
            imports.triggerServerEvent("Assetify:Mapper:onSaveScene", localPlayer, mapper.rwAssets[(mapper.cacheManifestPath)][(mapper.loadedScene)], sceneIPL)
        end):resume({
            executions = downloadSettings.buildRate,
            frames = 1
        })
    end)
end

mapper.ui.sceneListWnd.createUI = function()
    mapper.ui.sceneListWnd.destroyUI()
    mapper.ui.sceneListWnd.element = imports.beautify.card.create((CLIENT_MTA_RESOLUTION[1] - mapper.ui.sceneListWnd.width)*0.5, (CLIENT_MTA_RESOLUTION[2] - mapper.ui.sceneListWnd.height)*0.5, mapper.ui.sceneListWnd.width, mapper.ui.sceneListWnd.height)
    imports.beautify.setUIVisible(mapper.ui.sceneListWnd.element, true)
    mapper.ui.sceneListWnd.sceneLst.element = imports.beautify.gridlist.create(mapper.ui.margin, mapper.ui.margin, mapper.ui.sceneListWnd.width - (mapper.ui.margin*2), mapper.ui.sceneListWnd.sceneLst.height, mapper.ui.sceneListWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneListWnd.sceneLst.element, true)
    imports.beautify.gridlist.addColumn(mapper.ui.sceneListWnd.sceneLst.element, mapper.ui.sceneListWnd.sceneLst.text, mapper.ui.sceneListWnd.width - (mapper.ui.margin*3))
    mapper.ui.sceneListWnd.loadBtn.element = imports.beautify.button.create(mapper.ui.sceneListWnd.loadBtn.text, mapper.ui.margin, mapper.ui.margin + mapper.ui.sceneListWnd.loadBtn.startY, "default", mapper.ui.sceneListWnd.width - (mapper.ui.margin*2), mapper.ui.sceneListWnd.loadBtn.height, mapper.ui.sceneListWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneListWnd.loadBtn.element, true)
    mapper.ui.sceneListWnd.deleteBtn.element = imports.beautify.button.create(mapper.ui.sceneListWnd.deleteBtn.text, mapper.ui.margin, mapper.ui.margin + mapper.ui.sceneListWnd.deleteBtn.startY, "default", mapper.ui.sceneListWnd.width - (mapper.ui.margin*2), mapper.ui.sceneListWnd.deleteBtn.height, mapper.ui.sceneListWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneListWnd.deleteBtn.element, true)
    mapper.ui.sceneListWnd.generateBtn.element = imports.beautify.button.create(mapper.ui.sceneListWnd.generateBtn.text, mapper.ui.margin, mapper.ui.margin + mapper.ui.sceneListWnd.generateBtn.startY, "default", mapper.ui.sceneListWnd.width - (mapper.ui.margin*2), mapper.ui.sceneListWnd.generateBtn.height, mapper.ui.sceneListWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneListWnd.generateBtn.element, true)
    mapper.ui.sceneListWnd.closeBtn.element = imports.beautify.button.create(mapper.ui.sceneListWnd.closeBtn.text, mapper.ui.margin, mapper.ui.margin + mapper.ui.sceneListWnd.closeBtn.startY, "default", mapper.ui.sceneListWnd.width - (mapper.ui.margin*2), mapper.ui.sceneListWnd.closeBtn.height, mapper.ui.sceneListWnd.element, false)
    imports.beautify.setUIVisible(mapper.ui.sceneListWnd.closeBtn.element, true)
    mapper.ui.sceneListWnd.refreshUI()
    imports.beautify.render.create(function()
        imports.beautify.native.drawRectangle(0, 0, mapper.ui.sceneListWnd.width, mapper.ui.sceneListWnd.height, mapper.ui.bgColor, false)
    end, {
        elementReference = mapper.ui.sceneListWnd.element,
        renderType = "preViewRTRender"
    })

    imports.addEventHandler("onClientUIClick", mapper.ui.sceneListWnd.loadBtn.element, function()
        local sceneName = mapper.ui.sceneListWnd.fetchSelection()
        if not sceneName then return false end
        if mapper.loadedScene and (mapper.rwAssets[(mapper.cacheManifestPath)][(mapper.loadedScene)] == sceneName) then
            imports.triggerEvent("Assetify:Mapper:onNotification", localPlayer, "Scene already loaded. ["..sceneName.."]", availableColors.error)
        else
            imports.triggerServerEvent("Assetify:Mapper:onLoadScene", localPlayer, sceneName)
        end
    end)
    imports.addEventHandler("onClientUIClick", mapper.ui.sceneListWnd.deleteBtn.element, function()
        local sceneName = mapper.ui.sceneListWnd.fetchSelection()
        if not sceneName then return false end
        imports.triggerServerEvent("Assetify:Mapper:onDeleteScene", localPlayer, sceneName)
    end)
    imports.addEventHandler("onClientUIClick", mapper.ui.sceneListWnd.generateBtn.element, function()
        local sceneName = mapper.ui.sceneListWnd.fetchSelection()
        if not sceneName then return false end
        imports.triggerServerEvent("Assetify:Mapper:onGenerateScene", localPlayer, sceneName)
    end)
    imports.addEventHandler("onClientUIClick", mapper.ui.sceneListWnd.closeBtn.element, function()
        mapper.ui.sceneListWnd.destroyUI()
    end)
end

mapper.ui.sceneListWnd.fetchSelection = function()
    local sceneSelection = imports.beautify.gridlist.getSelection(mapper.ui.sceneListWnd.sceneLst.element)
    if not sceneSelection then return false end
    local sceneName = imports.beautify.gridlist.getRowData(mapper.ui.sceneListWnd.sceneLst.element, sceneSelection, 1)
    return sceneName
end

mapper.ui.sceneListWnd.refreshUI = function()
    if not mapper.ui.sceneListWnd.element or not imports.isElement(mapper.ui.sceneListWnd.element) then return false end
    imports.beautify.gridlist.clearRows(mapper.ui.sceneListWnd.sceneLst.element)
    if mapper.rwAssets[(mapper.cacheManifestPath)] then
        for i = 1, #mapper.rwAssets[(mapper.cacheManifestPath)], 1 do
            local j = mapper.rwAssets[(mapper.cacheManifestPath)][i]
            local rowIndex = imports.beautify.gridlist.addRow(mapper.ui.sceneListWnd.sceneLst.element)
            imports.beautify.gridlist.setRowData(mapper.ui.sceneListWnd.sceneLst.element, rowIndex, 1, j)
        end
    end
end

mapper.ui.sceneListWnd.destroyUI = function()
    if mapper.ui.sceneListWnd.element and imports.isElement(mapper.ui.sceneListWnd.element) then
        imports.destroyElement(mapper.ui.sceneListWnd.element)
    end
end


------------------------------------------------
--[[ Functions: Enables/Creates/Destroys UI ]]--
------------------------------------------------

mapper.ui.enable = function(state)
    if mapper.ui.propWnd.element and imports.isElement(mapper.ui.propWnd.element) then
        imports.beautify.setUIDisabled(mapper.ui.propWnd.element, not state)
    end
    if mapper.ui.sceneWnd.element and imports.isElement(mapper.ui.sceneWnd.element) then
        imports.beautify.setUIDisabled(mapper.ui.sceneWnd.element, not state)
    end
    return true
end

mapper.ui.create = function()
    mapper.ui.destroy()
    mapper.ui.propWnd.createUI()
    mapper.ui.sceneWnd.createUI()
    return true
end

mapper.ui.destroy = function()
    if mapper.ui.propWnd.element and imports.isElement(mapper.ui.propWnd.element) then
        imports.destroyElement(mapper.ui.propWnd.element)
    end
    if mapper.ui.sceneWnd.element and imports.isElement(mapper.ui.sceneWnd.element) then
        imports.destroyElement(mapper.ui.sceneWnd.element)
    end
    mapper.ui.sceneListWnd.destroyUI()
    return true
end