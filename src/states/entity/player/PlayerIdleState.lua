--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(player, dungeon)
    EntityIdleState.init(self, player)
    self.dungeon = dungeon
end

function PlayerIdleState:enter(params)
end

-- Get the position in front of the player
function PlayerIdleState:getLookPosition()
    local lookX = self.entity.x + self.entity.width/2
    local lookY = self.entity.y + self.entity.height/2
    if self.entity.direction == "up" then
        lookY = lookY - self.entity.height
    elseif self.entity.direction == "down" then
        lookY = lookY + self.entity.height
    elseif self.entity.direction == "left" then
        lookX = lookX - self.entity.width
    elseif self.entity.direction == "right" then
        lookX = lookX + self.entity.width
    end
    return lookX, lookY
end

function PlayerIdleState:update(dt)
    EntityIdleState.update(self, dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end

    if love.keyboard.wasPressed('f') then
        local object = self.dungeon.currentRoom:getObjectAt(self:getLookPosition())
        if object and object.type == "pot" then
            self.entity:changeState('pot-lift', { pot = object })
        end
    elseif love.keyboard.wasPressed("space") then
        self.entity:changeState('swing-sword')
    end
end

