local Charset = {}
--test
for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

GetRandomString = function(length)
    math.randomseed(GetGameTimer())

    if length > 0 then
        return GetRandomString(length - 1) .. Charset[math.random(1, #Charset)]
    else
        return ''
    end
end

MARKERAPP = setmetatable({}, MARKERAPP)

MARKERAPP.__index = MARKERAPP

MARKERAPP.__call = function()
    return "MARKERAPP"
end

function MARKERAPP.new()

    local _MARKERAPP = {
        _Markers = {},
        _InMarker = false,
        _LastMarker = nil,
        _Started = false
    }

    return setmetatable(_MARKERAPP, MARKERAPP)
end

--- Manages marker state. Don't use
--- @param state boolean Sets the state of the current marker
--- @return boolean
function MARKERAPP:InMarker(state)
    if type(state) ~= "boolean" then
        return self._InMarker
    else
        self._InMarker = state
        return self._InMarker
    end
end


--- @return table Returns all markers in this instance
function MARKERAPP:GetMarkers()
    return self._Markers
end

--- @param marker Marker Adds a marker to the instance
function MARKERAPP:AddMarker(marker)
    self._Markers[marker._UID] = marker
end

--- @param marker Marker Removes a marker from the instance
function MARKERAPP:RemoveMarker(marker)
    self._Markers[marker._UID] = nil
end

--- @param location string | boolean Sets the last location of the instance. For internal use
function MARKERAPP:LastLocation(location)
    if location ~= nil and type(location) ~= "boolean" then
        for k,v in pairs(self:GetMarkers()) do
            if k == location then
                self._LastMarker = location
                return self._LastMarker
            end
        end
    elseif type(location) == "boolean" then
        if location == false then
            self._LastMarker = nil
        end
    else
        return self._LastMarker
    end
end

--- Starts the marker instance
function MARKERAPP:Start()
    if self._Started == false then
        self._Started = true
        Citizen.CreateThread(function()
            while self._Started == true do
                Wait(0)
                if MarkerApp:InMarker() == false then
                    Wait(500)
                end
                local coords = GetEntityCoords(PlayerPedId())

                for k,v in pairs(MarkerApp:GetMarkers()) do
                    local icoords = v:Coords()
                    local dist = #(coords - icoords)
                    if dist < v:Threshold() and MarkerApp:InMarker() == false then
                        MarkerApp:InMarker(true)
                        MarkerApp:LastLocation(k)
                        v:OnEnter()
                    end

                    if dist > v:Threshold() and MarkerApp:InMarker() == true and MarkerApp:LastLocation() == k then
                        MarkerApp:InMarker(false)
                        MarkerApp:LastLocation(false)
                        v:OnExit()
                    end
                end
            end
        end)
    end
end

--- Stops the marker instance
function MARKERAPP:Stop()
    self._Started = false
end

function CreateMarkerApp()
    return MARKERAPP.new()
end

MarkerApp = CreateMarkerApp()
-------------------------------------
-------------------------------------
-------------------------------------

MARKER = setmetatable({}, MARKER)

MARKER.__index = MARKER

MARKER.__call = function()
    return "MARKER"
end

--- @param coords table Expects `{ x = number, y = number, z = number }`
--- @param threshold number The radius around the marker that will trigger it. Defaults to 1.5
function MARKER.new(coords, threshold)
    local randString
    repeat
        Wait(10)
        local _randString = GetRandomString(5)
        if MarkerApp._Markers[_randString] == nil then
            randString = _randString
        end
    until randString ~= nil

    threshold = threshold or 1.5

    local vcoords = vector3(coords.x, coords.y, coords.z)

    local _MARKER = {
        _UID = randString,
        _Coords = vcoords,
        _Threshold = threshold,
        OnEnter = function()

        end,
        OnExit = function()

        end
    }

    local mt = setmetatable(_MARKER, MARKER)
    MarkerApp:AddMarker(mt)
    return mt
end

--- @param coords table
--- Sets the coords for the marker
--- @return table
function MARKER:Coords(coords)
    if type(coords) ~= "table" then
        return self._Coords
    else
        if type(coords.x) == "number" and type(coords.y) == "number" and type(coords.z) == "number" then
            self._Coords = coords
        end
    end
end

--- @param threshold number Sets/Gets the threshold for the marker
--- @return number
function MARKER:Threshold(threshold)
    if type(threshold) ~= "number" then
        return self._Threshold
    else
        self._Threshold = threshold
    end
end


function CreateMarker(coords, threshold)
    return MARKER.new(coords, threshold)
end


