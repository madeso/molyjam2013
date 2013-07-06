require("data")

-- Aliases
local Draw = love.graphics.draw
local PauseAllAudio = love.audio.pause
function Playx(x)
	x:rewind()
	love.audio.play(x)
end
local Play = love.audio.play

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
local state = STATEMENU

function SetState(x)
	PauseAllAudio()
	state = x
	Setup()
end

function love.load()
	love.graphics.setFont(love.graphics.newFont("AlexBrush-Regular-OTF.otf", 30))
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
	Setup()
end

-----------------------------------------------------------------------------------------

-- Sounds
local titlemusic = Music("music/title.ogg")
local foresta = Music("music/foresta.ogg")
local forestb = Music("music/forestb.ogg")
local forestc = Music("music/forestc.ogg")
foresta:setLooping(true)
forestb:setLooping(true)
forestc:setLooping(true)

local failmusic = Music("music/defeat.ogg")
local winmusic = Music("music/victory.ogg")

local test = Sfx("test.ogg")
local sfxhurt = Sfx("sfx/Hurt.ogg")
local sfxjump = Sfx("sfx/jump.ogg")
local sfxslash = Sfx("sfx/slash.ogg")
local sfxslide = Sfx("sfx/slide.ogg")

-- Graphics
local title = Img("title.png")
local winbg = Img("win.png")
local failbg = Img("fail.png")
local gamebkg = Img("world.png")
local player = Img("player.png")
local goblin = Img("goblin.png")
local playerslide = Img("playersliding.png")
local playerattack = Img("playerattack.png")
local stone = Img("stone.png")
local tree = Img("tree.png")
local heartgfx = Img("heart.png")

-----------------------------------------------------------------------------------------
function title_onkey(key)
	if key == " " then
		SetState(STATEGAME)
	end
end
function title_draw()
	Draw(title, 0,0)
end
function title_update(dt)
end
function title_setup()
	Playx(titlemusic)
end

-----------------------------------------------------------------------------------------
function win_onkey(key)
	if key == " " then
		SetState(STATEMENU)
	end
end
function win_draw()
	Draw(winbg, 0,0)
end
function win_update(dt)
end
function win_setup()
	Playx(winmusic)
end

-----------------------------------------------------------------------------------------
function fail_onkey(key)
	if key == " " then
		SetState(STATEMENU)
	end
end
function fail_draw()
	Draw(failbg, 0,0)
end
function fail_update(dt)
end
function fail_setup()
	Playx(failmusic)
end


-----------------------------------------------------------------------------------------

function Enemy()
	local s
	s = {}
	s.pos = 600
	return s
end
local enemies = {}

local leveldata = FORESTDATA
local levelindex = 1
local jumptimer = 0
local isjumping = false
local gametimer = 0
local enemytype = 1

local currentxp = 0
local collided = false
local currentlevel = 1
local jumpedstone = false
local health = MAXHEALTH

function game_logic()
	-- jumpheight less than 60 = player collide with stone & x between -10 and 160
	local enemypos = 0
	-- 0.68 = player placing
	-- was wrap01(gametimer-0.38)
	enemypos = from01(-256, gametimer, 800)
	local col = false
	if enemypos > -1 and enemypos < 160 then
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
	
	return jumpheight,enemypos,col,dojump
end

