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

--[[------------------------------------------------------------
Substates
--]]--

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
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
	gamestate.switch(ingame)
end

function state:gamepadpressed(joystick, button)
end

function state:update(dt)
end

function state:draw()
	love.graphics.setFont(fontHuge)
	love.graphics.printf("Toil and trouble", WORLD_W*0.25, WORLD_H*0.3, WORLD_W*0.5, "center")
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state