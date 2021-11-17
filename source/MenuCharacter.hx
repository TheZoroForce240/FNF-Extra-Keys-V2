package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var baseOffsets:Array<Float> = [-100,100];

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;

		var tex = Paths.getSparrowAtlas('campaign_menu_UI_characters');
		frames = tex;

		switch(character)
		{
			case "bf": 
				animation.addByPrefix('idle', "BF idle dance white", 24);
				animation.addByPrefix('confirm', 'BF HEY!!', 24, false);
				baseOffsets = [-80, 0];
				setGraphicSize(Std.int(width * 0.9));
				updateHitbox();
			case "gf": 
				animation.addByPrefix('idle', "GF Dancing Beat WHITE", 24);
				setGraphicSize(Std.int(width * 0.5));
				updateHitbox();
				baseOffsets = [0, 0];
			case "dad": 
				animation.addByPrefix('idle', "Dad idle dance BLACK LINE", 24);
				setGraphicSize(Std.int(width * 0.5));
				updateHitbox();
				baseOffsets = [0, 0];
			case "spooky": 
				animation.addByPrefix('idle', "spooky dance idle BLACK LINES", 24);
				setGraphicSize(Std.int(width * 0.5));
			case "pico": 
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				setGraphicSize(Std.int(width * 0.5));
				flipX = true;
			case "mom": 
				animation.addByPrefix('idle', "Mom Idle BLACK LINES", 24);
				setGraphicSize(Std.int(width * 0.5));
				baseOffsets = [0, 0];
			case "parents-christmas": 
				animation.addByPrefix('idle', "Parent Christmas Idle", 24);
				setGraphicSize(Std.int(width * 0.5));
				updateHitbox();
				baseOffsets = [-200, 0];
			case "senpai": 
				animation.addByPrefix('idle', "SENPAI idle Black Lines", 24);
				setGraphicSize(Std.int(width * 1));
				baseOffsets = [-130, 100];
		}

		
		
		
		
		
		
		
		animation.play("idle");
		updateHitbox();
	}
}
