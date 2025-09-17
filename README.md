# 20 Game Challenge : Breakout Invaders

Game #2(and 3!) in my attempt at the [20 game challenge](https://20_games_challenge.gitlab.io/challenge/) - Breakout and Space Invaders mash-up!

See it in action on Itch.io:  [Breakout Invaders](https://daddio-dragonslayer.itch.io/breakout-invaders)

<p align="center">
  <img height="320" src="https://res.cloudinary.com/dbgabg3vb/image/upload/v1757410862/Breakout_Invaders_2025_09_09_11_39_52_y8ecmi.png" />
  <img height="320" src="https://img.itch.zone/aW1hZ2UvMzg3MDcwMy8yMzEwNzkzNy5wbmc=/original/SuhRrc.png" />
  <img height="320" src="https://img.itch.zone/aW1hZ2UvMzg3MDcwMy8yMzEwMDYxMS5wbmc=/original/rZwxJ1.png" />
</p>

This project included a persistent high score table using a JSON API on jsonbin.io. This means the project will not run (or score list wont work at least) 
out the box as I could not commit my API secret, to use the project, create a folder in root called data and add a file api_key.txt. Put your jsonbin.io key
in this file.

You will also need to update the bin hash in the /scripts/globals/game_manager.gd:load/save_high_scores() (yes this needs to be fixed in next update to not be duplicated and a constant!!)

A future update will also move high score management code to high_score_manager.gd which is really where it belongs.  

## What is the 20 game challenge?

[The 20 Games Challenge](https://20_games_challenge.gitlab.io/how/)

> The goal of the 20 games challenge is to gradually learn more about game development through a series of small projects.
> At the end of the challenge, you should be comfortable creating games in your engine of choice without a tutorial.


## Credits

Sprites:
	Comp-3 Interactive
	https://comp3interactive.itch.io/invaders-from-outerspace-full-project-asset-pack
	
Additional Sprites And Graphics:
	Anzimus Legacy Collection - https://ansimuz.itch.io/gothicvania-patreon-collection
	FX Pixel Texture - BDragon1727
	
Explosion SFX:
	JDSherbert - https://jdsherbert.itch.io/	
	
Theme Music:
Title:
	Starter [8 bit Dub]
Author:
	TAD
URL:
	https://opengameart.org/content/starter-8-bit-dub
