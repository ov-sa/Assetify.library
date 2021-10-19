----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: pedExport.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 19/10/2021 (OvileAmriam)
     Desc: Ped Exports ]]--
----------------------------------------------------------------


--------------------------------------
--[[ Function: Retrieves Ped's ID ]]--
--------------------------------------

function getPedID(...)

    return _getPedID(unpack({...}))

end