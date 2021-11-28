package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.math.FlxPoint;


class StrumLineGroup extends FlxTypedGroup<BabyArrow>
{
    //public var strumLineAngle:Float = 0;
    public var strumLineCenter:FlxPoint;
    public var curMania:Int = 0;
    var SwagMiddle:Float = 50;
    var player:Int;
    public function new(playernum:Int)
    {
        super();
        player = playernum;
        if (SaveData.middlescroll && player == 1)
            SwagMiddle += ((FlxG.width / 2) * 0.5) + (Note.noteWidths[curMania] / 2);
        else 
            SwagMiddle += ((FlxG.width / 2) * player);

        SwagMiddle += (Note.noteWidths[curMania] * PlayState.keyAmmo[curMania]) / 2;
         
        strumLineCenter = new FlxPoint(SwagMiddle, PlayState.StrumLineStartY);
    }

    override public function update(elapsed) 
    {
        if (Note.StrumLinefollowAngle)
        {
            SwagMiddle = 50;
            if (SaveData.middlescroll && player == 1)
                SwagMiddle += ((FlxG.width / 2) * 0.5) + (Note.noteWidths[curMania] / 2);
            else 
                SwagMiddle += ((FlxG.width / 2) * player);
    
            SwagMiddle += ((Note.noteWidths[curMania] * PlayState.keyAmmo[curMania]) / 2) - (Note.noteWidths[curMania] / 2);
             
            strumLineCenter.set(SwagMiddle, PlayState.StrumLineStartY);
        }


        super.update(elapsed);
    }
}