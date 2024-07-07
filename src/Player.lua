--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.maxHealth = def.maxHealth or self.health
    self.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self, def.dungeon.currentRoom) end,
        ['idle'] = function() return PlayerIdleState(self, def.dungeon) end,
        ['swing-sword'] = function() return PlayerSwingSwordState(self, def.dungeon) end,
        --pot states
        ['pot-lift'] = function() return PlayerPotLiftState(self, def.dungeon) end,
        ['pot-idle'] = function() return PlayerPotIdleState(self, def.dungeon) end,
        ['pot-walk'] = function() return PlayerPotWalkState(self, def.dungeon) end,
        ['pot-throw'] = function() return PlayerPotThrowState(self, def.dungeon) end,
    }
    self:changeState('idle')
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:heal(amount)
    self.health = math.min(self.health + amount, self.maxHealth)
end

function Player:render()
    Entity.render(self)
    -- love.graphics.setColor(1, 0, 1, 0.8)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(1, 1, 1, 1)
end

