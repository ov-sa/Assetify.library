----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: gui: tool.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Tool UI Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tocolor = tocolor,
    beautify = beautify
}


-------------------
--[[ Variables ]]--
-------------------

mapper.ui.toolWnd = {
    font = availableFonts[1], fontColor = imports.tocolor(175, 175, 175, 255)
}


------------------------------
--[[ Function: Renders UI ]]--
------------------------------

mapper.ui.toolWnd.renderUI = function()
    imports.beautify.gridlist.setSelection(mapper.ui.sceneWnd.propLst.element, (mapper.isTargettingDummy and mapper.buffer.element[(mapper.isTargettingDummy)].id) or 0)
    imports.beautify.native.drawText("Scene Name: "..((mapper.loadedScene and mapper.rwAssets[(mapper.cacheManifestPath)][(mapper.loadedScene)]) or "-").."\nSelected Prop: "..(mapper.isTargettingDummy and imports.beautify.gridlist.getRowData(mapper.ui.sceneWnd.propLst.element, mapper.buffer.element[(mapper.isTargettingDummy)].id, 1) or "-").."\nTranslator Mode: "..((mapper.translationMode and mapper.translationMode.type and (((mapper.axis.validAxesTypes[(mapper.translationMode.type)] == "slate") and "Position") or "Rotation")) or "-").."\nTranslation Axis: "..((mapper.translationMode and mapper.translationMode.axis) or "-"), 0, mapper.ui.margin, CLIENT_MTA_RESOLUTION[1] - mapper.ui.margin, CLIENT_MTA_RESOLUTION[2], mapper.ui.toolWnd.fontColor, 1, mapper.ui.toolWnd.font, "right", "top", true, true, false)
end