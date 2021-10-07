package;

import lime.utils.Assets;
import flixel.FlxG;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"]; //old stinky one

	public static var CurSongDiffs:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return CurSongDiffs[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = File.getContent(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function getSongFromJsons(song:String, diff:Int, customChart:Bool = false)
	{
		var path = "assets/data/charts/" + song;
		if (customChart)
			path = "assets/data/customChart/" + song;
		if (FileSystem.exists(path))
		{
			var diffs:Array<String> = [];
			var sortedDiffs:Array<String> = [];
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
				else if (file.endsWith(song + ".json")) //add normal
				{
					normal = file;
				}
				else if (file.endsWith("-hard.json")) //add hard
				{
					hard = file;
				}
				else
				{
					extra.push(file);
					extraCount++;
				}
			}
			if (easy != "")
				sortedDiffs.push(easy);
			if (normal != "")
				sortedDiffs.push(normal);
			if (hard != "")
				sortedDiffs.push(hard);
			if (extraCount != 0)
				for (i in extra)
					sortedDiffs.push(i);


			var outputDiffs:Array<String> = [];
			for (file in sortedDiffs)
			{
				var noJson = StringTools.replace(file,".json", "");
				var noSongName = StringTools.replace(noJson,song.toLowerCase(), "");
				outputDiffs.push(noSongName);
			}
			trace(outputDiffs);
			var textDiffs:Array<String> = [];
			for (file in outputDiffs)
			{
				var fixedShit = StringTools.replace(file,"-", "");
				textDiffs.push(fixedShit.toUpperCase());
			}
			CurSongDiffs = textDiffs;
			return song + outputDiffs[diff];
		}
		else 
			return "tutorial"; //in case it dont work lol
	}

	public static function bindCheck(mania:Int)
	{
		var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
		switch(mania)
		{
			case 0: 
				binds = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
			case 1: 
				binds = [FlxG.save.data.L1Bind, FlxG.save.data.U1Bind, FlxG.save.data.R1Bind, FlxG.save.data.L2Bind, FlxG.save.data.D1Bind, FlxG.save.data.R2Bind];
			case 2: 
				binds = [FlxG.save.data.N0Bind, FlxG.save.data.N1Bind, FlxG.save.data.N2Bind, FlxG.save.data.N3Bind, FlxG.save.data.N4Bind, FlxG.save.data.N5Bind, FlxG.save.data.N6Bind, FlxG.save.data.N7Bind, FlxG.save.data.N8Bind];
			case 3: 
				binds = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.N4Bind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
			case 4: 
				binds = [FlxG.save.data.L1Bind, FlxG.save.data.U1Bind, FlxG.save.data.R1Bind,FlxG.save.data.N4Bind, FlxG.save.data.L2Bind, FlxG.save.data.D1Bind, FlxG.save.data.R2Bind];
			case 5: 
				binds = [FlxG.save.data.N0Bind, FlxG.save.data.N1Bind, FlxG.save.data.N2Bind, FlxG.save.data.N3Bind, FlxG.save.data.N5Bind, FlxG.save.data.N6Bind, FlxG.save.data.N7Bind, FlxG.save.data.N8Bind];
			case 6: 
				binds = [FlxG.save.data.N4Bind];
			case 7:
				binds = [FlxG.save.data.leftBind, FlxG.save.data.rightBind];
			case 8: 
				binds = [FlxG.save.data.leftBind, FlxG.save.data.N4Bind, FlxG.save.data.rightBind];
		}
		return binds;
	}
	public static function arrowKeyCheck(mania:Int, keycode:Int)
	{
		var data = -1;
		switch(mania)
		{
			case 0: 
				switch(keycode) // arrow keys // why the fuck are arrow keys hardcoded it fucking breaks the controls with extra keys
				{
					case 37:
						data = 0;
					case 40:
						data = 1;
					case 38:
						data = 2;
					case 39:
						data = 3;
				}
			case 1: 
				switch(keycode) // arrow keys
				{
					case 37:
						data = 3;
					case 40:
						data = 4;
					case 39:
						data = 5;
				}
			case 2: 
				switch(keycode) // arrow keys
				{
					case 37:
						data = 5;
					case 40:
						data = 6;
					case 38:
						data = 7;
					case 39:
						data = 8;
				}
			case 3: 
				switch(keycode) // arrow keys
				{
					case 37:
						data = 0;
					case 40:
						data = 1;
					case 38:
						data = 3;
					case 39:
						data = 4;
				}
			case 4: 
				switch(keycode) // arrow keys
				{
					case 37:
						data = 4;
					case 40:
						data = 5;
					case 39:
						data = 6;
				}
			case 5: 
				switch(keycode) // arrow keys
				{
					case 37:
						data = 4;
					case 40:
						data = 5;
					case 38:
						data = 6;
					case 39:
						data = 7;
				}
			case 7: 
				switch(keycode) // arrow keys 
				{
					case 37:
						data = 0;
					case 39:
						data = 1;
				}

			case 8: 
				switch(keycode) // arrow keys 
				{
					case 37:
						data = 0;
					case 39:
						data = 2;
				}
		}
		return data;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
