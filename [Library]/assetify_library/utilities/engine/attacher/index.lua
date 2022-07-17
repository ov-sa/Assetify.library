----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: engine: attacher: index.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Attacher Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    pairs = pairs,
    tonumber = tonumber,
    collectgarbage = collectgarbage,
    isElement = isElement,
    addDebugHook = addDebugHook,
    setElementMatrix = setElementMatrix,
    getElementMatrix = getElementMatrix,
}


-----------------------------
--[[ Namespace: Attacher ]]--
-----------------------------

local attacher = namespace:create("attacher")
attacher.private.buffer = {
    element = {},
    parent = {}
}

function attacher.public:attachElements(element, parent, offX, offY, offZ, rotX, rotY, rotZ)
    offX, offY, offZ, rotX, rotY, rotZ = imports.tonumber(offX) or 0, imports.tonumber(offY) or 0, imports.tonumber(offZ) or 0, imports.tonumber(rotX) or 0, imports.tonumber(rotY) or 0, imports.tonumber(rotZ) or 0
    if not imports.isElement(element) or not imports.isElement(parent) or (element == parent) then return false end
    attacher.public:detachElements(element)
    attacher.private.buffer.parent[parent] = attacher.private.buffer.parent[parent] or {}
    attacher.private.buffer.parent[parent][element] = true
    attacher.private.buffer.element[element] = {
        parent = parent,
        position = {x = offX, y = offY, z = offZ},
        rotation = {x = rotX, y = rotY, z = rotZ, matrix = math.matrix:fromRotation(rotX, rotY, rotZ)}
    }
    attacher.private.updateAttachments(parent, element)
    return true
end

function attacher.public:detachElements(element)
    if not element or not attacher.private.buffer.element[element] then return false end
    if attacher.private.buffer.parent[(attacher.private.buffer.element[element].parent)] then
        attacher.private.buffer.parent[(attacher.private.buffer.element[element].parent)][element] = nil
    end
    attacher.private.buffer.element[element].rotation.matrix:destroyInstance()
    attacher.private.buffer.element[element] = nil
    imports.collectgarbage()
    return true
end

function attacher.public:clearAttachments(element)
    if not element then return false end
    if attacher.private.buffer.parent[element] then
        for i, j in imports.pairs(attacher.private.buffer.parent[element]) do
            attacher.public:detachElements(i)
        end
    end
    attacher.public:detachElements(element)
    attacher.private.buffer.parent[element] = nil
    return true
end

function attacher.private.updateAttachments(parent, element, parentMatrix)
    if not parent or not attacher.private.buffer.parent[parent] then return false end
    parentMatrix = parentMatrix or imports.getElementMatrix(parent)
    if element then
        local cPointer = attacher.private.buffer.element[element]
        if cPointer then
            local rotationMatrix = cPointer.rotation.matrix.rows
            local offX, offY, offZ = cPointer.position.x, cPointer.position.y, cPointer.position.z
            imports.setElementMatrix(element, {
                {
                    (parentMatrix[2][1]*rotationMatrix[1][2]) + (parentMatrix[1][1]*rotationMatrix[1][1]) + (rotationMatrix[1][3]*parentMatrix[3][1]),
                    (parentMatrix[3][2]*rotationMatrix[1][3]) + (parentMatrix[1][2]*rotationMatrix[1][1]) + (parentMatrix[2][2]*rotationMatrix[1][2]),
                    (parentMatrix[2][3]*rotationMatrix[1][2]) + (parentMatrix[3][3]*rotationMatrix[1][3]) + (rotationMatrix[1][1]*parentMatrix[1][3]),
                    0
                },
                {
                    (rotationMatrix[2][3]*parentMatrix[3][1]) + (parentMatrix[2][1]*rotationMatrix[2][2]) + (rotationMatrix[2][1]*parentMatrix[1][1]),
                    (parentMatrix[3][2]*rotationMatrix[2][3]) + (parentMatrix[2][2]*rotationMatrix[2][2]) + (parentMatrix[1][2]*rotationMatrix[2][1]),
                    (rotationMatrix[2][1]*parentMatrix[1][3]) + (parentMatrix[3][3]*rotationMatrix[2][3]) + (parentMatrix[2][3]*rotationMatrix[2][2]),
                    0
                },
                {
                    (parentMatrix[2][1]*rotationMatrix[3][2]) + (rotationMatrix[3][3]*parentMatrix[3][1]) + (rotationMatrix[3][1]*parentMatrix[1][1]),
                    (parentMatrix[3][2]*rotationMatrix[3][3]) + (parentMatrix[2][2]*rotationMatrix[3][2]) + (rotationMatrix[3][1]*parentMatrix[1][2]),
                    (rotationMatrix[3][1]*parentMatrix[1][3]) + (parentMatrix[3][3]*rotationMatrix[3][3]) + (parentMatrix[2][3]*rotationMatrix[3][2]),
                    0
                },
                {
                    (offZ*parentMatrix[1][1]) + (offY*parentMatrix[2][1]) - (offX*parentMatrix[3][1]) + parentMatrix[4][1],
                    (offZ*parentMatrix[1][2]) + (offY*parentMatrix[2][2]) - (offX*parentMatrix[3][2]) + parentMatrix[4][2],
                    (offZ*parentMatrix[1][3]) + (offY*parentMatrix[2][3]) - (offX*parentMatrix[3][3]) + parentMatrix[4][3],
                    1
                }
            })
        end
    else
        for i, j in imports.pairs(attacher.private.buffer.parent[parent]) do
            if j and attacher.private.buffer.element[i] then
                attacher.private.updateAttachments(parent, i, parentMatrix)
            end
        end
    end
    return true
end


---------------------
--[[ API Syncers ]]--
---------------------

imports.addDebugHook("postFunction", function(_, _, _, _, _, element)
    attacher.private.updateAttachments(element)
end, {"setElementMatrix", "setElementPosition", "setElementRotation"})
network:fetch("Assetify:onElementDestroy"):on(function(source)
    if not syncer.isLibraryBooted or not source then return false end
    attacher.public:clearAttachments(source)
end)