----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: mapExport.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Map Exports ]]--
----------------------------------------------------------------


----------------------------------------
--[[ Function: Retrieves Loaded Map ]]--
----------------------------------------

function getLoadedMap()

    return _getLoadedMap()

end


--------------------------------------
--[[ Functions: Unloads/Loads Map ]]--
--------------------------------------

function unloadMap()

    return _unloadMap()

end

function loadMap(...)

    return _loadMap(unpack({...}))

end