global describe: function(string, function)
global it: function(string, function)

local Emitter = require("emitter")

local record Greet is Emitter.Event
  name: string
end

function Greet.new(name: string): Greet
  return { type = Greet, name = name }
end

local record Depart is Emitter.Event
    name: string
end

function Depart.new(name: string): Depart
  return { type = Depart, name = name }
end

describe("Emitter", function()
  describe("new", function()
    it("works", function()
      Emitter.new()
    end)
  end)

  describe("subscribe", function()
    it("emits in order", function()
      local messages: {string} = {}
      local emitter = Emitter.new()
      emitter:on(Greet, function(greet: Greet)
        table.insert(messages, greet.name .. " 1")
      end)
      emitter:on(Greet, function(greet: Greet)
        table.insert(messages, greet.name .. " 2")
      end)
      emitter:on(Depart, function(depart: Depart)
        table.insert(messages, "Depart: " .. depart.name)
      end)
      emitter:emit(Greet.new("Hi"))
      assert(2 == #messages)
      assert("Hi 1" == messages[1])
      assert("Hi 2" == messages[2])

      emitter:emit(Depart.new("Bye"))
      assert(3 == #messages)
      assert("Depart: Bye" == messages[3])
    end)

    it("can prepend events", function()
      local messages: {string} = {}
      local emitter = Emitter.new()
      emitter:on(Greet, function(greet: Greet)
        table.insert(messages, greet.name .. " 1")
      end, { position = "first" })
      emitter:on(Greet, function(greet: Greet)
        table.insert(messages, greet.name .. " 2")
      end, { position = "first" })
      emitter:emit(Greet.new("Hi"))
      assert(2 == #messages)
      assert("Hi 2" == messages[1])
      assert("Hi 1" == messages[2])
    end)
  end)

  describe("unsubscribe", function()
    it("emits once", function()
      local messages: {string} = {}
      local emitter = Emitter.new()
      emitter:once(Greet, function(greet: Greet)
        table.insert(messages, greet.name .. " 1")
      end)
      emitter:once(Greet, function(greet: Greet)
        table.insert(messages, greet.name .. " 2")
      end)

      emitter:emit(Greet.new("Hi"))
      assert(2 == #messages)
      assert("Hi 1" == messages[1])
      assert("Hi 2" == messages[2])

      emitter:emit(Greet.new("Hi"))
      assert(2 == #messages)
    end)

    it("can unsubscribe by receiver", function()
      local messages: {string} = {}
      local emitter = Emitter.new()
      local listener = function(greet: Greet)
        table.insert(messages, greet.name)
      end
      emitter:on(Greet, listener)
      emitter:emit(Greet.new("Hi"))
      assert(1 == #messages)
      assert("Hi" == messages[1])

      emitter:off(Greet, listener)
      emitter:emit(Greet.new("Hi"))
      assert(1 == #messages)
    end)

    it("can unsubscribe by id", function()
      local messages: {string} = {}
      local emitter = Emitter.new()
      local listener = function(greet: Greet)
        table.insert(messages, greet.name)
      end
      emitter:on(Greet, listener, { id = "id" })
      emitter:emit(Greet.new("Hi"))
      assert(1 == #messages)
      assert("Hi" == messages[1])

      emitter:off(Greet, "id")
      emitter:emit(Greet.new("Hi"))
      assert(1 == #messages)
    end)

    it("can unsubscribe multiple by id", function()
      local messages: {string} = {}
      local emitter = Emitter.new()
      local listener = function(greet: Greet)
        table.insert(messages, greet.name)
      end
      emitter:on(Greet, listener, { id = "id" })
      emitter:on(Greet, listener, { id = "id" })
      emitter:emit(Greet.new("Hi"))

      assert(2 == #messages)
      assert("Hi" == messages[1])
      assert("Hi" == messages[2])

      emitter:off(Greet, "id")
      emitter:emit(Greet.new("Hi"))
      assert(2 == #messages)
    end)
  end)

  describe("forwards events", function()
    it("forwards events to an emitter", function()
      local messages: {string} = {}
      local forwarded: {string} = {}

      local emitter = Emitter.new()
      local forward = Emitter.new()

      emitter:on(Greet, function(greet: Greet)
        table.insert(messages, greet.name)
      end)

      forward:on(Greet, function(greet: Greet)
        table.insert(forwarded, greet.name)
      end)

      emitter:startForwarding(forward)
      emitter:emit(Greet.new("Hi"))

      assert(1 == #messages)
      assert("Hi" == messages[1])
      assert(1 == #forwarded)
      assert("Hi" == forwarded[1])

      forward:emit(Greet.new("Hi"))

      assert(1 == #messages)
      assert(2 == #forwarded)

      emitter:stopForwarding(forward)
      emitter:emit(Greet.new("Hello"))

      assert(2 == #messages)
      assert("Hello" == messages[2])
      assert(2 == #forwarded)
    end)
  end)
end)

