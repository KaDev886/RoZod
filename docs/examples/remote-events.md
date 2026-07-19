# Example: RemoteEvent Validation

Validating chat messages sent from clients through RemoteEvents.

## Schema

```lua
local chatSchema = RoZod.Object({
    Message = RoZod.String():MinLength(1):MaxLength(200),
    Channel = RoZod.String():OneOf({ "global", "team", "whisper" }),
    TargetPlayer = RoZod.String():Optional(),
})
```

## Server handler

```lua
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

ChatEvent.OnServerEvent:Connect(function(player, data)
    local cleanData = chatSchema:Coerce(data)

    if cleanData == nil then
        warn(`Invalid chat data from {player.UserId}`)
        return
    end

    BroadcastMessage(player, cleanData.Message, cleanData.Channel)
end)
```

## Client sending

```lua
local ChatEvent = ReplicatedStorage:WaitForChild("ChatEvent")

local function sendChat(message, channel, target)
    ChatEvent:FireServer({
        Message = message,
        Channel = channel,
        TargetPlayer = target,
    })
end
```

## Strict validation

```lua
local strictSchema = chatSchema:Silent()

ChatEvent.OnServerEvent:Connect(function(player, data)
    if not strictSchema:IsValid(data) then
        warn(`Invalid data from {player.UserId}:`, data)
        return
    end

    BroadcastMessage(player, data.Message, data.Channel)
end)
```
