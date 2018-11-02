lovebird = require "lovebird"
local imageFile
local frames = {}

local activeFrame
local currentFrame = 1
function love.load()
    world = love.physics.newWorld( 0, 10, true )
    
    animations = {
        newAnimation(love.graphics.newImage("assets/idle.png"), 100, 100, 1), 
        newAnimation(love.graphics.newImage("assets/enemy-walking.png"), 100, 100, 1)
    }
    bodies = {
        love.physics.newBody(world, 50, 50, 'dynamic'), 
        love.physics.newBody(world, love.graphics.getWidth() - 150, love.graphics.getHeight() - 150, 'dynamic')
    }
    love.graphics.setBackgroundColor(1,1,1,1)
end

function love.draw()
    for k, v in pairs(animations) do
        drawAnimation(v, bodies[k])
    end
end

local elapsedTime = 0
function love.update(dt)
    lovebird.update()
    world:update(dt)
    for k, v in pairs(animations) do
        updateAnimation(v, dt)
    end
end

function drawAnimation(animation, body)
    x, y = body:getPosition()
    local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], 
        x,
        y,
        0,
        1,
        1)
end

function updateAnimation(animation, dt)
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
    end
end

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};
 
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end