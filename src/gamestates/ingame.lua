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
    self.combos = {}
    for comboSize = 1, math.min(WORLD_N_TILE_ACROSS, WORLD_N_TILE_DOWN) do
      self.combos[comboSize] = {}
    end
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

function Player:bindColour(a)
  love.graphics.setColor(self.red, self.green, self.blue, a or 255)
end


--[[------------------------------------------------------------
TILE CLASS
--]]------------------------------------------------------------

local Tile = Class
{
  types = {},

  w = TILE_W,
  h = TILE_H,

  init = function(self)
    self.influence = {}
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
  else
    for i, player in ipairs(Player) do
      if self.influence[player] then
        player:bindColour()
        --love.graphics.print(tostring(self.influence[player]), self.x, self.y + (i - 1)*16)
      end
    end
    local mostInfluential, influenceLead = self:mostInfluential()
    if mostInfluential then
      mostInfluential:bindColour(128)
      love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
      mostInfluential:bindColour()
      love.graphics.printf(
        tostring(influenceLead), self.x + TILE_W*0.4, self.y + TILE_H*0.3, TILE_W*0.3)
    end
    useful.bindWhite()
  end
  useful.bindWhite(128)
  love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
  useful.bindWhite()

  -- if self:isFrontier() then
  --   love.graphics.circle("line", self.x + TILE_W/2, self.y + TILE_H/2, 8)
  -- end

end

function Tile:mostInfluential()
  if self.owner then
    return self.owner
  end
  local second_most_influence = 0
  local most_influence, most_influential = 0, nil
  for i, player in ipairs(Player) do
    local influence = self.influence[player] or 0
    if influence > most_influence then
      second_most_influence = most_influence
      most_influence, most_influential = influence, player
    elseif influence == most_influence then
      most_influential = nil
    elseif influence > second_most_influence then
      second_most_influence = influence
    end
  end
  return most_influential, most_influence - second_most_influence, most_influence
end

function Tile:hasNeighbourSuchThat(f)
  for i, otherTile in ipairs(self.neighbours8) do
    if otherTile then
      local val = f(otherTile)
      if val then
        return val
      end
    end
  end
end

function Tile:isFrontier()
  if self.owner then
    return false
  else
    local mostInfluential, influenceLead, mostInfluence = self:mostInfluential()
    if not mostInfluential then
      return true
    elseif mostInfluence >= 5 then
      return false
    else
      return self:hasNeighbourSuchThat(function(otherTile)

        return (not otherTile.owner) and otherTile:mostInfluential() ~= mostInfluential
      end)
    end
  end
end

--[[------------------------------------------------------------
INGAME GAMESTATE
--]]------------------------------------------------------------

local state = gamestate.new()

local grid
local currentPlayer
local isEnding

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
  isEnding = false
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
  local isValidMove = function(tile)
    if not tile then
      return false
    elseif tile.owner then
      return false
    else
      local currentPlayerInfluence = tile.influence[currentPlayer] or 0
      for i, otherPlayer in ipairs(Player) do
        if otherPlayer ~= currentPlayer then
          local otherPlayerInfluence = tile.influence[otherPlayer] or 0
          if currentPlayerInfluence < otherPlayerInfluence then
            return false
          end
        end
      end
      return true
    end
  end

  local isEndCondition = function()
    return not grid:map(function(tile)
      return tile:isFrontier()
    end)
  end

  local setTileOwner
  setTileOwner = function(tile, owner)

    -- set the owner
    tile.owner = owner

    -- propagate influence
    for i, neighbouringTile in ipairs(tile.neighbours8) do
      if neighbouringTile and not neighbouringTile.owner then
        neighbouringTile.influence[owner] = (neighbouringTile.influence[owner] or 0) + 1
      end
    end

    -- check for combos
    grid:map(function(comboStartTile)
      for comboSize, comboList in ipairs(owner.combos) do
        if not comboList[comboStartTile] then
          local isCombo = not grid:mapRectangle(comboStartTile.col, comboStartTile.row, comboSize + 1, comboSize + 1, 
          function(comboTile) 
            if not comboTile then
              return true
            elseif comboTile.owner ~= owner then
              return true
            else
              return false
            end
          end)
          if isCombo then
            comboList[comboStartTile] = true
            log:write(owner.name, "got a combo of size", comboSize + 1)
          end
        end
      end
    end)

    -- check for stalemate: fill out remaining tiles if so
    if not isEnding and isEndCondition() then
      isEnding = true
      grid:map(function(tile)
        if not tile.owner then
          local influential = tile:mostInfluential()
          if influential then
            setTileOwner(tile, influential)
          end
        end
      end)
    end
  end

  local t = grid:pixelToTile(x, y)
  if isValidMove(t) then
    -- set owner
    setTileOwner(t, currentPlayer)

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