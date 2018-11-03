lovebird = require "libs/lovebird"
lurker = require("libs/lurker")
anim8 = require 'libs/anim8'
frames = {}
player = {}
enemy = {}
entities = {}
ground = {}
currentFrame = 1
function love.load()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    backroundImg = love.graphics.newImage("assets/bg.png")

    world = love.physics.newWorld( 0, 500, true )
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    createGround(ground)
    
    player.allowedJump = false
    player.isAlive = true
    player.shape = love.physics.newRectangleShape(100, 100)
    player.body = love.physics.newBody(world, 50, 50, 'dynamic')
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setCategory(2)
    player.img = love.graphics.newImage("assets/idle.png")
    local pg = anim8.newGrid(100,100, player.img:getWidth(), player.img:getHeight())
    player.animation = anim8.newAnimation(pg('1-4', 1), 0.1)

    enemy.shape = love.physics.newRectangleShape(100, 100)
    enemy.body = love.physics.newBody(world, screenWidth - 150, 50, 'dynamic')
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1)
    enemy.fixture:setCategory(3)
    enemy.img = love.graphics.newImage("assets/enemy-walking.png")
    local eg = anim8.newGrid(100,100, enemy.img:getWidth(), enemy.img:getHeight())
    enemy.animation = anim8.newAnimation(eg('1-12', 1), 0.1)

    entities[1] = player
    entities[2] = enemy

    love.graphics.setBackgroundColor(1,1,1,1)
end

local elapsedTime = 0
function love.update(dt)
    lovebird.update()
    lurker.update()
    world:update(dt)
    if love.keyboard.isDown( "left" ) then 
        if not player.animation.flippedH then
            player.animation:flipH()
        end
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(-100, vy) 
    end
    if love.keyboard.isDown( "right" ) then 
        if player.animation.flippedH then
            player.animation:flipH()
        end
        local vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(100, vy) 
    end
    for k, v in pairs(entities) do
        v.animation:update(dt)
    end
end

function love.draw()
    drawBackground(backroundImg)
    drawGround(ground)
    for k, v in pairs(entities) do
        drawAnimation(v)
    end
end

function love.keypressed(key)
    if type(keyTable[key]) == "function" then
        keyTable[key]()
    end
end

function beginContact(a, b, coll)
    contacts = world:getContacts( )
    local aCat = a:getCategory()
    local bCat = b:getCategory()
    if aCat == 2 or bCat == 2 then
        if aCat == 1 or bCat == 1 then
            player.allowedJump = true
            
        end
        if aCat == 1 or bCat == 1 then
            player.isAlive = false
        end
    end
end
 
function endContact(a, b, coll)
    aCat = a:getCategory()
    bCat = b:getCategory()
    if aCat == 2 or bCat == 2 then
        if aCat == 1 or bCat == 1 then
            player.allowedJump = false 
        end
    end
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end

function drawBackground(image)
    for i = 0, love.graphics.getWidth() / image:getWidth() do
        for j = 0, love.graphics.getHeight() / image:getHeight() do
            love.graphics.draw(image, i * image:getWidth(), j * image:getHeight())
        end
    end
end

function createGround(ground)
    ground.img = love.graphics.newImage("assets/Tiles/sand.png")
    ground.shapes = {}
    ground.bodies = {}
    ground.fixtures = {}
    for i = 0, love.graphics.getWidth() / ground.img:getWidth() do
        ground.shapes[i+1] = love.physics.newRectangleShape(ground.img:getWidth(), ground.img:getHeight())
        ground.bodies[i+1] = love.physics.newBody(world, i * ground.img:getWidth() + ground.img:getWidth() / 2, love.graphics.getHeight() - ground.img:getHeight() + ground.img:getHeight() / 2, 'static')
        local fixt = love.physics.newFixture(ground.bodies[i+1], ground.shapes[i+1], 1)
        fixt:setCategory(1)
        ground.fixtures[i+1] = fixt
    end
end

function drawGround(ground)
    for k,v in pairs(ground.bodies) do
        local x, y = v:getPosition()
        love.graphics.draw(ground.img, x, y, 0, 1, 1, ground.img:getWidth() / 2, ground.img:getHeight() / 2)
    end
end

keyTable = {
    ["escape"] = function() love.event.push("quit") end,
    ["space"] = function() 
        local vx, vy = player.body:getLinearVelocity()
        if player.allowedJump then
            player.body:setLinearVelocity(vx, -300) 
        end
    end,
}

function drawAnimation(entity)
    local x, y = entity.body:getPosition()
    local w, h = entity.animation:getDimensions()
    entity.animation:draw(entity.img, x - w/2, y - h/2)
end