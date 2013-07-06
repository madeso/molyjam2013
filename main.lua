function Img(p)
	local r
	r = love.graphics.newImage(p)
	return r
end

local Draw = love.graphics.draw

local title = Img("title.png")
local gamebkg = Img("world.png")
local player = Img("player.png")
local stone = Img("stone.png")

function title_draw()
	Draw(title, 0,0)
end

function game_draw()
    Draw(gamebkg, 0,0)
	Draw(player, 72,300)
	Draw(stone, 400,340)
end

function love.draw()
    game_draw()
end