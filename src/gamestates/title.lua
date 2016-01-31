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
TITLE GAMESTATE
--]]------------------------------------------------------------

local state = gamestate.new()

local anim_t
local anim_r
local anim_y

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	audio:set_music_volume(1)
	anim_t = 0
	anim_r = 0
end

function state:leave()
end

--[[------------------------------------------------------------
Callbacks
--]]--


function state:keypressed(key, uni)
  if key == "escape" then
  	return love.event.push("quit")
  end
end

function state:mousepressed()
	audio:play_sound("game_start")
	gamestate.switch(ingame)
end

function state:gamepadpressed(joystick, button)
end

function state:update(dt)
	anim_t = anim_t + dt
	if anim_t > 30 then
		anim_t = anim_t - 30
	end
	anim_r = anim_t/15*math.pi
	anim_y = WORLD_H*0.01*math.sin(anim_t/2*math.pi)
end

function state:draw()

	-- logo
	useful.bindWhite()
	love.graphics.draw(logo, WORLD_W*0.5, WORLD_H*0.475, anim_r, 1, 1, 64, 64)	
	
	love.graphics.setColor(255, 204, 127)

	-- text
	love.graphics.setFont(fontLarge)
	love.graphics.printf("RYTE", WORLD_W*0.1, WORLD_H*0.1 - anim_y, WORLD_W*0.8, "center")
	love.graphics.setFont(fontMedium)
	love.graphics.printf("@wilbefast", WORLD_W*0.1, WORLD_H*0.75 + anim_y, WORLD_W*0.8, "center")
	love.graphics.printf("#GGJ16", WORLD_W*0.1, WORLD_H*0.85 + anim_y, WORLD_W*0.8, "center")

  -- cursor
  if not HIDE_CURSOR then
	  local x, y = love.mouse.getPosition( )
	  x = (x - (WINDOW_W - VIEW_W)*0.5)/WINDOW_SCALE
	  y = (y - (WINDOW_H - VIEW_H)*0.5)/WINDOW_SCALE
	  love.graphics.draw(cursor, x, y)
	end

  useful.bindWhite()

end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state