package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;

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
			default: 
				for (i in StoryMenuState.StoryData.menuCharacters) //mostly copied from character.hx
				{
					if (i.name == character)
					{
						var imagePath = "assets/images/storymenu/characters/" + i.fileName + ".png";

						var imageGraphic:FlxGraphic;
		
						if (CacheShit.images[imagePath] == null)
						{
							var image:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(imagePath));
							image.persist = true;
							CacheShit.images[imagePath] = image;
						}
						imageGraphic = CacheShit.images[imagePath];
		
						var xmlPath = "assets/images/storymenu/characters/" + i.fileName + ".xml";
						var xml:String;
		
						if (CacheShit.xmls[xmlPath] != null) //check if xml is stored in cache
							xml = CacheShit.xmls[xmlPath];
						else
						{
							#if sys
							xml = File.getContent(xmlPath);
							#else
							xml = Assets.getText(xmlPath);
							#end
							CacheShit.SaveXml(xmlPath, xml);
						}
						var texture = FlxAtlasFrames.fromSparrow(imageGraphic, xml);
						frames = texture;

						if (i.anims.length != 0)
						{
							for (ii in i.anims)
							{
								var animname:String = ii.anim;
								var xmlname:String = ii.xmlname;
								var fps:Int = ii.frameRate;
								var loop:Bool = ii.loop;
		
								animation.addByPrefix(animname, xmlname, fps, loop);
							}
						}
						flipX = i.flip;
						setGraphicSize(Std.int(this.width * i.scale));
						baseOffsets = [i.offsets[0], i.offsets[1]];
						break;
					}
				}
		}

		
		
		
		
		
		
		
		animation.play("idle");
		updateHitbox();
	}
}
