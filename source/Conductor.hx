package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

typedef ManiaChangeEvent = 
{
	var strumTime:Float;
	var maniaToChangeTo:Int;
	//var playernum:Int;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	/*public static var curP1NoteMania:Int = 0; //mapping changessss
	public static var curP2NoteMania:Int = 0;
	public static var prevP1NoteMania:Int = 0; 
	public static var prevP2NoteMania:Int = 0;
	public static var lastP1mChange:Float = 0; 
	public static var lastP2mChange:Float = 0;*/

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static var P1maniaChangeMap:Array<ManiaChangeEvent>;
	public static var P2maniaChangeMap:Array<ManiaChangeEvent>;

	public function new()
	{
	}

	public static function recalculateTimings()
	{
		//Conductor.safeFrames = FlxG.save.data.frames;
		Conductor.safeZoneOffset = Math.floor(((Conductor.safeFrames / 60) * 1000) * PlayState.SongSpeedMultiplier);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function mapManiaChanges(song:SwagSong) //get real :troll:
	{

		P1maniaChangeMap = [];
		P2maniaChangeMap = [];

		/*if (playernum == 1)
		{
			prevP1NoteMania = curP1NoteMania;
			curP1NoteMania = Std.parseInt(eventNote.eventData[1]);
			lastP1mChange = eventNote.strumTime;

			
		}
		else 
		{
			prevP2NoteMania = curP2NoteMania;
			curP2NoteMania = Std.parseInt(eventNote.eventData[1]);
			lastP2mChange = eventNote.strumTime;
		}*/
		for (i in 0...song.notes.length)
		{
			for(songNotes in song.notes[i].sectionNotes)
			{
				if (songNotes[1] >= -3 && songNotes[1] <= 0)
				{
					var eventData:Array<String> = songNotes[6];
					if (eventData != null)
					{
						if (eventData[0] == "Change P1 Mania")
						{
							var maniaChange:ManiaChangeEvent = {
								strumTime: songNotes[0],
								maniaToChangeTo: Std.parseInt(eventData[1])
							};
							P1maniaChangeMap.push(maniaChange);
						}
						else if (eventData[0] == "Change P2 Mania")
						{
							var maniaChange:ManiaChangeEvent = {
								strumTime: songNotes[0],
								maniaToChangeTo: Std.parseInt(eventData[1])
							};
							P2maniaChangeMap.push(maniaChange);
						}
					}	
				}
				
			}
		}
		trace("new Mania map BUDDY " + P1maniaChangeMap);
		trace("new Mania map BUDDY " + P2maniaChangeMap);
	}
}
