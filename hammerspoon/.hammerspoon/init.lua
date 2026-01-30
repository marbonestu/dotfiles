-- Hammerspoon config: http://www.hammerspoon.org/go/
local application = require("hs.application")
local hotkey = require("hs.hotkey")
-- local Grid = require "grid"

hs.loadSpoon("Lunette")

customBindings = {
	leftHalf = {
		{ { "cmd", "shift" }, "h" },
	},
	rightHalf = {
		{ { "cmd", "shift" }, "l" },
	},
	bottomHalf = {
		{ { "cmd", "shift" }, "j" },
	},
	topHalf = {
		{ { "cmd", "shift" }, "k" },
	},
	fullScreen = {
		{ { "cmd", "shift" }, "o" },
	},
	nextDisplay = {
		{ { "cmd", "alt", "control" }, "l" },
	},
	prevDisplay = {
		{ { "cmd", "alt", "control" }, "h" },
	},
	undo = false,
	redo = false,
}

spoon.Lunette:bindHotkeys(customBindings)

local mashApps = {
	"cmd",
}

-- Slack-specific app launcher (since I keep it "peeked" to the side by default)
function showSlack()
	local appName = "Microsoft Teams"
	local app = application.find(appName)
	application.launchOrFocus(appName)

	if app and application.isRunning(app) then
		Grid.topleft()
	end
end

-- App Shortcuts
hotkey.bind(mashApps, "1", function()
	application.launchOrFocus("Ghostty")
end)
hotkey.bind(mashApps, "2", function()
	application.launchOrFocus("Firefox")
end)
hotkey.bind(mashApps, "3", showSlack)

-- TODO: add condition based on workspace
hotkey.bind(mashApps, "4", function()
	application.launchOrFocus("Microsoft Outlook")
end)
hotkey.bind(mashApps, "5", function()
	application.launchOrFocus("zoom.us")
end)
hotkey.bind(mashApps, "7", function()
	application.launchOrFocus("Cursor")
end)

-- function moveWindowToDisplay(d)
--   return function()
--     local displays = hs.screen.allScreens()
--     print(displays)
--     local win = hs.window.focusedWindow()
--     win:moveToScreen(displays[d], false, true)
--   end
-- end

-- hs.hotkey.bind({ "cmd" }, "9", moveWindowToDisplay(1))
-- hs.hotkey.bind({ "cmd" }, "7", moveWindowToDisplay(2))
-- hs.hotkey.bind({ "cmd" }, "8", moveWindowToDisplay(3))

-- Reload automatically on config changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
hs.alert("Hammerspoon is locked and loaded", 1)
