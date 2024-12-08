local Emitter = require("emitter")

local Greet = {}
function Greet.new(name)
  return { type = Greet, name = name }
end

local Depart = {}
function Depart.new(name)
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
      local messages = {}
      local emitter = Emitter.new()
      emitter:on(Greet, function(greet)
        table.insert(messages, greet.name .. " 1")
      end)
      emitter:on(Greet, function(greet)
        table.insert(messages, greet.name .. " 2")
      end)
      emitter:on(Depart, function(depart)
        table.insert(messages, "Depart: " .. depart.name)
      end)
      emitter:emit(Greet.new("Hi"))
      assert.equals(2, #messages)
      assert.equals("Hi 1", messages[1])
      assert.equals("Hi 2", messages[2])

      emitter:emit(Depart.new("Bye"))
      assert.equals(3, #messages)
      assert.equals("Depart: Bye", messages[3])
    end)

    it("can prepend events", function()
      local messages = {}
      local emitter = Emitter.new()
      emitter:on(Greet, function(greet)
        table.insert(messages, greet.name .. " 1")
      end, { position = "first" })
      emitter:on(Greet, function(greet)
        table.insert(messages, greet.name .. " 2")
      end, { position = "first" })
      emitter:emit(Greet.new("Hi"))
      assert.equals(2, #messages)
      assert.equals("Hi 2", messages[1])
      assert.equals("Hi 1", messages[2])
    end)
  end)

  describe("unsubscribe", function()
    it("emits once", function()
      local messages = {}
      local emitter = Emitter.new()
      emitter:once(Greet, function(greet)
        table.insert(messages, greet.name .. " 1")
      end)
      emitter:once(Greet, function(greet)
        table.insert(messages, greet.name .. " 2")
      end)

      emitter:emit(Greet.new("Hi"))
      assert.equals(2, #messages)
      assert.equals("Hi 1", messages[1])
      assert.equals("Hi 2", messages[2])

      emitter:emit(Greet.new("Hi"))
      assert.equals(2, #messages)
    end)

    it("can unsubscribe by receiver", function()
      local messages = {}
      local emitter = Emitter.new()
      local listener = function(greet)
        table.insert(messages, greet.name)
      end
      emitter:on(Greet, listener)
      emitter:emit(Greet.new("Hi"))
      assert.equals(1, #messages)
      assert.equals("Hi", messages[1])

      emitter:off(Greet, listener)
      emitter:emit(Greet.new("Hi"))
      assert.equals(1, #messages)
    end)

    it("can unsubscribe by id", function()
      local messages = {}
      local emitter = Emitter.new()
      local listener = function(greet)
        table.insert(messages, greet.name)
      end
      emitter:on(Greet, listener, { id = "id" })
      emitter:emit(Greet.new("Hi"))
      assert.equals(1, #messages)
      assert.equals("Hi", messages[1])

      emitter:off(Greet, "id")
      emitter:emit(Greet.new("Hi"))
      assert.equals(1, #messages)
    end)

    it("can unsubscribe multiple by id", function()
      local messages = {}
      local emitter = Emitter.new()
      local listener = function(greet)
        table.insert(messages, greet.name)
      end
      emitter:on(Greet, listener, { id = "id" })
      emitter:on(Greet, listener, { id = "id" })
      emitter:emit(Greet.new("Hi"))

      assert.equals(2, #messages)
      assert.equals("Hi", messages[1])
      assert.equals("Hi", messages[2])

      emitter:off(Greet, "id")
      emitter:emit(Greet.new("Hi"))
      assert.equals(2, #messages)
    end)
  end)

  describe("forwards events", function()
    it("forwards events to an emitter", function()
      local messages = {}
      local forwarded = {}

      local emitter = Emitter.new()
      local forward = Emitter.new()

      emitter:on(Greet, function(greet)
        table.insert(messages, greet.name)
      end)

      forward:on(Greet, function(greet)
        table.insert(forwarded, greet.name)
      end)

      emitter:startForwarding(forward)
      emitter:emit(Greet.new("Hi"))

      assert.equals(1, #messages)
      assert.equals("Hi", messages[1])
      assert.equals(1, #forwarded)
      assert.equals("Hi", forwarded[1])

      forward:emit(Greet.new("Hi"))

      assert.equals(1, #messages)
      assert.equals(2, #forwarded)

      emitter:stopForwarding(forward)
      emitter:emit(Greet.new("Hello"))

      assert.equals(2, #messages)
      assert.equals("Hello", messages[2])
      assert.equals(2, #forwarded)
    end)
  end)
end)
