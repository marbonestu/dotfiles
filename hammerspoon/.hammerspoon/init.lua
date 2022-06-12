-- Hammerspoon config: http://www.hammerspoon.org/go/
local application = require "hs.application"
local hotkey = require "hs.hotkey"
-- local Grid = require "grid"

hs.loadSpoon("Lunette")

customBindings = {
  leftHalf = {
    {{"cmd", "shift"}, "h"},
  },
  rightHalf = {
    {{"cmd", "shift"}, "l"},
  },
  bottomHalf = {
    {{"cmd", "shift"}, "j"},
  },
  topHalf = {
    {{"cmd", "shift"}, "k"},
  },
  fullScreen = {
    {{"cmd",  "shift"}, "o"},
  },
  nextDisplay = {
    {{"cmd", "alt", "control"}, "l"},
  },
  prevDisplay = {
    {{"cmd", "alt", "control"}, "h"},
  },
  undo = false,
  redo = false
}

spoon.Lunette:bindHotkeys(customBindings)

local mashApps = {
  'cmd',
}

-- local mashGeneral = {
--   'cmd',
--   'shift'
-- }

-- local movementGeneral = {
--   'alt',
--   'cmd'
-- }


-- function yabai(args)
--   hs.task.new("/usr/local/bin/yabai",nil, function(ud, ...)
--     print("stream", hs.inspect(table.pack(...)))
--     return true
--   end, args):start()

-- end

-- hs.hotkey.bind(movementGeneral, "j", function() yabai({"-m", "window", "--focus", "north"}) end)
-- hs.hotkey.bind(movementGeneral, "k", function() yabai({"-m", "window", "--focus", "south"}) end)
-- hs.hotkey.bind(movementGeneral, "h", function() yabai({"-m", "window", "--focus", "west"}) end)
-- hs.hotkey.bind(movementGeneral, "l", function() yabai({"-m", "window", "--focus", "east"}) end)

-- -- Disable window animations (janky for iTerm)
-- hs.window.animationDuration = 0

-- -- Window Management
-- hotkey.bind(mashGeneral, 'O', Grid.fullscreen)
-- hotkey.bind(mashGeneral, 'H', Grid.leftchunk)
-- hotkey.bind(mashGeneral, 'L', Grid.rightchunk)
-- hotkey.bind(mashGeneral, 'K', Grid.topHalf)
-- hotkey.bind(mashGeneral, 'J', Grid.bottomHalf)

-- hotkey.bind(mashGeneral, 'U', Grid.topleft)
-- hotkey.bind(mashGeneral, 'N', Grid.bottomleft)
-- hotkey.bind(mashGeneral, 'I', Grid.topright)
-- hotkey.bind(mashGeneral, 'M', Grid.bottomright)

-- -- Spotify
-- hotkey.bind(mashGeneral, 'P', hs.spotify.play)
-- hotkey.bind(mashGeneral, 'Y', hs.spotify.pause)
-- hotkey.bind(mashGeneral, 'T', hs.spotify.displayCurrentTrack)

-- Slack-specific app launcher (since I keep it "peeked" to the side by default)
function showSlack()
  local appName = 'Slack'
  local app = application.find(appName)
  application.launchOrFocus(appName)

  if (app and application.isRunning(app)) then
    Grid.topleft()
  end
end

-- App Shortcuts
hotkey.bind(mashApps, '7', function() application.launchOrFocus('kitty') end)
hotkey.bind(mashApps, '8', function() application.launchOrFocus('Google Chrome') end)
hotkey.bind(mashApps, '9', showSlack)

-- TODO: add condition based on workspace
hotkey.bind(mashApps, '0', function() application.launchOrFocus('Microsoft Outlook') end)
hotkey.bind(mashApps, '6', function() application.launchOrFocus('zoom.us') end)

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
hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', hs.reload):start()
hs.alert('Hammerspoon is locked and loaded', 1)
