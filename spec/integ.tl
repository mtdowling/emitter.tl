-- Ensures that examples from the README properly type check.

-- Usage

local Emitter = require("emitter")

-- Creating an Emitter

local emitter = Emitter.new()

-- Creating an Event

local record WarningEvent is Emitter.Event
    message: string
end

local _e1: WarningEvent = {type = WarningEvent, message = "This is a warning"}

function WarningEvent.new(message: string): WarningEvent
    return {type = WarningEvent, message = message}
end

local _e: WarningEvent = WarningEvent.new("This is a warning")

-- Subscribing to an Event

emitter:on(WarningEvent, function(event: WarningEvent)
    print(event.message)
end)

-- Emitting an Event

emitter:emit(WarningEvent.new("This is a warning"))

-- Unsubscribing from an Event

local function onWarning(event: WarningEvent)
    print(event.message)
end

emitter:on(WarningEvent, onWarning)
emitter:off(WarningEvent, onWarning)

emitter:on(WarningEvent, onWarning, {id = "warning" })
emitter:off(WarningEvent, "warning")

-- Receiving an event at most once

emitter:once(WarningEvent, function(event: WarningEvent)
    print("Once: " .. event.message)
end)

-- Forwarding events

local forwardEmitter = Emitter.new()

forwardEmitter:on(WarningEvent, function(event: WarningEvent)
    print("Child: " .. event.message)
end)

-- Clearing and resetting an Emitter

emitter:startForwarding(forwardEmitter)
emitter:emit(WarningEvent.new("This is a warning"))

emitter:stopForwarding(forwardEmitter)

emitter:removeAllListeners(WarningEvent)

emitter:reset()

