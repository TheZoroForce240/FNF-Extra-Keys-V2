package;

import flixel.FlxG;

#if sys
import flixel.graphics.FlxGraphic;
#end


//so i saw a tweet from kade dev about notes being shit and getting the xml for every note or something
//gonna like cache the note xmls here or something, idk what im doing lol

class CacheShit
{

    public static var xmls:Map<String, String> = new Map();
    public static var images:Map<String, FlxGraphic> = new Map(); 


    //tbh i dont even know if this helps lol

    public static function clearCache()
    {
        xmls.clear();
        images.clear();
    }

    public static function SaveXml(name:String, xmlString:String)
    {
        xmls[name] = xmlString;
    }


}