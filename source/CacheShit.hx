package;

import flixel.system.FlxSound;
import openfl.display.BitmapData;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;

import flash.media.Sound;

//so i saw a tweet from kade dev about notes being shit and getting the xml for every note or something
//gonna like cache the note xmls here or something, idk what im doing lol

class CacheShit
{

    public static var xmls:Map<String, String> = new Map(); //stores xml data
    public static var images:Map<String, FlxGraphic> = new Map(); //store image bitmap data
    public static var sounds:Map<String, FlxSoundAsset> = new Map(); //store image bitmap data


    //tbh i dont even know if this helps lol

    public static function clearCache() //how to optimize for dummasses 101, just fucking delete everything and hope it works
    {
        /*for (i in images.keys())
        {
            var imageGraphic:FlxGraphic = FlxG.bitmap.get(i);
            imageGraphic.dump();
            imageGraphic.bitmap.dispose();
            imageGraphic.bitmap.disposeImage(); //idk if both of these are needed???
            imageGraphic.destroy();
        }*/
        FlxG.bitmap.dumpCache();
        FlxG.bitmap.clearCache();
        OpenFlAssets.cache.clear(); //just fucking clear everything or some shit idk
        xmls.clear();
        images.clear();
        sounds.clear();
    }

    public static function SaveXml(name:String, xmlString:String)
    {
        xmls[name] = xmlString;
    }

    public static function SaveImage(name:String, image:FlxGraphic)
    {
        images[name] = image;
    }
    public static function SaveSound(name:String, sound:FlxSoundAsset)
    {
        sounds[name] = sound;
    }

}