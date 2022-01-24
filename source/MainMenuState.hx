package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flash.media.Sound;

using StringTools;

class MainMenuState extends MusicBeatState
{
	

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	public static var songText:FlxText;


	#if !switch
	public static var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var XOffset:Float = 0;

	public static var curSong:String = "Freaky Menu";

	/*public var script:HscriptShit;
	public static var instance:MainMenuState;

	public function call(tfisthis:String, shitToGoIn:Array<Dynamic>)
	{
		if (script.enabled)
			script.call(tfisthis, shitToGoIn);
	}*/

	override function create()
	{
		//instance = this;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		Main.updateGameData();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
			FlxG.sound.music.onComplete = MainMenuState.musicShit;
		}

		persistentUpdate = persistentDraw = true;

		//script = new HscriptShit("assets/data/stateScripts/MainMenuState.hscript"); //heheheha
		//call("loadScript", []);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('mainmenu/FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, Application.current.meta.get('version') + ' | Zoro Engine 0.5 Release', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();
		SaveData.keyBindCheck();
		//call("onStateCreated", []);
		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;
	

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		if (FlxG.keys.justPressed.R)
		{
			SaveData.ResetData();
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new DebugState());
		}

		//call("update", [elapsed]);
		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.FIVE)
			{
				musicShit();
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										LoadingState.loadAndSwitchState(new CustomizationState());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.x = (FlxG.width / 2) - (spr.width / 2) + XOffset;
		});

	}
	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}


	public static function musicShit():Void
	{
		
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		var randomSong = FlxG.random.int(0, initSonglist.length - 1);

		var data:Array<String> = initSonglist[randomSong].split(':');
		var song = data[0].toLowerCase();

		#if sys
		FlxG.sound.playMusic(Sound.fromFile(Paths.inst(song)), 0.6, true);
		#end

		FlxG.sound.music.onComplete = MainMenuState.musicShit;

		curSong = data[0];

		//CacheShit.clearCache();

		/*songText = new FlxText(FlxG.width * 0.7, -1000, 0, "Now Playing: " + curSong, 20);
        songText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        songText.scrollFactor.set();
        add(songText);
        FlxTween.tween(songText, {x: 100}, 1, {ease: FlxEase.quadInOut, 
            onComplete: function(twn:FlxTween)
            {
                new FlxTimer().start(4, function(tmr:FlxTimer)
                {
                    FlxTween.tween(songText, {x: -1000}, 1, {ease: FlxEase.quadInOut, 
                        onComplete: function(twn:FlxTween)
                        {
                            remove(songText);
                            songText.destroy();
                        }});
                });

            }});*/
		//apparently you literaly cant add sprites inside a static function bruh
	}

}
