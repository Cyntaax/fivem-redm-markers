Fivem/RedM Marker Helper

This is a simple utility to help create "markers" in the world.
"Markers" being defined as areas which users will enter and exit that have certain actions happen. (i.e. entering a shop)

I've come across some interesting solutions to handling marker logic and figured I'd present my own.

This works off of a single thread which will sleep for 500 frames while not in a "marker" and will run every frame while in a "marker"

**Will not create markers on the ground, just points of interaction**

### Example

```lua
MarkerApp:Start()
local marker = CreateMarker({ x = 100.0, y = 100.0, z = 38.0 }, 2.5)

marker.OnEnter = function()
    print('You have entered the marker')
end

marker.OnExit = function()
    print('You have exited the marker')
end

--- If you want to kill the marker instance for whatever reason:
--- This will simply kill the thread. The instance will retain its data
MarkerApp:Stop()
```

### Another example

```lua
local ShopLocations = {
    {
        coords = { x = 0, y = 0, z = 0 }
    },
    {
        coords = { x = 10, y = 10, z = 10 }
    }
}

MarkerApp:Start()
LastShop = nil

for k,v in pairs(ShopLocations) do
    v.marker = CreateMarker(v.coords, 1.5)
    v.marker.OnEnter = function()
        LastShop = k
        CreateShopPrompt()
        print('^2You have entered shop ^3 ' .. k .. '^0')
    end

    v.marker.OnExit = function()
        LastShop = nil
        print('^1You have exited shop ^3 ' .. k .. '^0')
    end
end

function CreateShopPrompt()
    Citizen.CreateThread(function()
        while LastShop ~= nil do
            Citizen.Wait(0)
            -- Draw text or something every frame
        end
    end)
end
```

### Usage
```lua
--- Cross-resource
client_scripts {
    '@markers/Marker.lua'
}
```

**OR**

```lua
--- Include with your resource
client_scripts {
    'client/Marker.lua',
    'client/client.lua'
}
```