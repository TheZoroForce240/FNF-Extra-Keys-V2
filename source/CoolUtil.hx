package;

import lime.utils.Assets;
import flixel.FlxG;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import PlayState;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD", "ALT"]; //old stinky one

	public static var CurSongDiffs:Array<String> = ['EASY', "NORMAL", "HARD", 'ALT'];

	public static function difficultyString():String
	{
		return CurSongDiffs[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		#if sys
		var daList:Array<String> = File.getContent(path).trim().split('\n');
		#else
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		#end

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

		if (PlayState.isStoryMode) //idk why its flagged as incorrect, game still compiles??????
			return song + PlayState.storySuffix;

		#if sys
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
				if (!file.contains(".hscript") && file.endsWith(".json")) //fuck you
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

				
			}
			var textDiffs:Array<String> = [];
			if (easy != "")
			{
				sortedDiffs.push(easy); //pushes them in correct order
				textDiffs.push("Easy");
			}
			if (normal != "")
			{
				sortedDiffs.push(normal);
				textDiffs.push("Normal");
			}
			if (hard != "")
			{
				sortedDiffs.push(hard);
				textDiffs.push("Hard");
			}
			if (extraCount != 0)
				for (i in extra)
				{
					sortedDiffs.push(i);
				}
					


			var outputDiffs:Array<String> = [];
			for (file in sortedDiffs)
			{
				var noJson = StringTools.replace(file,".json", "");
				var noSongName = StringTools.replace(noJson,song.toLowerCase(), "");
				outputDiffs.push(noSongName); //gets just the difficulty on the end of the file
			}
			
			if (extraCount != 0)
				for (file in extra)
				{
					var noJson = StringTools.replace(file,".json", "");
					var noSongName = StringTools.replace(noJson,song.toLowerCase(), "");
					var fixedShit = StringTools.replace(noSongName,"-", "");
					textDiffs.push(fixedShit.toUpperCase()); //upper cases the difficulty to use them in the array
				}
			CurSongDiffs = textDiffs;
			if (diff > outputDiffs.length)
				diff = outputDiffs.length;
			return song + outputDiffs[diff];
		}
		else 
			return "tutorial"; //in case it dont work lol
		#else
			//do nothing lol
		#end
	}

	public static function bindCheck(mania:Int, customizing:Bool = false, savedBinds:Array<Dynamic>, changedMania:Int)
	{
		if (PlayState.flipped && !PlayState.multiplayer && !customizing)
			changedMania = PlayState.p2Mania;

		var binds:Array<String> = savedBinds[0];
		switch(mania)
		{
			case 0: 
				binds = savedBinds[0]; //already matched up
			case 1: 
				binds = savedBinds[1];
			case 2: 
				if (changedMania != mania && !customizing)
				{
					switch(changedMania) //for mania switches
					{
						case 0: 
							binds = [savedBinds[0][0],savedBinds[0][1], savedBinds[0][2], savedBinds[0][3], null, null, null, null, null];
						case 1: 
							binds = [savedBinds[1][0], savedBinds[1][4], savedBinds[1][1], savedBinds[1][2], null, savedBinds[1][3], null, null, savedBinds[1][5]];
						case 2: 
							binds = savedBinds[2];
						case 3: 
							binds = [savedBinds[0][0],savedBinds[0][1], savedBinds[0][2], savedBinds[0][3], savedBinds[2][4], null, null, null, null];
						case 4: 
							binds = [savedBinds[1][0], savedBinds[1][4], savedBinds[1][1], savedBinds[1][2], savedBinds[2][4], savedBinds[1][3], null, null, savedBinds[1][5]];
						case 5: 
							binds = savedBinds[2]; //doesnt really matter if you can sit hit space lol
						case 6: 
							binds = [null, null, null, null, savedBinds[2][4], null, null, null, null];
						case 7: 
							binds = [savedBinds[0][0], null, null, savedBinds[0][3], null, null, null, null, null];
						case 8: 
							binds = [savedBinds[0][0], null, null, savedBinds[0][3], savedBinds[2][4], null, null, null, null];
					}
				}
				else 
					binds = savedBinds[2];
			case 3: 
				binds = [savedBinds[0][0],savedBinds[0][1], savedBinds[2][4], savedBinds[0][2], savedBinds[0][3]];
			case 4: 
				binds = [savedBinds[1][0], savedBinds[1][1], savedBinds[1][2],savedBinds[2][4], savedBinds[1][3], savedBinds[1][4], savedBinds[1][5]];
			case 5: 
				binds = [savedBinds[2][0],savedBinds[2][1],savedBinds[2][2],savedBinds[2][3], savedBinds[2][5], savedBinds[2][6],savedBinds[2][7],savedBinds[2][8]];
			case 6: 
				binds = [savedBinds[2][4]];
			case 7:
				binds = [savedBinds[0][0], savedBinds[0][3]];
			case 8: 
				binds = [savedBinds[0][0], savedBinds[2][4], savedBinds[0][3]];
		}
		return binds;
	}

	public static function complexAssKeybindSaving(maniaToChange:Int, key:String, curSelectedNote:Int, player:Int = 1) //wait shouldnt i put this in save data?? who cares lol
	{
		var binds = bindCheck(maniaToChange, true, SaveData.binds, maniaToChange);
		if (player != 1)
			binds = bindCheck(maniaToChange, true, SaveData.P2binds, maniaToChange);

		binds[curSelectedNote] = key;

		if (player == 1)
		{
			switch (maniaToChange) //this code scares me
			{
				case 0: 
					SaveData.binds[0] = binds;
				case 1: 
					SaveData.binds[1] = binds;
				case 2: 
					SaveData.binds[2] = binds;
				case 3: 
					SaveData.binds[0][0] = binds[0];
					SaveData.binds[0][1] = binds[1];
					SaveData.binds[2][4] = binds[2];
					SaveData.binds[0][2] = binds[3];
					SaveData.binds[0][3] = binds[4];
				case 4: 
					SaveData.binds[1][0] = binds[0];
					SaveData.binds[1][1] = binds[1];
					SaveData.binds[1][2] = binds[2];
					SaveData.binds[2][4] = binds[3];
					SaveData.binds[1][3] = binds[4];
					SaveData.binds[1][4] = binds[5];
					SaveData.binds[1][5] = binds[6];
				case 5: 
					SaveData.binds[2][0] = binds[0];
					SaveData.binds[2][1] = binds[1];
					SaveData.binds[2][2] = binds[2];
					SaveData.binds[2][3] = binds[3];
					SaveData.binds[2][5] = binds[4];
					SaveData.binds[2][6] = binds[5];
					SaveData.binds[2][7] = binds[6];
					SaveData.binds[2][8] = binds[7];
				case 6: 
					SaveData.binds[2][4] = binds[0];
				case 7: 
					SaveData.binds[0][0] = binds[0];
					SaveData.binds[0][3] = binds[1];
				case 8: 
					SaveData.binds[0][0] = binds[0];
					SaveData.binds[2][4] = binds[1];
					SaveData.binds[0][3] = binds[2];
			}
		}
		else 
		{
			switch (maniaToChange) //for player 2
			{
				case 0: 
					SaveData.P2binds[0] = binds;
				case 1: 
					SaveData.P2binds[1] = binds;
				case 2: 
					SaveData.P2binds[2] = binds;
				case 3: 
					SaveData.P2binds[0][0] = binds[0];
					SaveData.P2binds[0][1] = binds[1];
					SaveData.P2binds[2][4] = binds[2];
					SaveData.P2binds[0][2] = binds[3];
					SaveData.P2binds[0][3] = binds[4];
				case 4: 
					SaveData.P2binds[1][0] = binds[0];
					SaveData.P2binds[1][1] = binds[1];
					SaveData.P2binds[1][2] = binds[2];
					SaveData.P2binds[2][4] = binds[3];
					SaveData.P2binds[1][3] = binds[4];
					SaveData.P2binds[1][4] = binds[5];
					SaveData.P2binds[1][5] = binds[6];
				case 5: 
					SaveData.P2binds[2][0] = binds[0];
					SaveData.P2binds[2][1] = binds[1];
					SaveData.P2binds[2][2] = binds[2];
					SaveData.P2binds[2][3] = binds[3];
					SaveData.P2binds[2][5] = binds[4];
					SaveData.P2binds[2][6] = binds[5];
					SaveData.P2binds[2][7] = binds[6];
					SaveData.P2binds[2][8] = binds[7];
				case 6: 
					SaveData.P2binds[2][4] = binds[0];
				case 7: 
					SaveData.P2binds[0][0] = binds[0];
					SaveData.P2binds[0][3] = binds[1];
				case 8: 
					SaveData.P2binds[0][0] = binds[0];
					SaveData.P2binds[2][4] = binds[1];
					SaveData.P2binds[0][3] = binds[2];
			}
		}
		
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


	public static function songCompatCheck(noteType:Int)
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			case "ectospasm" | "spectral":
				if (noteType == 1)
					noteType = 8;
				else if (noteType == 2)
					noteType = 4;
			case "godspeed" | "where-are-you": //my own mod lol
				if (noteType <= 4)
					noteType = 0;
				else if (noteType == 5)
					noteType = 1;
				else if (noteType == 6)
					noteType = 2;
				else if (noteType == 7)
					noteType = 3;
				else if (noteType == 8)
					noteType = 6;
				else if (noteType == 9)
					noteType = 7;
		}


		return noteType;
	}



}
