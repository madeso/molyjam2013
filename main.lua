function Img(p)
	local r
	r = love.graphics.newImage(p)
	return r
end

local Draw = love.graphics.draw

local title = Img("title.png")

function love.draw()
    Draw(title, 0,0)
end