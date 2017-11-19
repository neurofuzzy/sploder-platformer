# sploder-platformer

Original client-side AS3/Flash source code for the Sploder (http://www.sploder.com) Platformer

## History

The Sploder platformer was originally launched on http://www.sploder.com in 2008. Hundreds of thousands of game levels were created with this software, and it has received many updates over the years, and this is the state of the source code since its last update in 2014.

## Technology

Sploder Platformer was written in AS3 using FlashDevelop. Visual assets were created in Adobe Flash 9 Public Alpha.

## Assets

Character and object physics, as well as weapons behavior are highly dependent on the SWF game library created by flash. Object bounds and hierarchies are used at runtime during physics calculations in the game loop. Some weapons behaviors are encoded in frame labels.

## Music

I do not own the rights to the music files, and only have permission to host them on sploder.com with attribution. Therefore they will not be included in this repo.

## Sub-projects

There are several `.as3proj` files which are FlashDevelop projects.

- Platformer.as3proj - the game engine
- Creator.as3proj - the creator
- TextureGen - the texture generator engine

## Source code

Much of the source code is in `com/sploder` but the platformer is built on the custom game framework in `fuz2d`.

## Historical Value

This code was never written for open-source purposes. Therefore it may be difficult to adapt for other uses. It is posted here for historical value and porting purposes. I'll be watching the repo and taking suggestions for branches and pull requests for porting efforts.

## License

See the license file for details.
