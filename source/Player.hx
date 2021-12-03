package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxCamera;

/*
has most things that are duplicated for each player (strum groups, stats, cameras for downscroll, etc),
the strum group class has the rest of the stuff (notes, notesplash and strum notes)
*/
class Player
{

    public var strums:StrumLineGroup = null;

    public var Stats = {
		songScore : 0,
		fc : true,
		sicks : 0,
		goods : 0,
		bads : 0,
		shits : 0,
		sustainsHit : 0,
		misses : 0,
		ghostmisses : 0,
		totalNotesHit : 0,
		accuracy : 0.0,
		curRank : "None",
		combo : 0,
		highestCombo : 0,
		nps : 0,
		highestNps : 0,
		health : 1.0,
		poisonHits : 0,
		scorelerp : 0,
		acclerp : 0.0,
		npsArray : []
	};

    public var playernum:Int;
    public var noteCam:FlxCamera;
	public var noteCamSplit:FlxCamera; //splitscroll fuck you
    public var char:Boyfriend;
    public var isCpu:Bool = true;

    public function new(player:Int = 0)
    {
        playernum = player;
    }


    public function createCams()
    {
        noteCam = new FlxCamera();
		noteCam.bgColor.alpha = 0;
		noteCamSplit = new FlxCamera();
		noteCamSplit.bgColor.alpha = 0;
    }
    public function addCams()
    {
        FlxG.cameras.add(noteCam);
		FlxG.cameras.add(noteCamSplit);
    }
    public function resetStats()
    {
        Stats.songScore = 0;
		Stats.fc = true;
		Stats.sicks = 0;
		Stats.goods = 0;
		Stats.bads = 0;
		Stats.shits = 0;
		Stats.misses = 0;
		Stats.sustainsHit = 0;
		Stats.ghostmisses = 0;
		Stats.totalNotesHit = 0;
		Stats.accuracy = 0;
		Stats.curRank = "None";
		Stats.combo = 0;
		Stats.highestCombo = 0;
		Stats.nps = 0;
		Stats.highestNps = 0;
		Stats.health = 1;
		Stats.poisonHits = 0;
		Stats.npsArray = [];
    }

    public function downscrollCheck(downscroll:Bool, splitScroll:Bool)
    {
        if (downscroll)
        {
            noteCam.flashSprite.scaleY *= 1;
            noteCamSplit.flashSprite.scaleY *= 1;
        }
        if (splitScroll)
            noteCamSplit.flashSprite.scaleY *= 1; //flip back to opposite
    }

    public function createStrums()
    {
        strums = new StrumLineGroup(playernum);
    }
    public function setNoteCams()
    {
        strums.noteSplashes.cameras = [noteCam];
        strums.cameras = [noteCam];
        strums.notes.cameras = [noteCam];
    }
    public function addNotes()
    {
        strums.notes = new FlxTypedGroup<Note>();
        PlayState.instance.add(strums.notes);
    }
    public function snapCams(camHUD:FlxCamera)
    {
        noteCam.x = camHUD.x; //so they match up when it moves, pretty much will just be for modcharts and shit
		noteCam.y = camHUD.y;
		noteCam.angle = camHUD.angle;
        noteCamSplit.x = camHUD.x;
		noteCamSplit.y = camHUD.y;
		noteCamSplit.angle = camHUD.angle;
    }




}