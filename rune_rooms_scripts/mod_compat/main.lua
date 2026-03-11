---@type {funct: function, exists: fun(): boolean}[]
local modCompatibilities = {}

---Adds a function that will only run once when all mods are loaded.
---@param mod string | fun(): boolean Name of the global variable to check if the mod exists, or funtion that checks if it does.
---@param funct function
function RuneRooms:AddModCompat(mod, funct)
    local exists = mod
    if type(exists) == "string" then
        exists = function ()
            return _G[mod] ~= nil
        end
    end

    modCompatibilities[#modCompatibilities+1] = {
        funct = funct,
        exists = exists
    }
end

local compats = {
    "eid",
    "fiend_folio",
    "revelations",
    "rare_chests",
    "repentanceplus",
    "runic_tablet"
}

for _, compat in ipairs(compats) do
    include("rune_rooms_scripts.mod_compat."..compat..".main")
end

local hasRunCompatibility = false
RuneRooms:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, function ()
    if hasRunCompatibility then return end
    hasRunCompatibility = true

    for _, modCompat in ipairs(modCompatibilities) do
        if modCompat.exists() then
            modCompat.funct()
        end
    end
end)