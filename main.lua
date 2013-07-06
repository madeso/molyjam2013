function Img(p)
	local r
	r = love.graphics.newImage(p)
	return r
end

function Music(p)
	local s
	s = love.audio.newSource(p, "stream")
	return s
end

function Sfx(p)
	local s
	s = love.audio.newSource(p, "static")
	return s
end

-- Aliases
local Draw = love.graphics.draw
local Play = love.audio.play
local PauseAllAudio = love.audio.pause

-- Sounds
local titlemusic = Music("title.ogg")

-- Graphics
local title = Img("title.png")
local gamebkg = Img("world.png")
local player = Img("player.png")
local stone = Img("stone.png")

local state = 0

Play(titlemusic)

-----------------------------------------------------------------------------------------
function title_onkey(key)
	if key == " " then
		PauseAllAudio()
		state = 1
	end
end
function title_draw()
	Draw(title, 0,0)
end

function game_draw()
    Draw(gamebkg, 0,0)
	Draw(player, 72,300)
	Draw(stone, 400,340)
end
function game_onkey(key)
end

function love.draw()
	if state == 0 then title_draw()
	elseif state == 1 then game_draw()
	else
		love.graphics.print("unknown gamestate " .. state, 400, 300)
	end
end

function love.keyreleased(key)
   if key == "escape" then
      love.event.push("quit")   -- actually causes the app to quit
   end
   
   if state == 0 then title_onkey(key)
	elseif state == 1 then game_onkey(key)
	else
		love.graphics.print("unknown gamestate " .. state, 400, 300)
	end
end