lovebird = require "lovebird"
local imageFile
local frames = {}

local activeFrame
local currentFrame = 1
function love.load()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    backroundImg = love.graphics.newImage("assets/bg.png")

    world = love.physics.newWorld( 0, 500, true )
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    ground = {}
    createGround(ground)
    

    player = {}
    player.allowedJump = false
    player.shape = love.physics.newRectangleShape(100, 100)
    player.body = love.physics.newBody(world, 50, 50, 'dynamic')
    player.fixture = love.physics.newFixture(player.body, player.shape, 1)
    player.fixture:setCategory(2)
    player.img = love.graphics.newImage("assets/idle.png")
    player.animation = newAnimation(player.img, 100, 100, 1)

    enemy = {}
    enemy.shape = love.physics.newRectangleShape(100, 100)
    enemy.body = love.physics.newBody(world, screenWidth - 150, 50, 'dynamic')
    enemy.fixture = love.physics.newFixture(enemy.body, enemy.shape, 1)
    enemy.img = love.graphics.newImage("assets/enemy-walking.png")
    enemy.animation = newAnimation(enemy.img, 100, 100, 1)

    entities = {
        player, 
        enemy
    }

    love.graphics.setBackgroundColor(1,1,1,1)
end

function beginContact(a, b, coll)
    lovebird.print(a, b, coll)
    aCat = a:getCategory()
    bCat = b:getCategory()
    if (aCat == 2 or bCat == 2) and (aCat == 1 or bCat == 1) then
        player.allowedJump = true
    end
end
 
function endContact(a, b, coll)
 
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
    ground.img = love.graphics.newImage("assets/tiles/sand.png")
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
        x, y = v:getPosition()
        love.graphics.draw(ground.img, x, y, 0, 1, 1, ground.img:getWidth() / 2, ground.img:getHeight() / 2)
    end
end

function love.draw()
    drawBackground(backroundImg)
    drawGround(ground)
    for k, v in pairs(entities) do
        drawAnimation(v)
    end
end

keyTable = {
    ["escape"] = function() love.event.push("quit") end,
    ["space"] = function() 
        vx, vy = player.body:getLinearVelocity()
        if vy < 0.1 and vy > -0.1 and player.allowedJump then
            player.body:setLinearVelocity(vx, -300) 
        end
    end,

}

function love.keypressed(key)
    if type(keyTable[key]) == "function" then
        keyTable[key]()
    end
end

local elapsedTime = 0
function love.update(dt)
    lovebird.update()
    world:update(dt)
    if love.keyboard.isDown( "left" ) then 
        vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(-100, vy) 
    end
    if love.keyboard.isDown( "right" ) then 
        vx, vy = player.body:getLinearVelocity()
        player.body:setLinearVelocity(100, vy) 
    end
    for k, v in pairs(entities) do
        updateAnimation(v, dt)
    end
end

function drawAnimation(entity)
    x, y = entity.body:getPosition()
    local spriteNum = math.floor(entity.animation.currentTime / entity.animation.duration * #entity.animation.quads) + 1
    love.graphics.draw(entity.animation.spriteSheet, entity.animation.quads[spriteNum], x, y, 0, 1, 1, 50, 50)
end

function updateAnimation(entity, dt)
    entity.animation.currentTime = entity.animation.currentTime + dt
    if entity.animation.currentTime >= entity.animation.duration then
        entity.animation.currentTime = entity.animation.currentTime - entity.animation.duration
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