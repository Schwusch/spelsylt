lovebird = require "libs/lovebird"
lurker = require "libs/lurker"
lume = require "libs/lume"
Input = require 'libs/Input'
sti = require 'libs/STI'
inspect = require 'libs/inspect'
frames = {}
destroyQueue = {}
currentFrame = 1

function love.load()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Set world meter size (in pixels)
    love.physics.setMeter(21)

    -- Load a map exported to Lua from Tiled
    map = sti('assets/maps/map01.lua', { "box2d" })
    spritesheet = get(map, {"tilesets", 1, "image"})

    -- Prepare physics world with horizontal and vertical gravity
    world = love.physics.newWorld( 0, 500 )
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- Prepare collision objects
    map:box2d_init(world)

    for k, object in pairs(map.box2d_collision) do
        if type(k) == 'number' and object.object.name == "Player" then
            player = object
        elseif type(k) == 'number' and object.object.name == "Ground" then
            ground = object
        end
    end

    for k, tile in pairs(map.tiles) do
        local name = get(tile, {"properties", "name"})
        if name == "still" then 
            still = tile
        elseif name == "walk" then 
            walk = tile
        elseif name == "brake" then 
            brake = tile
        elseif name == "fall" then 
            fall = tile
        elseif name == "jump" then 
            jump = tile
        elseif name == "coin" then
            coin = tile
        end
    end

    map.layers.GameObjects.draw = function(self)
        lume.each(map.box2d_collision, function(coll)
            if get(coll, {"object", "properties", "type"}) == "coin" then
                local points = {coll.body:getWorldPoints(coll.shape:getPoints())}
                love.graphics.draw(spritesheet, coin.quad, points[7], points[8])
            end
        end)
    end
    
    player.tile = still

    map.layers.Player.draw = function(self) 
        local t
        if player.tile.animation then 
            local tileid = player.tile.animation[player.tile.frame].tileid
            local firstgid = map.tilesets[player.tile.tileset].firstgid
            t = map.tiles[tonumber(tileid) + firstgid]
        else 
            t = player.tile
        end
        local x, y = player.body:getWorldCenter()
        love.graphics.draw(
            spritesheet,
            t.quad,
            x,
            y,
            player.tile.r, -- rotation
            player.tile.sx, -- scale X
            player.tile.sy, -- scale Y
            player.object.width / 2, -- offset X
            player.object.height / 2 -- offset Y
        )
    end

    local function jump()
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(vx, -300) 
    end

    input = Input()
    input:bind('escape', function() love.event.push("quit") end)
    input:bind('space', jump)
    input:bind('up', jump)
    input:bind('left', 'left')
    input:bind('right', 'right')
end

local elapsedTime = 0
function love.update(dt)
    lume.each(destroyQueue, "destroy")
    lume.clear(destroyQueue)

    updateKeyboardInput()
    lovebird.update() -- Debugging at 127.0.0.1:8000
    lurker.update() -- Hotswapping files when saving
    world:update(dt) -- Updating Box2D world
    map:update(dt)
    updatePlayer()
end

function love.draw()
    -- Scale world
    local scale = 2.5
    local x, y = player.body:getWorldCenter()

    local s_width = love.graphics.getWidth() / scale
    local s_height = love.graphics.getHeight() / scale
    
    local tx = -(x - s_width / 2)
    local ty = -(y - s_height / 2)
    
    love.graphics.setColor(255, 255, 255)
    map:draw(tx, ty, scale, scale)

    -- Draw Collision Map (useful for debugging)
	 love.graphics.setColor(255, 0, 0)
	 map:box2d_draw(tx, ty, scale, scale)
end

function updatePlayer() 
    player.object.x, player.object.y = player.body:getPosition()
    local vx, vy = player.body:getLinearVelocity()
    if (vx > 0.1 or vx < -0.1) and vy < 0.1 and vy > -0.1 and (input:down( "left") or input:down( "right")) then 
        player.tile = walk
    elseif (vx > 0.1 or vx < -0.1) and vy < 0.1 and vy > -0.1 then
        player.tile = brake
    elseif vy > 0.1 then
        player.tile = jump
    elseif vy < -0.1 then
        player.tile = fall
    else 
        player.tile = still
    end
    -- flip sprite depending on 
    if vx < -0.1 then 
        player.tile.sx = -1
    else
        player.tile.sx = 1
    end
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

function beginContact(a, b, coll)
    local coin = lume.match({a, b}, function(c) return get(c:getUserData(), {"properties", "type"}) == "coin" end)
    if coin then 
        print("COIN!")
        v, k = lume.match(map.box2d_collision, function(x) return x.fixture == coin end)
        lume.remove(map.box2d_collision, v)
        lume.push(destroyQueue, coin) 
    end
end
 
function endContact(a, b, coll) end
 
function preSolve(a, b, coll) end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse) end

function get(table, keys) 
    local tmp = table[keys[1]]
    for k, key in ipairs(keys) do
        if k > 1 and tmp then
            tmp = tmp[keys[k]]
        end
    end
    return tmp
end