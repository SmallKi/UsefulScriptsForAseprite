--[[

Title: Selected Colors to Palette

Version: v1.3 (2024-04-15)

Description: This script for Aseprite captures colors from a selected area of an active sprite and adds them to the sprite's palette. It includes options to deduplicate colors, invert the color order, and clear the temporary color list.

Usage:
- Open a sprite in Aseprite.
- Select an area from which you want to capture colors.
- Run this script, and use the dialog options to manage and manipulate the palette.

Features:
- Add captured colors to the sprite's palette.
- Invert the order of captured colors.
- Deduplicate colors to avoid duplicates in the palette (optional).
- Clear the temporary color list.

Acknowledgments:
- Inspired by a discussion on r/aseprite on Reddit by users including ChocolateSea2553 and [deleted], whoever they are.
  The original discussion can be found here: [Reddit Post Link](https://www.reddit.com/r/aseprite/comments/y9qcy3/scripts_color_palette_from_selection/)

License: 
- This script is released under the MIT License. More details can be found at [MIT License](https://opensource.org/licenses/MIT).

Potential Issues:
- The script requires an active sprite and a selection. If these conditions are not met, it will alert the user.
- Handling very large selections or high color counts might slow down the script due to processing requirements.

]]


local spr = app.activeSprite
if not spr then
    return app.alert("There is no active sprite")
end

local sel = spr.selection
if sel.isEmpty then
    return app.alert("Select an area to make a palette from")
end

local new_pal
local shade_pal = {}
local dlgMain -- Declare dlgMain outside the functions to access it globally
local deduplicate = false -- Checkbox state

function populatePalette()
    for _i = #new_pal-1, 0, -1 do
        local c = new_pal:getColor(_i)
        if c.alpha ~= 0 then
            table.insert(shade_pal, c)
        end
    end
end

function deduplicateColors()
    local unique_colors = {}
    local hash = {}
    for _, color in ipairs(shade_pal) do
        local color_str = tostring(color.red) .. tostring(color.green) .. tostring(color.blue) .. tostring(color.alpha)
        if not hash[color_str] then
            table.insert(unique_colors, color)
            hash[color_str] = true
        end
    end
    shade_pal = unique_colors
end

function getPalette()
    if spr.selection.isEmpty then
        return app.alert("Please make a selection to capture colors.")
    end

    local act_pal = spr.palettes[1]
    local pal = Palette()
    app.command.NewSpriteFromSelection()
    app.command.ColorQuantization {
        ui = false,
        withAlpha = true,
        maxColors = 256,
        useRange = false,
        algorithm = 0 -- 0 default, 1 RGB table, 2 octree
    }
    local new_spr = app.activeSprite
    if new_spr then
        new_pal = new_spr.palettes[1]
        populatePalette()
        if deduplicate then
            deduplicateColors()
        end
        new_spr:close()
        if dlgMain then updateDialog() end -- Ensure dlgMain exists before updating
    else
        app.alert("Failed to create a new sprite from the selection. Please try again.")
    end
end

function addShade()
    local act_pal = spr.palettes[1]
    local ncolors = #act_pal
    act_pal:resize(ncolors + #shade_pal)
    for _i = 1, #shade_pal do
        act_pal:setColor(ncolors + _i - 1, shade_pal[_i])
    end
end

function invertShades()
    local inverted_shade_pal = {}
    for _i = #shade_pal, 1, -1 do
        table.insert(inverted_shade_pal, shade_pal[_i])
    end
    shade_pal = inverted_shade_pal
    if dlgMain then updateDialog() end -- Check if dlgMain is initialized
end

function clearColors()
    shade_pal = {}
    updateDialog()
end

function updateDialog()
    dlgMain:modify{id = 'sha', colors = shade_pal}  -- Update the shades widget directly
end

-- Dialog Windows
-- Main -- Sketch View
function showMain()
    dlgMain = Dialog{
        title = "SelectedColors2Palette",
        onclose = function()
            ColorShadingWindowBounds = dlgMain.bounds
        end
    }

    dlgMain:shades{id = 'sha', colors = shade_pal,
        onclick = function(ev) app.fgColor = ev.color end}
    :newrow()
    :button{text = "Add to Palette",
        onclick = function() addShade() end}
    :separator()
    :newrow()
    :button{text = "Invert Color Order",
        onclick = function() invertShades() end}
    :newrow()
    :button{text = "Get Colors from Selection",
        onclick = function() getPalette() end}
    :newrow()
    :button{text = "Clear Colors",
        onclick = function() clearColors() end}
    :newrow()
    :check{ id = "deduplicate_check", text = "Avoid Color Duplication", selected = deduplicate,
        onclick = function()
            deduplicate = not deduplicate
            dlgMain:modify{id = "deduplicate_check", selected = deduplicate}
        end}
    dlgMain:show{ wait = false, bounds = ColorShadingWindowBounds }
end

do
    getPalette()
    showMain()
end
