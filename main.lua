JUMPKEY = " "

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
local state = 0

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
local forestb = Music("forestb.ogg")
local forestc = Music("forestc.ogg")
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
		Setup()
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
local jumptimer = 0
local isjumping = false
local gametimer = 0

local currentxp = 0
local collided = false
local currentlevel = 1

function game_draw()
	local jumpheight = 0
	if isjumping then
		jumpheight = 210 -- *math.sin(3.14*jumptimer)
	else
		jumpheight = 0
	end
    Draw(gamebkg, 0,0)
	Draw(player, 72,300 - jumpheight)
	
	-- jumpheight less than 60 = player collide with stone & x between -10 and 160
	local stonepos = 0
	-- 0.68 = player placing
	stonepos = from01(-256, wrap01(gametimer-0.38), 800)
	Draw(stone, stonepos, 340)
	
	local col = false
	if jumpheight < 60 and stonepos > -1 and stonepos < 160 then
		col = true
	else
		col = false
	end
	
	if col then
		love.graphics.print("Collision!", 400, 300)
		if collided == false then
			collided = true
			Play(test)
		end
	end
	
	-- hud
	love.graphics.printf("Experience: " .. currentxp .. " & Level: " .. currentlevel, 0, 0, 780, "right")
end
function game_onkey(key)
end
function game_update(dt)
	gametimer = gametimer - dt * (90/60)
	if gametimer < 0 then
		gametimer = gametimer + 1
		if collided == false then
			currentxp = currentxp + 1
			if currentxp >= 20 then
				currentxp = 0
				currentlevel = currentlevel + 1
				levelmusic()
			end
		end
		collided = false
	end
	
	if love.keyboard.isDown(JUMPKEY) then
		if jumptimer < 0.2 then
			jumptimer = jumptimer + dt
			isjumping = true
		else
			isjumping = false
		end
	else
		isjumping = false
		jumptimer = 0
	end
end
function game_setup()
	Play(foresta)
	Play(forestb)
	Play(forestc)
	foresta:setVolume(0)
	forestb:setVolume(0)
	forestc:setVolume(0)
	levelmusic()
end
function levelmusic()
	foresta:setVolume(0)
	forestb:setVolume(0)
	forestc:setVolume(0)
	
	if currentlevel == 1 then
		foresta:setVolume(1)
	elseif currentlevel == 2 then
		forestb:setVolume(1)
	else
		forestc:setVolume(1)
	end
end



-----------------------------------------------------------------------------------------
function Setup()
	if state == 0 then
		title_setup()
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