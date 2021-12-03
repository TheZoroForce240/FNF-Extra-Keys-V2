package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.math.FlxPoint;



class StrumLineGroup extends FlxTypedGroup<BabyArrow> //stores notes, notesplashes and strum notes in one class (mainly used for strumline angleling)
{
    public var notes:FlxTypedGroup<Note>;
    public var noteSplashes:FlxTypedGroup<NoteSplash>;
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

        noteSplashes = new FlxTypedGroup<NoteSplash>(); //note splash spawning before the song
		var daSplash = new NoteSplash(100, 100, 0);
		daSplash.alpha = 0;
		noteSplashes.add(daSplash);

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