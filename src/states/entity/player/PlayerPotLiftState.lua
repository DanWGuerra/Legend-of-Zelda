PlayerPotLiftState = Class{__includes = BaseState}

function PlayerPotLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
end

function PlayerPotLiftState:enter(params)
    assert(params, "Missing paramaters")
    local pot = params.pot
    assert(pot, "Missing paramater 'pot'")
    self.pot = pot

    self.pot:initGrab()

    self.player.currentAnimation:refresh()
    self.player:changeAnimation("pot-lift-"..self.player.direction)

    local targetX = self.player.x
    local targetY = self.player.y - self.pot.height/2

    Timer.tween(0.3, {
        [self.pot] = {x = targetX, y = targetY}
    }):finish(function()
        self.player:changeState("pot-idle", { pot = self.pot })
    end)
end

