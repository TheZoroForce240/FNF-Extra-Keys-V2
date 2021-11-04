package;
import lime.utils.PackedAssetLibrary;
import Song.SwagSong;
import flixel.math.FlxMath;
class SongRating
{
    public static function CalculateSongRating(SONG:SwagSong)
    {
        var p1Rating:Float = 0;
        var p2Rating:Float = 0;
        var player1Notes:Array<CalcNote> = [];
        var player2Notes:Array<CalcNote> = [];
        var p1Amount:Int = 0;
        var p2Amount:Int = 0;
        var p1NoteTypeAmount:Int = 0;
        var p2NoteTypeAmount:Int = 0;
        var totalP1Strum:Float = 0;
        var totalP2Strum:Float = 0;
        var lastNoteData = 0;

        var p1notesPerSection:Array<Int> = [];
        var p2notesPerSection:Array<Int> = [];
        var amountOfSections:Int = 0;
        if (SONG.notes != null && SONG.notes.length != 0)
        {
            
            for (section in SONG.notes)
            {
                amountOfSections++;
                var p1NoteNum:Int = 0;
                var p2NoteNum:Int = 0;
                for (daNote in section.sectionNotes) // notes
                {
                    var mustPress:Bool = section.mustHitSection;

                    if (daNote[1] >= PlayState.keyAmmo[SONG.mania])
                        mustPress = !mustPress;

                    var daType = daNote[3];

                    var daNoteData = Std.int(daNote[1] % PlayState.keyAmmo[SONG.mania]);

                    var t = Std.int(daNote[1] / 18); //compatibility with god mode final destination (or just shaggy x matt charts)
					switch(t)
					{
						case 1: 
							daType = 2;
							daNoteData = Std.int((daNote[1] - 18) % PlayState.keyAmmo[SONG.mania]);
							mustPress = section.mustHitSection;
							if (daNote[1] >= (PlayState.keyAmmo[SONG.mania] + 18))
								mustPress = !section.mustHitSection;
						case 2: 
							daType = 3;
							daNoteData = Std.int((daNote[1] - 36) % PlayState.keyAmmo[SONG.mania]);
							mustPress = section.mustHitSection;
							if (daNote[1] >= (PlayState.keyAmmo[SONG.mania] + 36))
								mustPress = !section.mustHitSection;
					}

                    var note:CalcNote = new CalcNote(daNote[0], daNoteData, 
                        daType, mustPress, daNote[2]);

                    if (mustPress)
                    {
                        p1NoteNum++;
                        player1Notes.push(note);
                    }
                    else
                    {
                        p2NoteNum++;
                        player2Notes.push(note);
                    }         
                }
                p1notesPerSection.push(p1NoteNum);
                p2notesPerSection.push(p2NoteNum);
            }

            player1Notes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
            player2Notes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
        }

        p1Rating = averageStrumTimeDiff(player1Notes, SONG.mania);
        p2Rating = averageStrumTimeDiff(player2Notes, SONG.mania);

        p1Rating *= averageNotesPerSection(p1notesPerSection, amountOfSections);
        p2Rating *= averageNotesPerSection(p2notesPerSection, amountOfSections);


        p1Rating = FlxMath.roundDecimal((p1Rating / 100000) * 1.8, 2);
        p2Rating = FlxMath.roundDecimal((p2Rating / 100000) * 1.8, 2);
        var ratings:Array<Float> = [p1Rating, p2Rating];
        return ratings;

    }


    public static function averageNotesPerSection(notesPerSection:Array<Int>, sections:Int)
    {
        var nps:Float = 0;
        var total:Float = 0;
        var usedSections:Int = sections;
        for (i in 0...sections)
        {
            total += notesPerSection[i];
        }
            

        nps = total / usedSections;
        return nps;
    }

    public static function averageStrumTimeDiff(notes:Array<CalcNote>, mania:Int)
    {
        var lastNoteData:Int = 0;
        var noteTypesTotal:Int = 0;
        var noteTotal:Int = 0;
        var averageStrumDiff:Float = 0;
        var shitToReturn:Float = 0;
        if (notes.length != 0 && notes != null)
        {
            for (daNote in notes)
            {
                var diffMulti:Float = 1;
                if (lastNoteData == daNote.noteData)
                    diffMulti / 2; //jack detection, cant really tell how close though

                if (daNote.noteType != 1 || daNote.noteType != 5)
                    noteTypesTotal++;

                lastNoteData = daNote.noteData; 

                noteTotal++;
                var idx = notes.indexOf(daNote);
                if (notes[idx + 1] != null)
                {
                    var nextNote = notes[idx + 1];
                    averageStrumDiff += (nextNote.strumTime - daNote.strumTime) * diffMulti;
                }
            }

            if (averageStrumDiff != 0)
                shitToReturn = (averageStrumDiff - (averageStrumDiff / (noteTotal + noteTypesTotal))) * (PlayState.keyAmmo[mania] / 4);
            
            return shitToReturn;
        }
        return shitToReturn;
    }
}

class CalcNote
{
    public var strumTime:Float;
    public var noteData:Int;
    public var noteType:Int;
    public var mustPress:Bool;
    public var susLength:Int;
    public var isSustainNote:Bool = false;

	//public var normalNote:Bool = true;
	//public var warningNoteType:Bool = false;
	//public var badNoteType:Bool = false;

    public function new(_strumTime, _noteData, _noteType, _mustPress, _susLength)
    {
        strumTime = _strumTime;
        noteData = _noteData;
        noteType = _noteType;
        mustPress = _mustPress;
        susLength = _susLength;

        if (susLength > 0)
            isSustainNote = true; //wait do i need this?? idk lol
    }
}