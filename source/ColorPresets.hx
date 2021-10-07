package;

import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxColor;


class ColorPresets
{
    /*public static var kapi:Array<Array<Float>> = [
        [0,0,0.6,0], 
        [0,0,0,1], 
        [0,0,0,1],
        [0,0,0.6,0],
        [0,0,0,1],
        [0,0,0.6,0],
        [0,0,0,1],
        [0,0,0,1],
        [0,0,0.6,0],
        ] */

    public static var purple:Array<Float> = [0, 0, 0, 0];
    public static var blue:Array<Float> = [0, 0, 0, 0];
    public static var green:Array<Float> = [0, 0, 0, 0];
    public static var red:Array<Float> = [0, 0, 0, 0];
    public static var white:Array<Float> = [0, 0, 0, 0];
    public static var yellow:Array<Float> = [0, 0, 0, 0];
    public static var violet:Array<Float> = [0, 0, 0, 0];
    public static var darkred:Array<Float> = [0, 0, 0, 0];
    public static var dark:Array<Float> = [0, 0, 0, 0];
    public static var ccolorArray:Array<Array<Float>> = [purple,blue,green,red,white,yellow,violet,darkred,dark];



    public static function fixColorArray(mania:Int):Void
    {
        switch (mania)
        {
            case 0: 
                ccolorArray = [purple, blue, green, red];
            case 1: 
                ccolorArray = [purple, green, red, yellow, blue, dark];
            case 2: 
                ccolorArray = [purple, blue, green, red, white, yellow, violet, darkred, dark];
            case 3: 
                ccolorArray = [purple, blue, white, green, red];
            case 4: 
                ccolorArray = [purple, green, red, white, yellow, blue, dark];
            case 5: 
                ccolorArray = [purple, blue, green, red, yellow, violet, darkred, dark];
            case 6: 
                ccolorArray = [white];
            case 7: 
                ccolorArray = [purple, red];
            case 8: 
                ccolorArray = [purple, white, red];
        }
    }
    public static function setColors(character:String, mania:Int)
    {
        switch (character)
        {
            case 'senpai' | 'senpai-angry' | 'spirit':
                purple = [0,0,0,5];
                blue = [0,0,0,5];
                green = [0,0,0,5];
                red = [0,0,0,5];
                white = [0,0,0,5];
                yellow = [0,0,0,5];
                violet = [0,0,0,5];
                darkred = [0,0,0,5];
                dark = [0,0,0,5];
            default: 
                purple = [0,0,0,0];
                blue = [0,0,0,0];
                green = [0,0,0,0];
                red = [0,0,0,0];
                white = [0,0,0,0];
                yellow = [0,0,0,0];
                violet = [0,0,0,0];
                darkred = [0,0,0,0];
                dark = [0,0,0,0];
        }
        ColorPresets.fixColorArray(mania);
    }


}