lovebird = require "libs/lovebird"
lurker = require "libs/lurker"
anim8 = require 'libs/anim8'
Input = require 'libs/Input'
sti = require 'libs/STI'
frames = {}
currentFrame = 1

function love.load()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Set world meter size (in pixels)
    love.physics.setMeter(21)

    -- Load a map exported to Lua from Tiled
    map = sti('assets/maps/map01.lua', { "box2d" })

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld( 0, 500, true )
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- Prepare collision objects
    map:box2d_init(world)

    map:removeLayer('GameObjects')

    for k, object in pairs(map.box2d_collision) do
        if type(k) == 'number' and object.object.name == "Player" then
            player = object
        elseif type(k) == 'number' and object.object.name == "Ground" then
            ground = object
        end
    end

    input = Input()
    input:bind('escape', function() love.event.push("quit") end)
end

local elapsedTime = 0
function love.update(dt)
    lovebird.update() -- Debugging at 127.0.0.1:8000
    lurker.update() -- Hotswapping files when saving
    world:update(dt) -- Updating Box2D world
    map:update(dt)
    updatePlayer()
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
	map:draw()
    -- Draw Collision Map (useful for debugging)
	love.graphics.setColor(255, 0, 0)
	map:box2d_draw()
end

function updatePlayer() 
    x, y = player.body:getPosition()
    player.object.x = x
    player.object.y = y
end

function beginContact(a, b, coll) end
 
function endContact(a, b, coll) end
 
function preSolve(a, b, coll) end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse) end