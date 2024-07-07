--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

EntityWalkState = Class{__includes = BaseState}

function EntityWalkState:init(entity, room)
    self.entity = entity
    self.entity:changeAnimation('walk-down')

    self.room = room

    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

    -- keeps track of whether we just hit a wall
    self.bumped = false
end

function EntityWalkState:getRoomBounds()
    return self.room:getBounds()
end

local function clamp(value, minValue, maxValue)
    return math.min(math.max(value, minValue), maxValue)
end

function EntityWalkState:update(dt)
    -- assume we didn't hit a wall
    self.bumped = false
    local speed = self.entity.walkSpeed
    local velx, vely = 0, 0

    if self.entity.direction == 'left' then
        velx = -speed
    elseif self.entity.direction == 'right' then
        velx = speed
    elseif self.entity.direction == 'up' then
        vely = -speed
    elseif self.entity.direction == 'down' then
        vely = speed
    end

    -- If not going in any direction, skip collision checks
    if velx == 0 and vely == 0 then return end

    -- Check collisions with walls
    local targetX = self.entity.x + velx * dt
    local targetY = self.entity.y + vely * dt

    local x, y, w, h = self:getRoomBounds()
    self.entity.x = clamp(targetX, x, x + w - self.entity.width)
    self.entity.y = clamp(targetY, y, y + h - self.entity.height)

    if self.entity.x ~= targetX or self.entity.y ~= targetY then
        self.bumped = true
    end
end

function EntityWalkState:processAI(params, dt)
    local room = params.room
    local directions = {'left', 'right', 'up', 'down'}

    if self.moveDuration == 0 or self.bumped then
        -- set an initial move duration and direction
        self.moveDuration = math.random(5)
        self.entity.direction = directions[math.random(#directions)]
        self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0
        -- chance to go idle
        if math.random(3) == 1 then
            self.entity:changeState('idle')
        else
            self.moveDuration = math.random(5)
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
        end
    end

    self.movementTimer = self.movementTimer + dt
end
