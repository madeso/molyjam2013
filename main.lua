JUMPKEY = " "
SLIDEKEY = "down"

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
local PauseAllAudio = love.audio.pause
local Play = love.audio.play
--function Play(x)
--end

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
local playerslide = Img("playersliding.png")
local stone = Img("stone.png")
local tree = Img("tree.png")

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
local gametimer = 1
local enemytype = 1

local currentxp = 0
local collided = false
local currentlevel = 1
local jumpedstone = false

function game_logic()
	-- jumpheight less than 60 = player collide with stone & x between -10 and 160
	local stonepos = 0
	-- 0.68 = player placing
	-- was wrap01(gametimer-0.38)
	stonepos = from01(-256, gametimer, 800)
	local col = false
	if stonepos > -1 and stonepos < 160 then
		col = true
	else
		col = false
	end
	
	local dojump = isjumping
	
	if col and jumpedstone then
		dojump = true
	end
	
	local jumpheight = 0
	if dojump then
		jumpheight = 180
	else
		jumpheight = 0
	end
	
	return jumpheight,stonepos,col,dojump
end

function game_draw()
	local jumpheight,stonepos,col,dojump = game_logic()
	Draw(gamebkg, 0,0)
	
	if enemytype == 1 then
		Draw(stone, stonepos, 340)
	elseif enemytype == 2 then
		Draw(tree, stonepos, 250)
	else
		love.graphics.print("Unknown enemytype" .. enemytype, stonepos, 340)
	end
	
	if enemytype == 1 then
		Draw(player, 72,300 - jumpheight)
	elseif enemytype == 2 then
		if dojump then
			Draw(playerslide, 72,300)
		else
			Draw(player, 72,300)
		end
	else
		love.graphics.print("Unknown enemytype" .. enemytype, 72, 300)
	end
	
	if col then
		if jumpheight < 60 then
			if jumpedstone==false then
				love.graphics.print("Collision!", 400, 300)
				if collided == false then
					collided = true
					Play(test)
				end
			end
		else
			-- jumping over the stone
			jumpedstone = true
		end
	end
	
	-- hud
	love.graphics.printf("Experience: " .. currentxp .. " & Level: " .. currentlevel .. " - Debug: " .. enemytype, 0, 0, 780, "right")
end
function game_onkey(key)
end
function game_update(dt)
	gametimer = gametimer - dt * (90/60)
	if gametimer < 0 then
		gametimer = gametimer + 1
		enemytype = math.random(2)
		if collided == false then
			currentxp = currentxp + 1
			if currentxp >= 20 then
				currentxp = 0
				currentlevel = currentlevel + 1
				levelmusic()
			end
		end
		collided = false
		jumpedstone = false
	end
	
	local currentactionkey
	
	if enemytype == 1 then
		currentactionkey = JUMPKEY
	elseif enemytype == 2 then
		currentactionkey = SLIDEKEY
	else
		currentactionkey = "a"
		print("Unknown enemytype " .. enemytype)
	end
	
	if love.keyboard.isDown(currentactionkey) then
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