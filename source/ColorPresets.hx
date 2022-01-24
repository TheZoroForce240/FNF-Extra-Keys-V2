package;

import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxColor;


class ColorPresets
{
    public static var noteColors:Array<Array<Float>> = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ];

    public static function setColors(character:Character, mania:Int)
    {
        switch (character.curCharacter)
        {
            case 'senpai' | 'senpai-angry' | 'spirit':
                noteColors = [
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5],
                    [0, 0, 0, 5]
                ];
            default: 
                noteColors = character.noteColors;
        }
    }
    public static function resetColors()
    {
        noteColors = [
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]
        ];
    }


}