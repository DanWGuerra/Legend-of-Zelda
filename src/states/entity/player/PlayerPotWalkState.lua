PlayerPotWalkState = Class{__includes = EntityWalkState}

function PlayerPotWalkState:init(player, dungeon)
    EntityWalkState.init(self, player, dungeon.currentRoom)
end

function PlayerPotWalkState:enter(params)
    assert(params, "Missing paramaters")
    local pot = params.pot
    assert(pot, "Missing paramater 'pot'")
    self.pot = pot
end

function PlayerPotWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('pot-walk-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('pot-walk-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('pot-walk-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('pot-walk-down')
    else
        self.entity:changeState('pot-idle', { pot = self.pot })
    end

    if love.keyboard.isDown('f') then
        self.entity:changeState('pot-throw', { pot = self.pot })
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)

    self.pot.x = self.entity.x
    self.pot.y = self.entity.y - self.pot.height/2
end

