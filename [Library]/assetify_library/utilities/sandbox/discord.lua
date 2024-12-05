----------------------------------------------------------------
--[[ Resource: Assetify Library
     Script: utilities: sandbox: discord.lua
     Author: vStudio
     Developer(s): Aviril, Tron, Mario, Аниса
     DOC: 19/10/2021
     Desc: Discord Utilities ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    os = os,
    isDiscordRichPresenceConnected = isDiscordRichPresenceConnected,
    setDiscordApplicationID = setDiscordApplicationID,
    setDiscordRichPresenceButton = setDiscordRichPresenceButton,
    getDiscordRichPresenceUserID = getDiscordRichPresenceUserID,
    resetDiscordRichPresenceData = resetDiscordRichPresenceData,
    setDiscordRichPresenceAsset = setDiscordRichPresenceAsset,
    setDiscordRichPresenceDetails = setDiscordRichPresenceDetails,
    setDiscordRichPresenceState = setDiscordRichPresenceState
}


------------------------
--[[ Class: Discord ]]--
------------------------

local discord = class:create("discord")

function discord.private:snowflakeToTick(snowflake)
    snowflake = tonumber(snowflake)
    if not snowflake then return false end
    return (snowflake/4194304) + 1420070400000
end

if localPlayer then
    if settings.discord and settings.discord.appID then
        imports.setDiscordApplicationID(settings.discord.appID)
        thread:createHeartbeat(function()
            local userID = settings.discord.userID
            settings.discord.userID = false
            if imports.isDiscordRichPresenceConnected() then
                settings.discord.userID = imports.getDiscordRichPresenceUserID()
                settings.discord.userID = (settings.discord.userID and (string.len(settings.discord.userID) > 0) and settings.discord.userID) or false
                if settings.discord.buttons then
                    for i = 1, #settings.discord.buttons, 1 do
                        local j = settings.discord.buttons[i]
                        imports.setDiscordRichPresenceButton(i, j.name, j.url)
                    end
                end
                imports.setDiscordRichPresenceAsset(settings.discord.logo.asset, settings.discord.logo.tooltip)
                imports.setDiscordRichPresenceDetails(settings.discord.details)
                if not syncer.isLibraryLoaded then imports.setDiscordRichPresenceState((syncer.isLibraryLoaded and "Downloading") or "Playing") end
                local info = thread:getThread():await(network:emitCallback("Assetify:Discord:onFetchUserInfo", true, false, "780426807739678740"))
                if (imports.os.time() - info.createdAt) < (settings.discord.minAge*30*24*60*60) then
                    network:emit("Assetify:Discord:onKickPlayer", true, false, localPlayer, string.format("Discord account must be at least %s month(s) old", settings.discord.minAge))
                end
            else
                network:emit("Assetify:Discord:onKickPlayer", true, false, localPlayer, "Allow Discord rich presence")
            end
            if userID and settings.discord.userID and (userID ~= settings.discord.userID) then
                network:emit("Assetify:Discord:onKickPlayer", true, false, localPlayer, "Discord account switch detected")
            end
            return true
        end, function() end, settings.discord.trackRate)
    else
        imports.resetDiscordRichPresenceData()
    end
else
    network:create("Assetify:Discord:onKickPlayer"):on(function(player, reason) kickPlayer(player, reason) end)
    network:create("Assetify:Discord:onFetchUserInfo", true):on(function(self, uid)
        local env = self:await(rest:get("https://raw.githubusercontent.com/ov-sa/Assetify.library/refs/heads/env/global.vcl"))
        env = (env and table.decode(env)) or false
        local result = (env and self:await(rest:get(string.format("https://discord.com/api/v10/users/%s", uid), false, {["Authorization"] = string.format("Bot %s", string.decode(env.discord, "base64"))}))) or false
        result = (result and table.decode(result, "json")) or false
        if result then result.createdAt = discord.private:snowflakeToTick(uid)/1000 end
        return result
    end, {isAsync = true})
end