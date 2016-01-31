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
TUTORIAL GAMESTATE
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
  	gamestate.switch(title)
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
end

function state:draw()

	love.graphics.setFont(fontMedium)

	-- 1x1 = 1 point
	love.graphics.draw(pentagram, WORLD_W*0.25, WORLD_H*0.1)
	love.graphics.printf("+1", WORLD_W*0.7, WORLD_H*0.1, WORLD_W*0.4, "left")

	-- 2x2 = 4 points
	love.graphics.draw(pentagram, WORLD_W*0.2, WORLD_H*0.3)
	love.graphics.draw(pentagram, WORLD_W*0.2 + 32, WORLD_H*0.3)
	love.graphics.draw(pentagram, WORLD_W*0.2, WORLD_H*0.3 + 32)
	love.graphics.draw(pentagram, WORLD_W*0.2 + 32, WORLD_H*0.3 + 32)
	love.graphics.printf("+4", WORLD_W*0.7, WORLD_H*0.35, WORLD_W*0.4, "left")

	-- 3x3 = 16 points
	love.graphics.draw(pentagram, WORLD_W*0.15, WORLD_H*0.6)
	love.graphics.draw(pentagram, WORLD_W*0.15 + 32, WORLD_H*0.6)
	love.graphics.draw(pentagram, WORLD_W*0.15 + 64, WORLD_H*0.6)
	love.graphics.draw(pentagram, WORLD_W*0.15, WORLD_H*0.6 + 32)
	love.graphics.draw(pentagram, WORLD_W*0.15 + 32, WORLD_H*0.6 + 32)
	love.graphics.draw(pentagram, WORLD_W*0.15 + 64, WORLD_H*0.6 + 32)
	love.graphics.draw(pentagram, WORLD_W*0.15, WORLD_H*0.6 + 64)
	love.graphics.draw(pentagram, WORLD_W*0.15 + 32, WORLD_H*0.6 + 64)
	love.graphics.draw(pentagram, WORLD_W*0.15 + 64, WORLD_H*0.6 + 64)
	love.graphics.printf("+16", WORLD_W*0.7, WORLD_H*0.7, WORLD_W*0.4, "left")
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state