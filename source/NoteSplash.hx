package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.FlxCamera;
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
		makeSplash(nX, nY, color, 1, [PlayState.p1.noteCams[0]], [0,0,0,0]);
		this.shader = HSV.shader;
		
	}
	public function makeSplash(nX:Float, nY:Float, color:Int, playernum:Int = 1, cameraShit:Array<FlxCamera>, colorShiz:Array<Float>) 
	{
		this.cameras = cameraShit;
		var maniaToUse = PlayState.p1Mania;
		if (playernum == 0)
			maniaToUse = PlayState.p2Mania;

        setPosition(nX - (102 * (Note.noteWidths[maniaToUse] / 66.5)), nY - (110 * (Note.noteWidths[maniaToUse] / 66.5)));
		angle = FlxG.random.int(0, 360);
        alpha = 0.6;
        
		if (playernum == 1)
		{
			HSV.hue = colorShiz[0];
			HSV.saturation = colorShiz[1];
			HSV.brightness = colorShiz[2];
			HSV.update();
		}


		if ((colorShiz[3] != 1 && colorShiz[3] != 2 && colorShiz[3] != 3 && colorShiz[3] != 4) || playernum != 1)
			animation.play(colors[color] + ' splash', true);
		else if (playernum == 1)
		{
			var newColors:Array<String> = ['nonelol','purple', 'blue', 'green', 'red'];
			animation.play(newColors[Std.int(colorShiz[3])] + ' splash', true);
		}

		animation.curAnim.frameRate = Std.int((24 + FlxG.random.int(-2, 2)) * PlayState.SongSpeedMultiplier);
		setGraphicSize(Std.int(Note.noteWidths[maniaToUse] * 4.5));
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
