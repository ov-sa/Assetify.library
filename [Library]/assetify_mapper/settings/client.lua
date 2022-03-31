----------------------------------------------------------------
--[[ Resource: Assetify Mapper
     Script: settings: client.lua
     Author: vStudio
     Developer(s): Tron
     DOC: 25/03/2022
     Desc: Client Sided Settings ]]--
----------------------------------------------------------------

-----------------
--[[ Imports ]]--
-----------------

local imports = {
    beautify = beautify
}


------------------
--[[ Settings ]]--
------------------

availableFonts = {
    [1] = imports.beautify.native.createFont(":beautify_library/files/assets/fonts/signika_semibold.rw", 10)
}

availableTemplates = {
    ["beautify_card"] = {
        color = {0, 0, 0, 0}
    },

    ["beautify_gridlist"] = {
        color = {10, 10, 10, 255},
        columnBar = {
            color = {6, 6, 6, 255},
            fontColor = {200, 200, 200, 255},
            divider = {
                size = 2,
                color = {6, 6, 6, 255}
            }
        },
        rowBar = {
            color = {20, 20, 20, 255},
            fontColor = {200, 200, 200, 255},
            hoverColor = {175, 175, 175, 255},
            hoverFontColor = {6, 6, 6, 255}
        }
    },

    ["beautify_button"] = {
        ["default"] = {
            fontPaddingY = 3,
            color = {10, 10, 10, 255},
            fontColor = {200, 200, 200, 255},
            hoverColor = {175, 175, 175, 255},
            hoverFontColor = {6, 6, 6, 255}
        }
    },

    ["beautify_scrollbar"] = {
        size = 5,
        track = {
            color = {6, 6, 6, 255}
        },
        thumb = {
            animAcceleration = 1,
            scrollAcceleration = 1,
            minSize = 75,
            shadowSize = 1,
            color = {150, 150, 150, 255},
            shadowColor = {0, 0, 0, 253}
        }
    }
}
