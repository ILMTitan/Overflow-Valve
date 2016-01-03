for _, player in ipairs(game.players) do

    player.force.reset_recipes()
    player.force.reset_technologies()
    
    if player.force.technologies["fluid-handling"].researched then
        player.force.recipes["overflow-valve"].enabled = true
    end
	
end
