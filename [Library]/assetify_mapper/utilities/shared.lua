----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: utilities: shared.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Shared Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

if localPlayer then
    loadstring(exports.beautify_library:fetchImports())()
end
loadstring(exports.assetify_library:fetchImports())()
loadstring(exports.assetify_library:fetchThreader())()

local imports = {
    isElement = isElement,
    setElementPosition = setElementPosition,
    getElementPosition = getElementPosition,
    setElementRotation = setElementRotation,
    getElementRotation = getElementRotation
}


-------------------------------------------------
--[[ Functions: Sets/Gets Element's Location ]]--
-------------------------------------------------

function setElementLocation(element, posX, posY, posZ, rotX, rotY, rotZ, rotOrder)
    if not element or not imports.isElement(element) then return false end
    if posX and posY and posZ then
        imports.setElementPosition(element, posX, posY, posZ)
    end
    if rotX and rotY and rotZ then
        imports.setElementRotation(element, rotX, rotY, rotZ, rotOrder)
    end
    return true
end

function getElementLocation(element, rotOrder)
    if not element or not imports.isElement(element) then return false end
    local posX, posY, posZ = imports.getElementPosition(element)
    local rotX, rotY, rotZ = imports.getElementRotation(element, rotOrder)
    return posX, posY, posZ, rotX, rotY, rotZ 
end