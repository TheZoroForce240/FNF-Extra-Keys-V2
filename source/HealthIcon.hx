package;

import flixel.FlxSprite;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var sprTrackerOptions:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		var path = "assets/images/characters/" + char + "/icon.png";
		#if sys
		if (FileSystem.exists(path))
		{
			var iconGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
			//trace("loading da custom icon");
			loadGraphic(iconGraphic, true, 150, 150);
			animation.add(char, [0, 1], 0, false, isPlayer);
		}
		#else 
		if (OpenFlAssets.exists(path))
			{
				var iconGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
				//trace("loading da custom icon");
				loadGraphic(iconGraphic, true, 150, 150);
				animation.add(char, [0, 1], 0, false, isPlayer);
			}
		#end
		else
		{
			//trace("loading da regaulr icon");
			loadGraphic(Paths.image('iconGrid'), true, 150, 150);

			antialiasing = true;
			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf-car', [0, 1], 0, false, isPlayer);
			animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
			animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
			animation.add('spooky', [2, 3], 0, false, isPlayer);
			animation.add('pico', [4, 5], 0, false, isPlayer);
			animation.add('mom', [6, 7], 0, false, isPlayer);
			animation.add('mom-car', [6, 7], 0, false, isPlayer);
			animation.add('tankman', [8, 9], 0, false, isPlayer);
			animation.add('face', [10, 11], 0, false, isPlayer);
			animation.add('dad', [12, 13], 0, false, isPlayer);
			animation.add('senpai', [22, 22], 0, false, isPlayer);
			animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
			animation.add('spirit', [23, 23], 0, false, isPlayer);
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
			animation.add('gf', [16], 0, false, isPlayer);
			animation.add('parents-christmas', [17], 0, false, isPlayer);
			animation.add('monster', [19, 20], 0, false, isPlayer);
			animation.add('monster-christmas', [19, 20], 0, false, isPlayer);
			animation.add('null', [30, 30], 0, false, isPlayer);
	
			if (char == 'check')
			{
				loadGraphic(Paths.image('icons/check'), true, 150, 150);
				animation.add('check', [0, 0], 0, false, isPlayer);
				animation.add('noCheck', [1, 1], 0, false, isPlayer);
			}
		}





		animation.play(char);

		
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		if (sprTrackerOptions != null)
			setPosition(sprTrackerOptions.x + sprTrackerOptions.width - 20, sprTrackerOptions.y - 175);
	}
}
