PlayerPotIdleState = Class{__includes = PlayerIdleState}

function PlayerPotIdleState:init(player, dungeon)
    PlayerIdleState.init(self, player, dungeon)
end

function PlayerPotIdleState:enter(params)
    assert(params, "Missing paramaters")
    local pot = params.pot
    assert(pot, "Missing paramater 'pot'")
    self.pot = pot

    self.entity:changeAnimation('pot-idle-'..self.entity.direction)
end

function PlayerPotIdleState:update()
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk', { pot = self.pot })
    end

    if love.keyboard.isDown('f') then
        self.entity:changeState('pot-throw', { pot = self.pot })
    end
end

