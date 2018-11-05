lovebird = require "libs/lovebird"
lurker = require "libs/lurker"
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
    spritesheet = map.tilesets[1].image

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld( 0, 500 )
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

    for k, tile in pairs(map.tiles) do
        if tile.properties and tile.properties.name == "Player" then 
            player.tile = tile
        end
    end
    
    map:removeLayer('Player')
    playerLayer = map:addCustomLayer("Player", 3)

    playerLayer.draw = function(self) 
        local tileid = player.tile.animation[player.tile.frame].tileid
        local firstgid = map.tilesets[player.tile.tileset].firstgid
        local t = map.tiles[tonumber(tileid) + firstgid]
        local x, y = player.body:getWorldCenter()
        love.graphics.draw(
            spritesheet,
            t.quad,
            x,
            y,
            0, -- rotation
            1, -- scale X
            1, -- scale Y
            player.object.width / 2, -- offset X
            player.object.height / 2 -- offset Y
        )
    end
    
    input = Input()
    input:bind('escape', function() love.event.push("quit") end)
    input:bind('space', function()
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -300) 
    end)
    input:bind('left', 'left')
    input:bind('right', 'right')
end

local elapsedTime = 0
function love.update(dt)
    updateKeyboardInput()
    lovebird.update() -- Debugging at 127.0.0.1:8000
    lurker.update() -- Hotswapping files when saving
    world:update(dt) -- Updating Box2D world
    map:update(dt)
    updatePlayer()
end

function love.draw()
    -- Scale world
    local scale = 2
    local screen_width = love.graphics.getWidth() / scale
    local screen_height = love.graphics.getHeight() / scale
    local x, y = player.body:getPosition()
    local tx = - math.floor(x + screen_width / 2)
    local ty = - math.floor(y + screen_height  / 2)

    love.graphics.setColor(255, 255, 255)
    map:draw(tx, ty, scale, scale)
    
    -- Draw Collision Map (useful for debugging)
	-- love.graphics.setColor(255, 0, 0)
	-- map:box2d_draw()
end

function updatePlayer() 
    x, y = player.body:getPosition()
    player.object.x = x
    player.object.y = y
end

function updateKeyboardInput()
    if input:down( "left") then 
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(-200, vy) 
    end
    if input:down("right") then 
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(200, vy) 
    end
end

function beginContact(a, b, coll) end
 
function endContact(a, b, coll) end
 
function preSolve(a, b, coll) end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse) end