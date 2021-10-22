package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flash.media.Sound;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var randomText:FlxText;
	var randomModeText:FlxText;
	var maniaText:FlxText;
	var flipModeText:FlxText;
	var bothSideText:FlxText;
	var randomManiaText:FlxText;
	var noteTypesText:FlxText;

	var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	var randMania:Array<String> = ["Off", "Low Chance", "Medium Chance", "High Chance"];
	var randNoteTypes:Array<String> = ["Off", "Low Chance", "Medium Chance", "High Chance", 'Unfair'];
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var diffArrays:Array<Array<Int>> = [];
	private var diffTextArrays:Array<Array<String>> = [];
	private var customSongCheck:Array<Bool> = [];

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
			//customSongCheck.push(false);
			#if sys
			var path = "assets/data/charts/" + data[0];
			if (FileSystem.exists(path))
			{
				var diffs:Array<String> = [];
				var sortedDiffs:Array<String> = [];
				var diffTexts:Array<String> = []; //for display text
				diffs = FileSystem.readDirectory(path);

				var easy:String = "";
				var normal:String = "";
				var hard:String = "";
				var extra:Array<String> = [];
				var extraCount = 0;
				
				for (file in diffs)
				{
					if (!file.endsWith(".json")) //get rid of non json files
						diffs.remove(file);
					else if (file.endsWith("-easy.json")) //add easy first
					{
						easy = file;
					}
					else if (file.endsWith(data[0].toLowerCase() + ".json")) //add normal
					{
						normal = file;
					}
					else if (file.endsWith("-hard.json")) //add hard
					{
						hard = file;
					}
					else if (file.endsWith(".json"))
					{
						var text:String = StringTools.replace(file, data[0].toLowerCase() + "-", "");
						var fixedText:String = StringTools.replace(text,".json", "");
						extra.push(fixedText.toUpperCase());
						extraCount++;
					}
				}

				if (easy != "") //me trying to figure out how to sort the diffs in correct order :(
					diffTexts.push("EASY"); //it works pog
				if (normal != "")
					diffTexts.push("NORMAL");
				if (hard != "")
					diffTexts.push("HARD");
				if (extraCount != 0)
					for (i in extra)
						diffTexts.push(i);

				//diffArrays.push(sortedDiffs);
				diffTextArrays.push(diffTexts);
				trace(sortedDiffs);
				trace(diffTexts);
				
			}
			#else
			var diffTexts = ["EASY", "NORMAL", "HARD", "ALT"];
			diffTextArrays.push(diffTexts);
			#end

		}
		
		/*var customChartsSearch = FileSystem.readDirectory("assets/data/customCharts/");
		if (customChartsSearch.length != 0)
		{
			for (shit in customChartsSearch)
			{
				addSong(shit, 0, "bf");
				customSongCheck.push(true);
				var customChartPath = "assets/data/customCharts/" + shit;
				if (FileSystem.exists(customChartPath))
					{
						var diffs:Array<String> = [];
						var sortedDiffs:Array<String> = [];
						var diffTexts:Array<String> = []; //for display text
						diffs = FileSystem.readDirectory(customChartPath);
		
						var easy:String = "";
						var normal:String = "";
						var hard:String = "";
						var extra:Array<String> = [];
						var extraCount = 0;
						
						for (file in diffs)
						{
							if (!file.endsWith(".json")) //get rid of non json files
								diffs.remove(file);
							else if (file.endsWith("-easy.json")) //add easy first
							{
								easy = file;
							}
							else if (file.endsWith(shit.toLowerCase() + ".json")) //add normal
							{
								normal = file;
							}
							else if (file.endsWith("-hard.json")) //add hard
							{
								hard = file;
							}
							else
							{
								var text:String = StringTools.replace(file, shit.toLowerCase() + "-", "");
								var fixedText:String = StringTools.replace(text,".json", "");
								extra.push(fixedText.toUpperCase());
								extraCount++;
							}
						}
		
						if (easy != "") //me trying to figure out how to sort the diffs in correct order :(
							diffTexts.push("EASY"); //it works pog
						if (normal != "")
							diffTexts.push("NORMAL");
						if (hard != "")
							diffTexts.push("HARD");
						if (extraCount != 0)
							for (i in extra)
								diffTexts.push(i);
		
						//diffArrays.push(sortedDiffs);
						diffTextArrays.push(diffTexts);
					}
			}
		}*/
		

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);


		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		

		if (FlxG.keys.justPressed.C)
		{
			openSubState(new QuickOptions());
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.SPACE)
			FlxG.sound.playMusic(Sound.fromFile(Paths.inst(songs[curSelected].songName)), 0);

		if (accepted)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				Main.editor = true;
				#if sys
				var poop:String = CoolUtil.getSongFromJsons(songs[curSelected].songName.toLowerCase(), curDifficulty);
				#else
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				#end
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new ChartingState());
			}
			else
			{
				#if sys
				var poop:String = CoolUtil.getSongFromJsons(songs[curSelected].songName.toLowerCase(), curDifficulty);
				#else
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				#end
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}

		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = diffTextArrays[curSelected].length - 1;
		if (curDifficulty > diffTextArrays[curSelected].length - 1)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = diffTextArrays[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		changeDiff(0); //update the diffs

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String = "tutorial", week:Int = 0, songCharacter:String = "bf")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
