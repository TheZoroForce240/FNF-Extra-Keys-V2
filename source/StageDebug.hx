package;



import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;


class StageDebug extends MusicBeatState
{
    var bf:Boyfriend;
    var dad:Character;
    var camFollow:FlxObject;
    var daStage:String = "stage";
    var dancingStagePieces:FlxTypedGroup<StagePiece>;

    var pieces:Array<String> = [];
    var zoom:Float = 1.05;
    var offsetMap:Map<String, Array<Dynamic>>;

    public function new(daStage:String = 'stage')
    {
        super();
        this.daStage = daStage;
    }

    override function create()
    {
        dancingStagePieces = new FlxTypedGroup<StagePiece>();
		add(dancingStagePieces);

        StagePiece.StageCheck(daStage);
        pieces = PlayState.stageData[0];

        for (i in 0...pieces.length) //x and y are optional and set in StagePiece.hx, so for loop can be used
			{
				var piece:StagePiece = new StagePiece(0, 0, pieces[i]);
				if (piece.danceable)
					dancingStagePieces.add(piece);


				if (pieces[i] == 'bgDancer')
					piece.x += (370 * (i - 2));
				
				piece.x += piece.newx;
				piece.y += piece.newy;
				add(piece);
			}

        camFollow = new FlxObject(0, 0, 2, 2);
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.E)
            FlxG.camera.zoom += 0.25;
        if (FlxG.keys.justPressed.Q)
            FlxG.camera.zoom -= 0.25;

        if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
        {
            if (FlxG.keys.pressed.I)
                camFollow.velocity.y = -350;
            else if (FlxG.keys.pressed.K)
                camFollow.velocity.y = 350;
            else
                camFollow.velocity.y = 0;

            if (FlxG.keys.pressed.J)
                camFollow.velocity.x = -350;
            else if (FlxG.keys.pressed.L)
                camFollow.velocity.x = 350;
            else
                camFollow.velocity.x = 0;
        }
        else
        {
            camFollow.velocity.set();
        }

        if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new DebugState());

        super.update(elapsed);
    }

    override function beatHit()
    {
        super.beatHit();

        StagePiece.daBeat = curBeat;
		for (piece in dancingStagePieces.members)
			piece.dance();
    }

}