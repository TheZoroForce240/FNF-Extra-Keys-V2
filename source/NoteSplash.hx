package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import Shaders;

using StringTools;

class NoteSplash extends FlxSprite
{

	public static var colors:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'darkblue'];
	var HSV:HSVEffect = new HSVEffect();
	var colorsThatDontChange:Array<String> = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'black', 'darkblue', 'orange', 'darkred'];
	public function new(nX:Float, nY:Float, color:Int)
	{



		x = nX;
		y = nY;
		super(x, y);
		frames = Paths.getSparrowAtlas('noteassets/notesplash/Splash');
		for (i in 0...colorsThatDontChange.length)
		{
			animation.addByPrefix(colorsThatDontChange[i] + ' splash', "splash " + colorsThatDontChange[i], 24, false);
		}
		antialiasing = true;
		updateHitbox();
		makeSplash(nX, nY, color);
		this.shader = HSV.shader;
		
	}
	public function makeSplash(nX:Float, nY:Float, color:Int) 
	{

        setPosition(nX - (102 * (Note.swagWidth / 66.5)), nY - (110 * (Note.swagWidth / 66.5)));
		angle = FlxG.random.int(0, 360);
        alpha = 0.6;
        
		var colorShit:Array<Float>;
		colorShit = SaveData.colorArray[color];
		HSV.hue = colorShit[0];
		HSV.saturation = colorShit[1];
		HSV.brightness = colorShit[2];
		HSV.update();

		if (colorShit[3] != 1 && colorShit[3] != 2 && colorShit[3] != 3 && colorShit[3] != 4)
			animation.play(colors[color] + ' splash', true);
		else
		{
			var newColors:Array<String> = ['nonelol','purple', 'blue', 'green', 'red'];
			animation.play(newColors[Std.int(colorShit[3])] + ' splash', true);
		}
		
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		setGraphicSize(Std.int(Note.swagWidth * 4.5));
        updateHitbox();

    }

	override public function update(elapsed) 
	{
        if (animation.curAnim.finished)
		{
            kill();
        }
        super.update(elapsed);
    }

}
