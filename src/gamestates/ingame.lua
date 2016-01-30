--[[
(C) Copyright 2014 William Dyce

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
TILE CLASS
--]]------------------------------------------------------------

local Tile = Class
{
  types = {},

  w = TILE_W,
  h = TILE_H,

  init = function(self)
  end,
}

--[[------------------------------------------------------------
Game loop
--]]--

function Tile:update(dt)
end

function Tile:draw()
  if self.owner then
    self.owner:bindColour()
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
    useful.bindWhite()
  end
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end


--[[------------------------------------------------------------
PLAYER OBJECT
--]]------------------------------------------------------------

local Player

Player = Class
{
  init = function(self, args)
    self.name = args.name
    self.red, self.green, self.blue = args.r, args.g, args.b
    table.insert(Player, self)
    self.index = #Player
  end
}
Player({
  name = "red",
  r = 255,
  g = 0,
  b = 0
})

Player({
  name = "blue",
  r = 0,
  g = 0,
  b = 255
})

function Player:bindColour()
  love.graphics.setColor(self.red, self.green, self.blue)
end

--[[------------------------------------------------------------
INGAME GAMESTATE
--]]------------------------------------------------------------

local state = gamestate.new()

local grid
local currentPlayer

--[[------------------------------------------------------------
Substates
--]]--

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	grid = CollisionGrid(Tile, TILE_W, TILE_H, WORLD_N_TILE_ACROSS, WORLD_N_TILE_DOWN)
  currentPlayer = Player[1]
end

function state:leave()
	grid = nil
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key == "escape" then
  	gamestate.switch(title)
  end
end

function state:mousepressed(x, y)
  local t = grid:pixelToTile(x, y)
  if t then
    -- set owner
    t.owner = currentPlayer

    -- next change
    local nextPlayerIndex = currentPlayer.index + 1
    if nextPlayerIndex > #Player then
      nextPlayerIndex = 1
    end
    currentPlayer = Player[nextPlayerIndex]
  end
end

function state:gamepadpressed(joystick, button)
end

function state:update(dt)
end

function state:draw()
	-- grid
  grid:draw()

  -- cursor
  local x, y = love.mouse.getPosition( )
  x = (x - (WINDOW_W - VIEW_W)*0.5)/WINDOW_SCALE
  y = (y - (WINDOW_H - VIEW_H)*0.5)/WINDOW_SCALE
  currentPlayer:bindColour()
  love.graphics.circle("fill", x, y, 6)
  useful.bindWhite()

end

--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state