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

function to01(a,x,b)
	return x-a/(b-a)
end

function from01(a,x,b)
	return (b-a)*x + a
end

function wrap01(x)
	local r
	r = x
	while r > 1 do
		r = r - 1
	end
	while r < 0 do
		r = r + 1
	end
	return r
end

-----------------------------------------------------------------------------------------
-- Startup
local state = 1

function love.load()
	love.graphics.setFont(love.graphics.newFont("AlexBrush-Regular-OTF.otf", 30))
	Setup()
end

-----------------------------------------------------------------------------------------
-- Aliases
local Draw = love.graphics.draw
local Play = love.audio.play
local PauseAllAudio = love.audio.pause

-- Sounds
local titlemusic = Music("title.ogg")
local foresta = Music("foresta.ogg")
local test = Sfx("test.ogg")

-- Graphics
local title = Img("title.png")
local gamebkg = Img("world.png")
local player = Img("player.png")
local stone = Img("stone.png")

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
function title_update(dt)
end
function title_setup()
	Play(titlemusic)
end


-----------------------------------------------------------------------------------------

function Stone()
	local s
	s = {}
	s.pos = 600
	return s
end
local stones = {}
local jumptimer = -1
local gametimer = 0

local currentxp = 0
local currentlevel = 1

function game_draw()
	local jumpheight = 0
	if jumptimer > 0 then
		jumpheight = 210*math.sin(3.14*jumptimer)
	else
		jumpheight = 0
	end
    Draw(gamebkg, 0,0)
	Draw(player, 72,300 - jumpheight)
	-- jumpheight less than 60 = player collide with stone & x between -10 and 160
	local stonepos = 0
	stonepos = from01(-256, wrap01(gametimer - 0.8), 800)
	Draw(stone, stonepos,340)
	
	love.graphics.printf("Experience: " .. currentxp .. " & Level: " .. currentlevel, 0, 0, 780, "right")
end
function game_onkey(key)
	if key == " " then
		if jumptimer < 0 then
			jumptimer = 1
		end
	end
end
function game_update(dt)
	gametimer = gametimer - dt / 2
	if gametimer < 0 then
		gametimer = gametimer + 1
		Play(test)
	end
	
	if jumptimer > 0 then
		jumptimer = jumptimer - dt*2
	else
		jumptimer = -1
	end
end
function game_setup()
	Play(foresta)
end




-----------------------------------------------------------------------------------------
function Setup()
	if state == 0 then
		tile_setup()
	elseif state == 1 then
		game_setup()
	else
		print("unknown gamestate " .. state)
	end
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
		print("unknown gamestate " .. state)
	end
end

function love.update(dt)
   if state == 0 then title_update(dt)
	elseif state == 1 then game_update(dt)
	else
		print("unknown gamestate " .. state)
	end
end