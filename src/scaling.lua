
local scaling = {
  pixel_perfect = true
}

VIEW_W = 0
VIEW_H = 0
WINDOW_SCALE = 0
WINDOW_W = 0
WINDOW_H = 0

WORLD_DIAMETER2 = WORLD_W*WORLD_W + WORLD_H*WORLD_H
WORLD_DIAMETER = math.sqrt(WORLD_DIAMETER2)

DESKTOP_W = nil
DESKTOP_H = nil

local _reset = function()
  -- set resolution
  WINDOW_W = love.graphics.getWidth()
  WINDOW_H = love.graphics.getHeight()
  if not DESKTOP_W or not DESKTOP_H then
  	DESKTOP_W = WINDOW_W
		DESKTOP_H = WINDOW_H
  end
  log:write("Native resolution:", WINDOW_W, "*", WINDOW_H)

  local step = (scaling.pixel_perfect and 1) or 0.01
  WINDOW_SCALE = step
	if WORLD_W <= WINDOW_W or WORLD_H <= WINDOW_H then
	  while (WORLD_W*(WINDOW_SCALE + step) < WINDOW_W) 
	  and (WORLD_H*(WINDOW_SCALE + step) < WINDOW_H)
	  do
	    WINDOW_SCALE = WINDOW_SCALE + step
	  end
	else
	  repeat
	  	WINDOW_SCALE = WINDOW_SCALE - 0.1*step
	  until ((WORLD_W*WINDOW_SCALE <= WINDOW_W)
	  and (WORLD_H*WINDOW_SCALE <= WINDOW_H))
	end
  VIEW_W = WORLD_W*WINDOW_SCALE
  VIEW_H = WORLD_H*WINDOW_SCALE

	log:write("Scaling factor = " .. tostring(WINDOW_SCALE))
  log:write("View size = " .. tostring(VIEW_W) ..  "*" .. tostring(VIEW_H))
end

scaling.reset = _reset

scaling.scaleMouse = function(x, y)
	
end

return scaling