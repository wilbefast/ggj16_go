--[[
(C) Copyright 2016 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

--[[------------------------------------------------------------
GLOBALS
--]]------------------------------------------------------------

local MUTE = true
local DEBUG = false
local MAX_DT = 1/30
local SAFE_MODE = false
local SCREENSHOT_KEY = "x"
local CAPTURE_SCREENSHOT = false
local NO_SHAKE_ON_SCREENSHOT = true

TILE_W = 32
TILE_H = 32
WORLD_N_TILE_ACROSS = 8
WORLD_N_TILE_DOWN = 8
WORLD_W = WORLD_N_TILE_ACROSS*TILE_W        -- 384
WORLD_H = (WORLD_N_TILE_DOWN + 2)*TILE_H    -- 448

numerals = {
  "I",
  "II",
  "III",
  "IV",
  "V",
  "V+",
  "V+",
  "V+"
}

--[[------------------------------------------------------------
LOVE CALLBACKS
--]]------------------------------------------------------------

function love.load(arg)

  -- "Hump" library
  gamestate = require("hump/gamestate")
  Class = require("hump/class")
  Vector = require("hump/vector-light")

  -- "Unrequited" library
  babysitter = require("unrequited/babysitter")
  useful = require("unrequited/useful")
  audio = require("unrequited/audio")
  log = require("unrequited/log")
  log:setLength(21)
  Controller = require("unrequited/Controller")
  CollisionGrid = require("unrequited/CollisionGrid")

  -- resources
  -- ... fonts
  fontSmall = love.graphics.newFont("assets/ttf/alagard.ttf", 16)
  fontMedium = love.graphics.newFont("assets/ttf/alagard.ttf", 24)
  fontLarge = love.graphics.newFont("assets/ttf/alagard.ttf", 32)
  love.graphics.setFont(fontMedium)
  -- ...images
  pentagram = love.graphics.newImage("assets/png/pentagram.png")
  tile_outline = love.graphics.newImage("assets/png/tile.png")
  cursor = love.graphics.newImage("assets/png/cursor.png")

  -- game-specific code
  scaling = require("scaling")
  title = require("gamestates/title")
  ingame = require("gamestates/ingame")

	-- set timestamp
	timestamp = useful.getTimestamp()

	-- startup logs
	log.print = true
	log:write("Starting 'Ryte'!")

	-- set scaling based on resolution
	scaling.reset()

  -- set interpolation
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineStyle("rough", 1)

  -- initialise random
  math.randomseed(os.time())

  -- no mouse
  love.mouse.setVisible(false)

  -- save directory
  love.filesystem.setIdentity("gg16_go")

  -- window title
  love.window.setTitle("Ryte")
  
  -- window icon
  love.window.setIcon(love.image.newImageData("assets/png/icon.png"))

  -- clear colour
  love.graphics.setBackgroundColor(0, 0, 0)

  -- go to the initial gamestate
  gamestate.switch(title)
end

function love.resize(w, h)
  -- set scaling based on resolution
  scaling.reset(w, h)
end

function love.focus(f)
  gamestate.focus(f)
end

function love.quit()
  gamestate.quit()
end

function love.keypressed(key, uni)
  if key=="o" then
    DEBUG = not DEBUG
  elseif key=="x" then
    CAPTURE_SCREENSHOT = (not CAPTURE_SCREENSHOT)
  end

  gamestate.keypressed(key, uni)
  Controller.keypressed(key, uni)
end

function love.keyreleased(key, uni)
  gamestate.keyreleased(key, uni)
  Controller.keyreleased(key, uni)
end

function love.mousepressed(x, y, button)
  x = (x - (WINDOW_W - VIEW_W)*0.5)/WINDOW_SCALE
  y = (y - (WINDOW_H - VIEW_H)*0.5)/WINDOW_SCALE
  gamestate.mousepressed(x, y, button)
  Controller.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  x = (x - (WINDOW_W - VIEW_W)*0.5)/WINDOW_SCALE
  y = (y - (WINDOW_H - VIEW_H)*0.5)/WINDOW_SCALE
  gamestate.mousereleased(x, y, button)
  Controller.mousereleased(x, y, button)
end

function love.joystickpressed(joystick, button)
  gamestate.joystickpressed(joystick, button)
  Controller.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
  gamestate.joystickreleased(joystick, button)
  Controller.joystickreleased(joystick, button)
end

function love.gamepadpressed(joystick, button)
  Controller.gamepadpressed(joystick, button)
  gamestate.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
  Controller.gamepadreleased(joystick, button)
  gamestate.gamepadreleased(joystick, button)
end

local __unsafeUpdate = function()
  local dt
  if CAPTURE_SCREENSHOT then
    dt = 1/30
  else
    dt = math.min(MAX_DT, love.timer.getDelta())
  end

  Controller.updateAll(dt)
  gamestate.update(dt)
  babysitter.update(dt)
  audio:update(dt) 
end

function love.update(dt)
  if SAFE_MODE then
    local status, err = xpcall(__unsafeUpdate, debug.traceback)
    if not status then
      print(err)
    end
  else
    __unsafeUpdate()
  end
end

local __unsafeDraw = function()

  love.graphics.push()

  	-- scaling
  	love.graphics.scale(WINDOW_SCALE, WINDOW_SCALE)

    -- playable area is the centre sub-rect of the screen
    love.graphics.translate((WINDOW_W - VIEW_W)*0.5/WINDOW_SCALE, (WINDOW_H - VIEW_H)*0.5/WINDOW_SCALE)

  	love.graphics.push()
	  	-- apply shake to top-level matrix (not canvas matrices)
      local shake_x, shake_y = 0, 0
	    if not NO_SHAKE_ON_SCREENSHOT 
	    or not CAPTURE_SCREENSHOT
	    then
        shake_x, shake_y = useful.signedRand(shake), useful.signedRand(shake)
	      love.graphics.translate(shake_x, shake_y)
	    end

	  love.graphics.pop() -- pop screenshake

    -- background
    love.graphics.setColor(18, 25, 25)
    love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)

    -- outline
    love.graphics.setColor(255, 204, 127)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", 0, 0, WORLD_W, WORLD_H)
    love.graphics.setLineWidth(1)

    -- draw any other state specific stuff
    gamestate.draw(0, 0)

  love.graphics.pop() -- pop offset

  -- capture GIF footage
  if CAPTURE_SCREENSHOT then
    useful.recordGIF()
  end

  -- draw logs
  if DEBUG then
    log:draw(16, 48)
  end
end

function love.draw()
  if SAFE_MODE then
    local status, err = xpcall(__unsafeDraw, debug.traceback)
    if not status then
      print(err)
      love.graphics.setCanvas(nil)
    end
  else
    __unsafeDraw()
  end
end
