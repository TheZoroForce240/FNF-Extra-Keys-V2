package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState //redo all this shit later
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var settings:Array<String> = ["Keybinds", 'Use Downscroll', 'Use Ghost Tapping', 'Use Note Splash', "Use Botplay", "P2 Downscroll", "multiplayer"];
	var settingsData:Array<Bool> = [false, SaveData.downscroll, SaveData.ghost, SaveData.noteSplash, SaveData.botplay, SaveData.P2downscroll, SaveData.multiplayer];

	private var grpSettings:FlxTypedGroup<Alphabet>;

	private var checkArray:FlxTypedGroup<HealthIcon>;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);
 
		grpSettings = new FlxTypedGroup<Alphabet>();
		add(grpSettings);

		checkArray = new FlxTypedGroup<HealthIcon>();
		add(checkArray);

		for (i in 0...settings.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, settings[i], true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpSettings.add(controlLabel);
	
				var check:HealthIcon;
	
				if (i != 0)
					check = new HealthIcon('check');
				else
					check = new HealthIcon('null');
	
				check.sprTracker = controlLabel;
	
				if (settingsData[i] == true)
				{
					check.animation.play("check");
				}
				else
				{
					check.animation.play("noCheck");
				}
		
				checkArray.add(check);	
			}

		super.create();

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);



		if (FlxG.keys.justPressed.UP)
		{
			changeSelection(-1);
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT)
		{
			selectOption();
		}

		if (controls.BACK)
		{
			SaveData.saveTheData();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

	}

	function waitingInput():Void
	{
		if (FlxG.keys.getIsDown().length > 0)
		{
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	function selectOption()
	{
		switch(curSelected)
		{
			case 0: 
				LoadingState.loadAndSwitchState(new CustomizationState());
			case 1: 
				SaveData.downscroll = !SaveData.downscroll;
			case 2: 
				SaveData.ghost = !SaveData.ghost;
			case 3: 
				SaveData.noteSplash = !SaveData.noteSplash;
			case 5: 
				SaveData.P2downscroll = !SaveData.P2downscroll;
			case 6: 
				SaveData.multiplayer = !SaveData.multiplayer;
		}
		checkArray.clear();
		grpSettings.clear();
		settingsData = [false, SaveData.downscroll, SaveData.ghost, SaveData.noteSplash, SaveData.botplay, SaveData.P2downscroll, SaveData.multiplayer];
		for (i in 0...settings.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, settings[i], true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpSettings.add(controlLabel);
	
				var check:HealthIcon;
	
				if (i != 0)
					check = new HealthIcon('check');
				else
					check = new HealthIcon('null');
	
				check.sprTracker = controlLabel;
	
				if (settingsData[i] == true)
				{
					check.animation.play("check");
				}
				else
				{
					check.animation.play("noCheck");
				}
		
				checkArray.add(check);	
			}
		changeSelection(0);

		
	}

	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSettings.length - 1;
		if (curSelected >= grpSettings.length)
			curSelected = 0;


		var bullShit:Int = 0;

		for (item in grpSettings.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