function game_draw()
	local jumpheight,enemypos,col,dojump = game_logic()
	Draw(gamebkg, 0,0)
	
	if enemytype == 1 then
		Draw(stone, enemypos, 340)
	elseif enemytype == 2 then
		Draw(tree, enemypos, 250)
	elseif enemytype == 3 then
		Draw(goblin, enemypos, 300)
	elseif enemytype == 4 then
		-- no enemy here
	else
		love.graphics.print("Unknown enemytype" .. enemytype, enemypos, 340)
	end
	
	if enemytype == 1 then
		Draw(player, 72,300 - jumpheight)
	elseif enemytype == 2 then
		if dojump then
			Draw(playerslide, 72,300)
		else
			Draw(player, 72,300)
		end
	elseif enemytype == 3 then
		if dojump then
			Draw(playerattack, 72,300)
		else
			Draw(player, 72,300)
		end
	elseif enemytype == 4 then
		-- no enemy here
		Draw(player, 72,300 - jumpheight)
	else
		love.graphics.print("Unknown enemytype" .. enemytype, 72, 300)
	end
	
	if collided then
		love.graphics.print("Bad!", INFOX, INFOY)
	end
	
	if jumpedstone then
		love.graphics.print("Good!", INFOX, INFOY)
	end
	
	if col then
		if jumpheight < 60 then
			if jumpedstone==false then
				if collided == false then
					if enemytype ~= 4 then
						collided = true
						Play(sfxhurt)
						
						if GODMODE == false then
							health = health - 1
							if health == 0 then
								SetState(STATEFAIL)
							end
						end
					end
				end
			end
		else
			-- jumping over the stone
			if collided == false then
				jumpedstone = true
				
				if enemytype == 1 then
					Play(sfxjump)
				elseif enemytype == 2 then
					Play(sfxslide)
				elseif enemytype == 3 then
					Play(sfxslash)
				elseif enemytype == 4 then
					Play(sfxjump)
				else
					print("Unknown enemytype" .. enemytype)
				end
			end
		end
	end
	
	-- hud
	love.graphics.printf("Experience: " .. currentxp .. " & Level: " .. currentlevel .. " - Debug: " .. levelindex, 0, 0, 780, "right")
	for i=1,health do
		Draw(heartgfx, HEARTX + (i-1)*SPACEBETWEENHEARTS, HEARTY)
	end
end
function game_onkey(key)
end
function game_update(dt)
	gametimer = gametimer - dt * (90/60)/2
	if gametimer < 0 then
		gametimer = gametimer + 1
		local leveltype
		if levelindex > leveldata:len() then
			enemytype = 4
			SetState(STATEWIN)
		else
			leveltype = string.sub(leveldata, levelindex,levelindex)
			if leveltype == "-" then
				enemytype = 2
			elseif leveltype == "o" then
				enemytype = 1
			elseif leveltype == "8" then
				enemytype = 3
			elseif leveltype == " " then
				enemytype = 4
			elseif leveltype == "r" then
				enemytype = math.random(3)
			else
				print("Unknown level character " .. leveltype)
				enemytype = 1
			end
		end
		
		levelindex = levelindex + 1
		
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
	elseif enemytype == 3 then
		currentactionkey = SWORDKEY
	elseif enemytype == 4 then
		currentactionkey = JUMPKEY
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
	leveldata = FORESTDATA
	levelindex = 1
	jumptimer = 0
	isjumping = false
	gametimer = 0
	enemytype = 1
	currentxp = 0
	collided = false
	currentlevel = 1
	jumpedstone = false
	health = MAXHEALTH

	Playx(foresta)
	Playx(forestb)
	Playx(forestc)
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
	if state == STATEMENU then title_setup()
	elseif state == STATEGAME then game_setup()
	elseif state == STATEWIN then win_setup()
	elseif state == STATEFAIL then fail_setup()
	else
		print("unknown gamestate " .. state)
	end
end

function love.draw()
	if state == STATEMENU then title_draw()
	elseif state == STATEGAME then game_draw()
	elseif state == STATEWIN then win_draw()
	elseif state == STATEFAIL then fail_draw()
	else
		love.graphics.print("unknown gamestate " .. state, 400, 300)
	end
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.push("quit")   -- actually causes the app to quit
	end
	
	if state == STATEMENU then title_onkey(key)
	elseif state == STATEGAME then game_onkey(key)
	elseif state == STATEWIN then win_onkey(key)
	elseif state == STATEFAIL then fail_onkey(key)
	else
		print("unknown gamestate " .. state)
	end
end

function love.update(dt)
	if state == STATEMENU then title_update(dt)
	elseif state == STATEGAME then game_update(dt)
	elseif state == STATEWIN then win_update(dt)
	elseif state == STATEFAIL then fail_update(dt)
	else
		print("unknown gamestate " .. state)
	end
end