package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;


#if sys
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end

import flash.media.Sound;

class Paths
{

	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/charts/$key.json', TEXT, library);
	}

	inline static public function customChartjson(key:String, ?library:String)
	{
		return getPath('data/customCharts/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function imageJson(key:String, ?library:String)
	{
		return getPath('images/$key.json', TEXT, library);
	}

	inline static public function imageXml(key:String, ?library:String)
	{
		return getPath('images/$key.xml', TEXT, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var daImage = checkForImage(key);
		var isCustom:Bool = true;
		if (daImage == null)
			isCustom = false;

		#if !sys
		isCustom = false;
		#end

		var xml:String;

		if (CacheShit.xmls[key] != null)
		{
			xml = CacheShit.xmls[key];
		}
		else
		{
			if (isCustom)
			{
				#if sys
				xml = File.getContent('assets/images/$key.xml');
				#else
				xml = file('images/$key.xml', library);
				#end
			}
			else
				xml = file('images/$key.xml', library);

			CacheShit.SaveXml(key, xml);
		}

		if (isCustom)
		{
			return FlxAtlasFrames.fromSparrow(daImage, xml);
		}
		else
		{
			return FlxAtlasFrames.fromSparrow(image(key, library), xml);
		}

	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	static private function checkForImage(path:String)
	{
		#if sys
		if(FileSystem.exists(image(path)))
		{
			if (CacheShit.images[path] == null)
			{
				var imageGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(image(path)));
				imageGraphic.persist = true;
				CacheShit.images[path] = imageGraphic;
			}
			return CacheShit.images[path];
			

		}
		#end
		return null;
	}


}
