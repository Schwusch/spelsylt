local imageFile
local frames = {}

local activeFrame
local currentFrame = 1
function love.load()
    imageFile = love.graphics.newImage("assets/idle.png")
    frames[1] = love.graphics.newQuad(0,0,100,100,imageFile:getDimensions())
    frames[2] = love.graphics.newQuad(100,0,100,100,imageFile:getDimensions())
    frames[3] = love.graphics.newQuad(200,0,100,100,imageFile:getDimensions())
    frames[4] = love.graphics.newQuad(300,0,100,100,imageFile:getDimensions())
    activeFrame = frames[currentFrame]
    print(select(4,activeFrame:getViewport())/2)
end

function love.draw()
    --love.graphics.draw(imageFile,activeFrame)
--[[    love.graphics.draw(imageFile,activeFrame,
        love.graphics.getWidth()/2 - (select(3,activeFrame:getViewport())/2) * 2,
        love.graphics.getHeight()/2 - (select(4,activeFrame:getViewport())/2) * 2,

            0,
            2,
            2)
]]--
    -- draw image 4x size centered
    love.graphics.draw(imageFile,activeFrame,
        love.graphics.getWidth()/2 - ({activeFrame:getViewport()})[3]/2,
        love.graphics.getHeight()/2 - ({activeFrame:getViewport()})[4]/2,
        0,
        1,
        1)
end

local elapsedTime = 0
function love.update(dt)
    elapsedTime = elapsedTime + dt

    if(elapsedTime > 1/10) then
        if(currentFrame < 4) then
            currentFrame = currentFrame + 1
        else
        currentFrame = 1
        end
        activeFrame = frames[currentFrame]
        elapsedTime = 0
        end
end
