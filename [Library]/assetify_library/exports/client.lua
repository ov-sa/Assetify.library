----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: exports: client.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Client Sided Exports ]]--
----------------------------------------------------------------


-------------------------
--[[ Functions: APIs ]]--
-------------------------

function getLibraryProgress(assetType, assetName)
    local cDownloaded, cBandwidth = nil, nil
    if assetType and assetName then
        if settings.assetPacks[assetType] and settings.assetPacks[assetType].rwDatas[assetName] then
            cBandwidth = settings.assetPacks[assetType].rwDatas[assetName].assetSize.total
            cDownloaded = (syncer.scheduledAssets and syncer.scheduledAssets[assetType] and syncer.scheduledAssets[assetType][assetName] and syncer.scheduledAssets[assetType][assetName].assetSize) or cBandwidth
        end
    else
        cBandwidth = syncer.libraryBandwidth
        cDownloaded = syncer.__libraryBandwidth or 0
    end
    if cDownloaded and cBandwidth then
        cDownloaded = math.min(cDownloaded, cBandwidth)
        return cDownloaded, cBandwidth, (cDownloaded/math.max(1, cBandwidth))*100
    end
    return false
end