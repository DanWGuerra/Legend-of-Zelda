--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(dungeon, width, height)
    assert(dungeon, "Missing dungeon")
    assert(type(width) == "number", "width must be number")
    assert(type(height) == "number", "height must be number")
    self.width = width
    self.height = height
    self.dungeon = dungeon

    self.tiles = Room.generateWallsAndFloors(self.width, self.height)

    -- entities in the room
    self.entities = {}

    -- doorways that lead to other dungeon rooms
    self.doorways = self:createDoorways()

    -- game objects in the room
    self.objects = {}

    self:generateEntities()
    self:generateObjects()
end

local function snapToGrid(x, y)
    return math.ceil(x/TILE_SIZE) * TILE_SIZE, math.ceil(y/TILE_SIZE) * TILE_SIZE
end

function Room:createDoorways()
    local x, y, w, h = self:getBounds()
    local positions = {
        up = { x + w/2 - TILE_SIZE, y - TILE_SIZE * 2 },
        down = { x + w/2 - TILE_SIZE, y + h },
        left = { x - TILE_SIZE * 2, y + h/2 - TILE_SIZE },
        right = { x + w, y + h/2 - TILE_SIZE }
    }
    local doorways = {}
    for direction, pos in pairs(positions) do
        local x, y = snapToGrid(pos[1], pos[2])
        table.insert(doorways, Doorway(direction, x, y))
    end
    return doorways
end

