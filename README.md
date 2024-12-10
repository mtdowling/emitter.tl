# emitter.tl

A small, strongly typed event emitter library for Lua and typed with
[Teal](https://github.com/teal-language/tl).

## Key features

* Designed around strongly typed events using Teal. Events are no longer just
  strings and bags of data.
* Allows for decoupling logic by subscribing and unsubscribing to events.
* Support for receiving an event at most once.
* Can efficiently forward all events from an Emitter to another Emitter.
  This is great for things like games that have global events and listeners
  that should only persist for the lifetime of a specific emitter.
* Listeners can be added or removed while emitting, and removals take effect
  immediately.

## Usage

First, require the module:

```teal
local Emitter = require("emitter")
```

### Creating an Emitter

An `Emitter` is used to publish and subscribe to events.

```teal
local emitter = Emitter.new()
```

### Creating an Event

Events are strongly typed and require a dedicated type for each kind of event.

For reference, this is the type definition of Event:

```teal
local interface Event
    type: Event
end
```

Each record that implements an Event must define a `type` property of the same
type as the event.

```teal
local record WarningEvent is Emitter.Event
    message: string
end
```

This library doesn't have any requirements on how instances of events are
created.

An instance of a `WarningEvent` can be created using basic table syntax:

```teal
local e: WarningEvent = {type = WarningEvent, message = "This is a warning"}
```

Alternatively, you can provide a constructor for your events.

```teal
function WarningEvent.new(message: string): WarningEvent
    return {type = WarningEvent, message = message}
end

local e: WarningEvent = WarningEvent.new("This is a warning")
```

This event can now be emitted and subscribed to.

### Subscribing to an Event

Listener functions are subscribed to an event using
`on<E is Event>(emitter: Emitter, E: event, function(E), config?: ListenerConfig)`.

```teal
emitter:on(WarningEvent, function(event: WarningEvent)
    print(event.message)
end)
```

### Emitting an Event

Events are emitted using `emit(Event: event)`.

```teal
emitter:emit(WarningEvent.new("This is a warning"))
```

Emitting the event will print "This is a warning".

### Event listener configuration

An optional configuration record can be passed when subscribing to an event
when using `on` or `once`:

* `id: string`: An identifier for the listener (defaults to ""). An identifier
  can be used to unsubscribe the listener by ID. No uniqueness checks are
  performed on the ID; multiple listeners can use the same ID, allowing events
  to be grouped.
* `position: "first" | "last"`: Controls whether the listener is added as the
  last listener for the event using "last" (the default) or the first listener
  for the event using "first".

### Unsubscribing from an Event

`off<E is Event>(event: E, listener: Listener<E> | string)` is used to
stop a listener from receiving events.

You can pass in the function that was used to subscribe to the event:

```teal
local function onWarning(event: WarningEvent)
    print(event.message)
end

emitter:on(WarningEvent, onWarning)

-- Unsubscribe the function.
emitter:off(WarningEvent, onWarning)
```

When subscribing to an event, an identifier can be given to the listener
so that the listener can be unsubscribed by ID rather than the actual function.

```teal
emitter:on(WarningEvent, onWarning, { id = "warning" })
emitter:off(WarningEvent, "warning")
```

IDs can be used for grouping event listeners.

```teal
-- While adding listeners, use the same ID to group them.
emitter:on(WarningEvent, b, { id = "print-group" })
emitter:on(WarningEvent, b, { id = "print-group" })

-- Remove both a and b listeners because they both have the id "print-group".
emitter:off(WarningEvent, "print-group")
```

### Receiving an event at most once

The `once<E is Event>(emitter: Emitter, E: event, function(E))` method can be
used to subscribe to an event and have the listeners automatically removed
after the first event is received.

```teal
emitter:once(WarningEvent, function(event: WarningEvent)
    print("Once: " .. event.message)
end)
```

### Forwarding events

Emitters can forward all events to another Emitter, allowing for a fan-out
pattern. This is done using `startForwarding(emitter: Emitter)`:

```teal
local forwardEmitter = Emitter.new()

forwardEmitter:on(WarningEvent, function(event: WarningEvent)
    print("Child: " .. event.message)
end)

emitter:startForwarding(forwardEmitter)
emitter:emit(WarningEvent.new("This is a warning"))
```

Will output:

```text
This is a warning
Child: This is a warning
```

An emitter can be detached from another emitter using
`stopForwarding(emitter: Emitter)`:

```teal
emitter:stopForwarding(forwardEmitter)
```

## Clearing and resetting an Emitter

`removeAllListeners(event: Event)` is used to remove all listeners for
an event type:

```teal
emitter:removeAllListeners(WarningEvent)
```

`reset()` is used to unsubscribe all listeners and stop forwarding all events:

```teal
emitter:reset()
```

## Installation

**Copy and paste**:

Copy and paste `src/emitter.tl` and/or `src/emitter.lua` into your project.

**Or use LuaRocks**:

```sh
luarocks install emitter.tl
```

## Contributing

The source code is written in Teal and compiled to Lua. The updated and
compiled Lua must be part of every code change to the Teal source code.
You can compile Teal to Lua and run tests using:

```sh
make
```

## License

This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See LICENSE for details.
