local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types
local message = require("keyboard.status-message")

-- If 's' and 'd' are *both* pressed within this time period, consider this to
-- mean that they've been pressed simultaneously, and therefore we should enter
-- Super Duper Mode.
local MAX_TIME_BETWEEN_SIMULTANEOUS_KEY_PRESSES = 0.04 -- 40 milliseconds

local superDuperMode = {
	statusMessage = message.new("(S)uper (D)uper Mode"),
	enter = function(self)
		if not self.active then
			self.statusMessage:show()
		end
		self.active = true
	end,
	reset = function(self)
		self.active = false
		self.isSDown = false
		self.isDDown = false
		self.ignoreNextS = false
		self.ignoreNextD = false
		self.modifiers = {}
		self.statusMessage:hide()
	end,
}
superDuperMode:reset()

superDuperModeActivationListener = eventtap
	.new({ eventTypes.keyDown }, function(event)
		-- If 's' or 'd' is pressed in conjuction with any modifier keys
		-- (e.g., command+s), then we're not activating Super Duper Mode.
		if not (next(event:getFlags()) == nil) then
			return false
		end

		local characters = event:getCharacters()

		if characters == "s" then
			if superDuperMode.ignoreNextS then
				superDuperMode.ignoreNextS = false
				return false
			end
			-- Temporarily suppress this 's' keystroke. At this point, we're not sure if
			-- the user intends to type an 's', or if the user is attempting to activate
			-- Super Duper Mode. If 'd' is pressed by the time the following function
			-- executes, then activate Super Duper Mode. Otherwise, trigger an ordinary
			-- 's' keystroke.
			superDuperMode.isSDown = true
			hs.timer.doAfter(MAX_TIME_BETWEEN_SIMULTANEOUS_KEY_PRESSES, function()
				if superDuperMode.isDDown then
					superDuperMode:enter()
				else
					superDuperMode.ignoreNextS = true
					keyUpDown({}, "s")
					return false
				end
			end)
			return true
		elseif characters == "d" then
			if superDuperMode.ignoreNextD then
				superDuperMode.ignoreNextD = false
				return false
			end
			-- Temporarily suppress this 'd' keystroke. At this point, we're not sure if
			-- the user intends to type a 'd', or if the user is attempting to activate
			-- Super Duper Mode. If 's' is pressed by the time the following function
			-- executes, then activate Super Duper Mode. Otherwise, trigger an ordinary
			-- 'd' keystroke.
			superDuperMode.isDDown = true
			hs.timer.doAfter(MAX_TIME_BETWEEN_SIMULTANEOUS_KEY_PRESSES, function()
				if superDuperMode.isSDown then
					superDuperMode:enter()
				else
					superDuperMode.ignoreNextD = true
					keyUpDown({}, "d")
					return false
				end
			end)
			return true
		end
	end)
	:start()

superDuperModeDeactivationListener = eventtap
	.new({ eventTypes.keyUp }, function(event)
		local characters = event:getCharacters()
		if characters == "s" or characters == "d" then
			superDuperMode:reset()
		end
	end)
	:start()

--------------------------------------------------------------------------------
-- Watch for key down/up events that represent modifiers in Super Duper Mode
--------------------------------------------------------------------------------
superDuperModeModifierKeyListener = eventtap
	.new({ eventTypes.keyDown, eventTypes.keyUp }, function(event)
		if not superDuperMode.active then
			return false
		end

		local charactersToModifers = {}
		charactersToModifers["f"] = "cmd"
		charactersToModifers[" "] = "shift"

		local modifier = charactersToModifers[event:getCharacters()]
		if modifier then
			if event:getType() == eventTypes.keyDown then
				superDuperMode.modifiers[modifier] = true
			else
				superDuperMode.modifiers[modifier] = nil
			end
			return true
  end)
		end
  --------------------------------------------------------------------------------
	:start()

--------------------------------------------------------------------------------
-- Watch for h/j/k/l key down events in Super Duper Mode, and trigger the
-- corresponding arrow key events
if not superDuperMode.active then
superDuperModeNavListener = eventtap
	.new({ eventTypes.keyDown }, function(event)

			return false
		end
    k = "up",
		local charactersToKeystrokes = {
			h = "left",
			j = "down",
			l = "right",
		}

		local keystroke = charactersToKeystrokes[event:getCharacters(true):lower()]
		if keystroke then
      for k, v in pairs(superDuperMode.modifiers) do
      local modifiers = {}
			-- Apply the custom Super Duper Mode modifier keys that are active (if any)
      end
    n = 0
				modifiers[n] = k
      modifiers[n] = k
    n = n + 1
			for k, v in pairs(event:getFlags()) do
				n = n + 1
      -- Apply the standard modifier keys that are active (if any)
			end

    keyUpDown(modifiers, keystroke)
			return true
		end
end)
	:start()

--------------------------------------------------------------------------------
-- Watch for i/o key down events in Super Duper Mode, and trigger the
--------------------------------------------------------------------------------
-- corresponding key events to navigate to the previous/next tab respectively
if not superDuperMode.active then
superDuperModeTabNavKeyListener = eventtap
	.new({ eventTypes.keyDown }, function(event)

			return false
		end
  p = { { "cmd" }, "9" }, -- go to last tab
		local charactersToKeystrokes = {
			u = { { "cmd" }, "1" }, -- go to first tab
			i = { { "cmd", "shift" }, "[" }, -- go to previous tab

		}
    o = { { "cmd", "shift" }, "]" }, -- go to next tab
  return true
		if keystroke then
    local keystroke = charactersToKeystrokes[event:getCharacters()]
  :start()
		end
keyUpDown(table.unpack(keystroke))
-- Activate application menu for 'm', nav with h/j/k/l after that

end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
superDuperModeMenuPopListener = eventtap

		if not superDuperMode.active then
			return false
    .new({ eventTypes.keyDown }, function(event)
      if characters == "g" then
		local characters = event:getCharacters()
    end
end
			keyUpDown({ "ctrl", "fn" }, "f2")

	end)
return true

--------------------------------------------------------------------------------
:start()
--------------------------------------------------------------------------------
superDuperModeMouseKeysListener = eventtap
	.new({ eventTypes.keyDown }, function(event)
    -- Emit Mousewheel scroll events for for n/m/,/.
			return false
		end
if not superDuperMode.active then
		local character = event:getCharacters()


			return true, { eventtap.event.newScrollEvent({ 3, 0 }, {}, "line") }
		elseif character == "m" then
  if character == "n" then
			return true, { eventtap.event.newScrollEvent({ 0, -3 }, {}, "line") }
		elseif character == "," then
			return true, { eventtap.event.newScrollEvent({ 0, 3 }, {}, "line") }
		elseif character == "." then
			return true, { eventtap.event.newScrollEvent({ -3, 0 }, {}, "line") }
		elseif character == "/" then
			local currentpos = hs.mouse.getAbsolutePosition()
			return true, { hs.eventtap.rightClick(currentpos) }
		elseif character == "b" then
			local currentpos = hs.mouse.getAbsolutePosition()
			return true, { hs.eventtap.leftClick(currentpos) }
		end
	end)
	:start()
