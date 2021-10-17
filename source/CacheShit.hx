package;

import flixel.FlxG;


//so i saw a tweet from kade dev about notes being shit and getting the xml for every note or something
//gonna like cache the note xmls here or something, idk what im doing lol

class CacheShit
{

    public static var xmls:Map<String, String> = new Map();

    //wait dont i already have image caching in paths lol
    //public static var images:Map<String, FlxGraphic> = new Map();
    //i should fix that at some point

    public static function clearCache()
    {
        xmls.clear();
    }

    public static function SaveXml(name:String, xmlString:String)
    {
        xmls[name] = xmlString;
    }


}