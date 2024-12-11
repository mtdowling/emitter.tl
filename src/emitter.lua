







local Emitter = {ListenerConfig = {}, }















































































local LinkedList = {}




function LinkedList.append(list, node)
   if list.head == nil then
      list.head = node
      list.tail = node
   else
      list.tail.next = node
      node.prev = list.tail
      list.tail = node
   end
end

function LinkedList.prepend(list, node)
   if list.head == nil then
      list.head = node
      list.tail = node
   else
      list.head.prev = node
      node.next = list.head
      list.head = node
   end
end

function LinkedList.remove(list, node)
   if node.prev then
      (node.prev).next = node.next
   else
      list.head = node.next
   end
   if node.next then
      (node.next).prev = node.prev
   else
      list.tail = node.prev
   end
end












local DEFAULT_CONFIG = { id = "", position = "last" }
local EMITTER_MT = { __index = Emitter }

function Emitter.new()
   return setmetatable({
      _listeners = {},
      _forwarding = {},
   }, EMITTER_MT)
end

function Emitter:reset()
   self._listeners = {}
   self._forwarding = {}
end

function Emitter:on(event, listener, config)
   local list = self._listeners[event]
   if not list then
      list = {}
      self._listeners[event] = list
   end
   config = config or DEFAULT_CONFIG
   local node = { id = config.id or "", listener = listener }
   if config.position == "last" then
      LinkedList.append(list, node)
   else
      LinkedList.prepend(list, node)
   end
end

function Emitter:off(event, listener)
   local listeners = self._listeners[event]
   if not listeners then
      return
   elseif type(listener) == "string" then
      local node = listeners.head
      while node do
         if node.id == listener then
            LinkedList.remove(listeners, node)
         end
         node = node.next
      end
   else
      local node = listeners.head
      while node do
         if node.listener == listener then
            LinkedList.remove(listeners, node)
         end
         node = node.next
      end
   end
end

function Emitter:once(event, listener, config)
   local wrappedFunction
   wrappedFunction = function(e)
      self:off(event, wrappedFunction)
      listener(e)
   end
   self:on(event, wrappedFunction, config)
end

function Emitter:emit(event)
   local listeners = self._listeners[event.type]
   if listeners then
      local node = listeners.head
      while node do
         node.listener(event)
         node = node.next
      end
   end

   local node = self._forwarding.head
   while node do
      node.emitter:emit(event)
      node = node.next
   end
end

function Emitter:removeAllListeners(event)
   self._listeners[event] = nil
end

function Emitter:startForwarding(emitter)
   local node = { emitter = emitter }
   LinkedList.append(self._forwarding, node)
end

function Emitter:stopForwarding(emitter)
   local node = self._forwarding.head
   while node do
      if node.emitter == emitter then
         LinkedList.remove(self._forwarding, node)
         return
      end
      node = node.next
   end
end

return Emitter
