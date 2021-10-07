package;

import haxe.macro.Expr.StringLiteralKind;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;


typedef SwagEvent = 
{
	var steps:Array<Int>;
	var eventType:String;
	var eventData:Array<Dynamic>;
}
class Event
{
	public var Steps:Array<Int>;
	public var EventType:String;
	public var EventData:Array<Dynamic>;

	public function new()
	{

	}
}
typedef EventsList = 
{
	var Events:Array<SwagEvent>;
}

class SongEvent
{
	public var Events:Array<SwagEvent>;

	public function new()
	{

	}

	public static function loadFromJson(jsonInput:String, ?folder:String):EventsList
	{
		var rawJson = File.getContent(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):EventsList
	{
		var swagShit:EventsList = cast Json.parse(rawJson);
		return swagShit;
	}
}