--[[
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    local x, y, w, h = self:getBounds()
    local entityWidth, entityHeight = 16, 16
    for _ = 1, 10 do
        local type = types[math.random(#types)]
        local def = ENTITY_DEFS[type]
        local entity = Entity {
            animations = def.animations,
            walkSpeed = def.walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = math.random(x, x + w - entityWidth),
            y = math.random(y, y + h - entityHeight),

            width = 16,
            height = 16,

            health = 1
        }

        entity.stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(entity, self) end,
            ['idle'] = function() return EntityIdleState(entity) end
        }

        entity:changeState('walk')
        table.insert(self.entities, entity)
    end
end

function Room:spawnSwitch()
    local boundsX, boundsY, boundsW, boundsH = self:getBounds()
    local def = GAME_OBJECT_DEFS["switch"]
    local x = math.random(boundsX, boundsX + boundsW - def.width)
    local y = math.random(boundsY, boundsY + boundsH - def.height)

    local switch = GameObject(def, x, y)

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'

            -- open every door in the room if we press the switch
            for _, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end

    table.insert(self.objects, switch)
    return switch
end

function Room:spawnPot()
    local boundsX, boundsY, boundsW, boundsH = self:getBounds()
    local def = GAME_OBJECT_DEFS["pot"]
    local pot = Pot(def, self)

    -- Check that the pot will be places in a valid position
    repeat
        local validPosition = true
        pot.x = math.random(boundsX, boundsX + boundsW - def.width)
        pot.y = math.random(boundsY, boundsY + boundsH - def.height)

        for _, object in ipairs(self.objects) do
            if object:collides(pot) or (self.player and self.player:collides(pot)) then
                validPosition = false
                break
            end
        end
    until validPosition

    table.insert(self.objects, pot)
    return pot
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    -- create switch
    self:spawnSwitch()

    --Pots creation
    --create 4 pots, meaning at least 1 heart at least "ish"
    for _=1, 4 do
        self:spawnPot()
    end
end

--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room.generateWallsAndFloors(width, height)
    local tiles = {}
    -- Create tile matrix with random floor
    for _y = 1, height do
        local row = {}
        table.insert(tiles, row)
        for _x = 1, width do
            table.insert(row, TILE_FLOORS[math.random(#TILE_FLOORS)])
        end
    end

    -- Corners
    tiles[1][1] = TILE_TOP_LEFT_CORNER
    tiles[height][1] = TILE_BOTTOM_LEFT_CORNER
    tiles[1][width] = TILE_TOP_RIGHT_CORNER
    tiles[height][width] = TILE_BOTTOM_RIGHT_CORNER

    -- Top edge
    for x = 2, width-1 do
        tiles[1][x] = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
    end
    -- Bottom edge
    for x = 2, width-1 do
        tiles[height][x] = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
    end
    -- Left edge
    for y = 2, height-1 do
        tiles[y][1] = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
    end
    -- Right edge
    for y = 2, height-1 do
        tiles[y][width] = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
    end

    return tiles
end

function Room:setPlayer(player)
    self.player = player
end

--- Returns the bounding box of the room.
function Room:getBounds()
    return 0, 0, (self.width-2) * TILE_SIZE, (self.height-2) * TILE_SIZE
end

function Room:spawnHeart(x, y)
    local heart = GameObject(GAME_OBJECT_DEFS['heart'], x, y)
    heart.consumed = function(player)
        player:heal(2)
        gSounds['heart']:play()
    end
    table.insert(self.objects, heart)
end

local function sign(num)
    return (num > 0 and 1) or (num < 0 and -1) or 0
end

local function resolveCollision(target, object)
    local totalHeight = target.height + object.height
    local totalWidth = target.width + object.width
    local xOverlap = (target.x + target.width/2) - (object.x + object.width/2)
    local yOverlap = (target.y + target.height/2) - (object.y + object.height/2)
    if math.abs(xOverlap) > math.abs(yOverlap) then
        target.x = target.x + (totalWidth/2 - math.abs(xOverlap)) * sign(xOverlap)
    else
        target.y = target.y + (totalHeight/2 - math.abs(yOverlap)) * sign(yOverlap)
    end
end

function Room:getObjectAt(x, y)
    for _, object in ipairs(self.objects) do
        if x >= object.x and x < object.x + object.width
        and y >= object.y and y < object.y + object.height then
            return object
        end
    end
end

function Room:removeObject(obj)
    for i, object in ipairs(self.objects) do
        if obj == object then
            table.remove(self.objects, i)
            return true
        end
    end
    return false
end

function Room:update(dt)
    if self.player then
        self.player:update(dt)
    end

    for _, doorway in pairs(self.doorways) do
        if self.player.direction == doorway.direction and self.player:collides(doorway) and doorway.open then
            self.dungeon:shiftRoom(doorway.direction)
        end
    end

    for i, object in ipairs(self.objects) do
        object:update(dt)
        if self.player:collides(object) then
            object:onCollide()
            if object.solid then
                resolveCollision(self.player, object)
            end
            if object.consumable then
                object.consumed(self.player)
                table.remove(self.objects, i)
            end
        end
        if object.state == "thrown" then
            for j, otherObject in ipairs(self.objects) do
                if i ~= j and otherObject.solid and otherObject:collides(object) and object.initDestroy then
                    object:initDestroy()
                end
            end
        end
        if object.toRemove then
            if math.random(3) == 1 then
                self:spawnHeart(object.x, object.y)
            end
            table.remove(self.objects, i)
        end
    end

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]
        for _, object in ipairs(self.objects) do
            if entity:collides(object) then
                if object.solid then
                    resolveCollision(entity, object)
                end
                if object.state == "thrown" then
                    entity:damage(1)
                    gSounds['hit-enemy']:play()
                    if object.initDestroy then object:initDestroy() end
                end
            end
        end

        -- remove entity from the table if health is <= 0
        if entity.health <= 0 then
            if not entity.dead and math.random(3) == 1 then
                self:spawnHeart(entity.x, entity.y)
            end
            entity.dead = true
        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end

        -- collision between the player and entities in the room
        if self.player and not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end
    end
end

function Room:renderTiles()
    love.graphics.setColor(1, 1, 1)
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            local x = (x - 1) * TILE_SIZE
            local y = (y - 1) * TILE_SIZE
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile], x, y)
            -- love.graphics.rectangle("line", x, y, TILE_SIZE, TILE_SIZE)
        end
    end
end

function Room:render()
    love.graphics.push()
    love.graphics.translate(
        (VIRTUAL_WIDTH - (self.width * TILE_SIZE)) / 2,
        (VIRTUAL_HEIGHT - (self.height * TILE_SIZE)) / 2
    )
    self:renderTiles()

    love.graphics.translate(TILE_SIZE, TILE_SIZE)

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for _, doorway in pairs(self.doorways) do
        doorway:render()
    end

    for _, obj in pairs(self.objects) do
        obj:render()
    end

    for _, entity in pairs(self.entities) do
        if not entity.dead then entity:render() end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        -- Hold a table of offsets for each type doorway direction.
        -- So that even if there would be more than 4 doorways, the code wont break.
        local rects = {
            left = {0, 0, TILE_SIZE, TILE_SIZE*2},
            right = {TILE_SIZE, 0, TILE_SIZE, TILE_SIZE*2},
            up = {0, -TILE_SIZE, TILE_SIZE*2, TILE_SIZE*2},
            down = {0, TILE_SIZE, TILE_SIZE*2, TILE_SIZE*2}
        }
        for _, doorway in ipairs(self.doorways) do
            local rect = rects[doorway.direction]
            local x = doorway.x + rect[1]
            local y = doorway.y + rect[2]
            local w, h = rect[3], rect[4]
            love.graphics.rectangle('fill', x, y, w, h)
        end
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)

    if self.player then
        self.player:render()
    end

    love.graphics.setStencilTest()


    for _, obj in pairs(self.objects) do
        if obj.type == "pot" and (obj.state == "grabbed" or obj.state == "thrown") then
            obj:render()
        end
    end

    love.graphics.pop()
end

