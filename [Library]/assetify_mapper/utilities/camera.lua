----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: utilities: camera.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Camera Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    addEventHandler = addEventHandler,
    removeEventHandler = removeEventHandler,
    getCameraMatrix = getCameraMatrix,
    setCameraMatrix = setCameraMatrix,
    getKeyState = getKeyState,
    getPedControlState = getPedControlState,
    showCursor = showCursor,
    math = math
}


-----------------------
--[[ Class: camera ]]--
-----------------------

camera = {
    fov = 45,
    rotation = {x = 0, y = 0},
    speed = {generic = 0, strafe = 0}
}
camera.__index = camera

function camera:create()
    if camera.isEnabled then return false end
    camera.speed.generic, camera.speed.strafe = 0, 0
    imports.addEventHandler("onClientRender", root, camera.render)
    imports.addEventHandler("onClientCursorMove", root, camera.controlMouse)
    camera.isEnabled = true
    return true
end

function camera:destroy()
    if not camera.isEnabled then return false end
    imports.removeEventHandler("onClientRender", root, camera.render)
    imports.removeEventHandler("onClientCursorMove", root, camera.controlMouse)
    camera.isEnabled = false
    return true
end

camera.render = function()
    camera.speed.generic, camera.speed.strafe = 0, 0
    local camera_posX, camera_posY, camera_posZ = imports.getCameraMatrix()
    local view_angleX, view_angleY, view_angleZ = imports.math.cos(camera.rotation.y)*imports.math.sin(camera.rotation.x), imports.math.cos(camera.rotation.y)*imports.math.cos(camera.rotation.x), imports.math.sin(camera.rotation.y)
    local camera_targetX, camera_targetY, camera_targetZ = camera_posX + (view_angleX*100), camera_posY + (view_angleY*100), 0
    local camera_speed = availableControlSpeeds.normal
    if not camera.isCursorVisible then
        camera_speed = (imports.getKeyState(availableControls.speedUp) and availableControlSpeeds.fast) or (imports.getKeyState(availableControls.speedDown) and availableControlSpeeds.slow) or camera_speed
        if imports.getPedControlState(availableControls.moveForwards) then
            camera.speed.generic = camera_speed
        elseif imports.getPedControlState(availableControls.moveBackwards) then
            camera.speed.generic = -camera_speed
        end
        if imports.getPedControlState(availableControls.moveLeft) then
            camera.speed.strafe = camera_speed
        elseif imports.getPedControlState(availableControls.moveRight) then
            camera.speed.strafe = -camera_speed
        end
    end
    local camera_angleX, camera_angleY, camera_angleZ = camera_posX - camera_targetX, camera_posY - camera_targetY, 0
    local camera_angleLength = imports.math.sqrt((camera_angleX*camera_angleX) + (camera_angleY*camera_angleY) + (camera_angleZ*camera_angleZ))
    local camera_normX, camera_normY, camera_normZ = camera_angleY/camera_angleLength, -camera_angleX/camera_angleLength, 0
    camera_posX, camera_posY, camera_posZ = camera_posX + (view_angleX*camera.speed.generic) + (camera_normX*camera.speed.strafe), camera_posY + (view_angleY*camera.speed.generic) + (camera_normY*camera.speed.strafe), camera_posZ + (view_angleZ*camera.speed.generic) + (camera_normZ*camera.speed.strafe)
    camera_targetX, camera_targetY, camera_targetZ = camera_posX + (view_angleX*100), camera_posY + (view_angleY*100), camera_posZ + (view_angleZ*100)
    imports.setCameraMatrix(camera_posX, camera_posY, camera_posZ, camera_targetX, camera_targetY, camera_targetZ, 0, camera.fov)
end

camera.controlMouse = function(_, _, aX, aY)
    if CLIENT_MTA_WINDOW_ACTIVE or CLIENT_IS_CURSOR_SHOWING then return false end
    if camera.isCursorVisible or not camera.cursorTick or ((CLIENT_CURRENT_TICK - camera.cursorTick) <= 500) then return false end
    aX, aY = aX - CLIENT_MTA_RESOLUTION[1]*0.5, aY - CLIENT_MTA_RESOLUTION[2]*0.5
    camera.rotation.x, camera.rotation.y = camera.rotation.x + (aX*0.05*0.01745), camera.rotation.y - (aY*0.05*0.01745)
    local mulX, mulY = 2*imports.math.pi, imports.math.pi/2.05
    if camera.rotation.x > imports.math.pi then
        camera.rotation.x = camera.rotation.x - mulX
    elseif camera.rotation.x < -imports.math.pi then
        camera.rotation.x = camera.rotation.x + mulX
    end
    if camera.rotation.y > imports.math.pi then
        camera.rotation.y = camera.rotation.y - mulX
    elseif camera.rotation.y < -imports.math.pi then
        camera.rotation.y = camera.rotation.y + mulX
    end
    if camera.rotation.y < -mulY then
        camera.rotation.y = -mulY
    elseif camera.rotation.y > mulY then
        camera.rotation.y = mulY
    end
end

camera.controlCursor = function(_, _, state)
    if state == nil then state = not camera.isCursorVisible end
    if not state then camera.cursorTick = CLIENT_CURRENT_TICK end
    camera.isCursorVisible = state
    imports.showCursor(camera.isCursorVisible, false)
end