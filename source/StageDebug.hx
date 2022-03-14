package;



import flixel.math.FlxMath;
import StagePiece.PieceAnims;
import openfl.filters.ShaderFilter;
import flixel.ui.FlxButton;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import StagePiece.StageOffset;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import openfl.filters.ShaderFilter;
import flixel.FlxSubState;
using StringTools;
import Shaders;

import openfl.desktop.Clipboard;

class StageDebug extends MusicBeatState
{
    var _file:FileReference;

    var camFollow:FlxObject;
    var daStage:String = "stage";
    var StagePieces:FlxTypedGroup<DebugStagePiece>;
    var PiecePosBoxes:FlxTypedGroup<FlxSprite>;
    var layerNums:FlxTypedGroup<FlxText>;
    var defaultCamZoom = 1.05;

    var pieces:Array<String> = [];
    var zoom:Float = 1.05;
    var offsetMap:Map<String, Array<Float>>;

    var stageOffsets:Array<StageOffset>;

    public var selectedPiece:DebugStagePiece = null;
    var camHUD:FlxCamera;
    var camGame:FlxCamera;

    var Stage_UI:FlxUITabMenu;
    var Piece_UI:FlxUITabMenu;

    var bf:DebugCharacter;
    var gf:DebugCharacter;
    var dad:DebugCharacter;
    var pieceText:FlxText;

    var tempLayerNum:Int = 0;
    var pieceDropMenu:FlxUIDropDownMenu = null;

    public static var instance:StageDebug;
    var dadCharacter:String = "dad";

    public function new(daStage:String = 'stage', _dad:String = "dad")
    {
        super();
        this.daStage = daStage;
        dadCharacter = _dad;
    }

    override function create()
    {
        instance = this;

        StagePieces = new FlxTypedGroup<DebugStagePiece>();
		add(StagePieces);
        PiecePosBoxes = new FlxTypedGroup<FlxSprite>();
        add(PiecePosBoxes);
        layerNums = new FlxTypedGroup<FlxText>();
        add(layerNums);

        offsetMap = new Map<String, Array<Float>>();

        loadStage();
        loadPieces();
        if (StagePieces.length > 0)
            selectedPiece = StagePieces.members[0];

        var characterList:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		if (!characterList.contains(dadCharacter))
			dadCharacter = "dad";

        gf = new DebugCharacter(PlayState.gfDefaultPos[0], PlayState.gfDefaultPos[1], "gf");
        dad = new DebugCharacter(PlayState.dadDefaultPos[0], PlayState.dadDefaultPos[1], dadCharacter);
        bf = new DebugCharacter(PlayState.bfDefaultPos[0], PlayState.bfDefaultPos[1], "bf", false, true);
        var stupidArray:Array<String> = ['dad', 'bf', 'gf'];
		var stupidCharArray:Array<Dynamic> = [dad, bf, gf];
		//stage offsets
		for (i in 0...stupidArray.length)
		{
			var offset = offsetMap.get(stupidArray[i]);
			if (offsetMap.exists(stupidArray[i]))
			{
				stupidCharArray[i].x += offset[0];
				stupidCharArray[i].y += offset[1];
			}
		}


        bf.posBox = new FlxSprite(bf.x, bf.y).makeGraphic(25, 25, FlxColor.CYAN);
        gf.posBox = new FlxSprite(gf.x, gf.y).makeGraphic(25, 25, FlxColor.RED);
        dad.posBox = new FlxSprite(dad.x, dad.y).makeGraphic(25, 25, FlxColor.PURPLE);

        add(gf);
        add(dad);
        add(bf);
        add(bf.posBox);
        add(gf.posBox);
        add(dad.posBox);

        camFollow = new FlxObject(0, 0, 2, 2);
		add(camFollow);

        camGame = new FlxCamera();
        FlxG.cameras.reset(camGame);
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        FlxCamera.defaultCameras = [camGame];

        var piecetabs = [
			{name: "Piece", label: 'Piece'},
			{name: "Anims", label: 'Anims'}
		];

        var stagetab = [
            {name: "Stage", label: 'Stage'},
            {name: "Offsets", label: 'Offsets'}
        ];

		Piece_UI = new FlxUITabMenu(null, piecetabs, true);

		Piece_UI.resize(300, 400);
		Piece_UI.x = FlxG.width - 320;
		Piece_UI.y = 20;
		add(Piece_UI);
        Piece_UI.scrollFactor.set();
        Piece_UI.cameras = [camHUD];

        Stage_UI = new FlxUITabMenu(null, stagetab, true);
		Stage_UI.resize(300, 200);
		Stage_UI.x = 100;
		Stage_UI.y = 500;
		add(Stage_UI);
        Stage_UI.scrollFactor.set();
        Stage_UI.cameras = [camHUD];

        createOffsetUI();
        createStageUI();
        createAnimUI();
        createPieceUI();

        pieceText = new FlxText(0, 0, 0, "", 40);
		pieceText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		pieceText.scrollFactor.set();
		add(pieceText);
        pieceText.cameras = [camHUD];

		FlxG.camera.follow(camFollow);

		super.create();
    }
    var bfstepperx:FlxUINumericStepper;
    var bfsteppery:FlxUINumericStepper;
    var gfstepperx:FlxUINumericStepper;
    var gfsteppery:FlxUINumericStepper;
    var dadstepperx:FlxUINumericStepper;
    var dadsteppery:FlxUINumericStepper;
    var zoomStepper:FlxUINumericStepper;

    function createOffsetUI()
    {
		bfstepperx = new FlxUINumericStepper(10, 20, 1,0, -9999, 9999, 0, 1);
		bfstepperx.value = bf.posBox.x;
		bfstepperx.name = 'bfPosx';

        bfsteppery = new FlxUINumericStepper(100, 20, 1,0, -9999, 9999, 0, 1);
		bfsteppery.value = bf.posBox.y;
		bfsteppery.name = 'bfPosy';
        
        gfstepperx = new FlxUINumericStepper(10, 60, 1,0, -9999, 9999, 0, 1);
		gfstepperx.value = gf.posBox.x;
		gfstepperx.name = 'gfPosx';
        gfsteppery = new FlxUINumericStepper(100, 60, 1,0, -9999, 9999, 0, 1);
		gfsteppery.value = gf.posBox.y;
		gfsteppery.name = 'gfPosy';

        dadstepperx = new FlxUINumericStepper(10, 100, 1,0, -9999, 9999, 0, 1);
		dadstepperx.value = dad.posBox.x;
		dadstepperx.name = 'dadPosx';

        dadsteppery = new FlxUINumericStepper(100, 100, 1,0, -9999, 9999, 0, 1);
		dadsteppery.value = dad.posBox.y;
		dadsteppery.name = 'dadPosy';

        zoomStepper = new FlxUINumericStepper(200, 30, 0.05, 1.05, 0.1, 10, 2);
        zoomStepper.value = defaultCamZoom;
        zoomStepper.name = 'zoom';
        var testZoom:FlxButton = new FlxButton(200, 60, "Test Zoom", function()
        {
            FlxG.camera.zoom = defaultCamZoom;
        });

        var bfLabel = new FlxText(55, 0, 0, "BF Offsets");

        var gfLabel = new FlxText(55, 40, 0, "GF Offsets");

        var dadLabel = new FlxText(55, 80, 0, "DAD Offsets");

        var camZoomLabel = new FlxText(200, 10, 0, "Default Cam Zoom");

		var tab_group_offset = new FlxUI(null, Stage_UI);
		tab_group_offset.name = "Offsets";
		tab_group_offset.add(bfLabel);
        tab_group_offset.add(gfLabel);
        tab_group_offset.add(dadLabel);
        tab_group_offset.add(camZoomLabel);

        tab_group_offset.add(zoomStepper);
        tab_group_offset.add(testZoom);

		tab_group_offset.add(bfstepperx);
        tab_group_offset.add(bfsteppery);
        tab_group_offset.add(gfstepperx);
        tab_group_offset.add(gfsteppery);
        tab_group_offset.add(dadstepperx);
        tab_group_offset.add(dadsteppery);

		Stage_UI.addGroup(tab_group_offset);
    }
    var layerStepper:FlxUINumericStepper;
    var selectedPieceName:String = "";
    function createStageUI()
    {

        var stagenameLabel = new FlxText(10, 0, 0, "Stage Name: " + daStage);
        var stageSelect:FlxButton = new FlxButton(10, 20, "Set Stage Name", function()
        {
            openSubState(new SelectionSubState('inputText', function(name:String)
            {
                daStage = name;
                stagenameLabel.text = "Stage Name: " + name;
            }, 'Enter Stage Name'));
        });
        stageSelect.scale.x *= 1.2;
        stageSelect.updateHitbox();

        var pieceLabel = new FlxText(10, 40, 0, "Piece Name: ");
        var pieceSelect:FlxButton = new FlxButton(10, 60, "Set Piece Name", function()
        {
            openSubState(new SelectionSubState('inputText', function(name:String)
            {
                selectedPieceName = name;
                pieceLabel.text = "Piece Name: " + name;
            }, 'Enter Piece Name'));
        });
        pieceSelect.scale.x *= 1.2;
        pieceSelect.updateHitbox();


        var layerLabel = new FlxText(25, 100, 0, "Layer Number");
        layerStepper = new FlxUINumericStepper(25, 120, 1, 0, 0, 999);
        layerStepper.value = tempLayerNum;
        layerStepper.name = 'layer';

        var layerUpdate:FlxButton = new FlxButton(110, 120, "Update Layer", function()
        {
            if (pieces.contains(selectedPieceName))
            {
                pieces.remove(selectedPieceName);
                pieces.insert(tempLayerNum, selectedPieceName); //updates layering in piece array
            }
            /*var temp:Array<DebugStagePiece> = [];
            for (piece in StagePieces)
            {
                temp.push(piece);
                StagePieces.remove(piece); //remove piece from group put temporaily store it in temp so it can be readded in the correct order
            }
            for (i in 0...pieces.length)
            {
                for (ii in 0...temp.length)
                {
                    if (temp[ii].part == pieces[i])
                    {
                        StagePieces.add(temp[ii]);
                        temp[ii].layerNumber.text = "" + i;
                    }
                }
            }*/
            loadPieces();
        });

        var addPiece:FlxButton = new FlxButton(210, 20, "Add Piece", function()
        {
            if (selectedPieceName != "")
                pieces.push(selectedPieceName);
            loadPieces();
        });

        var removePiece:FlxButton = new FlxButton(210, 60, "Remove Piece", function()
        {
            if (pieces.contains(selectedPieceName))
                pieces.remove(selectedPieceName);
            loadPieces();
        });

        /*var reloadPieces:FlxButton = new FlxButton(210, 20, "Reload Pieces", function()
        {
            loadPieces();
        });*/


        var saveShit:FlxButton = new FlxButton(10, 150, "Save Stage", function()
        {
            saveStage();
        });

        var pieceListSelection:FlxButton = new FlxButton(210, 120, "Pick Piece From List", function()
        {
            openSubState(new SelectionSubState('list', function(name:String)
            {
                selectedPieceName = name;                
                tempLayerNum = SelectionSubState.selectedItemID;
                layerStepper.value = tempLayerNum;
                if (StagePieces.members[tempLayerNum] != null)
                    selectedPiece = StagePieces.members[tempLayerNum];
            }, '',pieces));
        });
        pieceListSelection.scale.y *= 1.5;
        pieceListSelection.updateHitbox();

        var tab_group_stage = new FlxUI(null, Stage_UI);
        tab_group_stage.name = "Stage";
        tab_group_stage.add(stageSelect);
        tab_group_stage.add(pieceSelect);
        tab_group_stage.add(stagenameLabel);
        tab_group_stage.add(pieceLabel);

        tab_group_stage.add(layerLabel);
        tab_group_stage.add(layerStepper);
        tab_group_stage.add(layerUpdate);

        tab_group_stage.add(pieceListSelection);

        tab_group_stage.add(saveShit);

        tab_group_stage.add(addPiece);
        tab_group_stage.add(removePiece);
        //tab_group_stage.add(reloadPieces);

        Stage_UI.addGroup(tab_group_stage);
    }

    private function getAnimList():Array<String>
    {
        var list:Array<String> = [];
        for (i in selectedPiece.anims)
            list.push(i.anim);
        return list;

    }

    var curAnimName:String = "";
    var curXmlName:String = "";
    var curFrameRate:Int = 24;
    var curLoopedToggle:Bool = false;
    var fpsStepper:FlxUINumericStepper;
    private function createAnimUI()
    {
        var tab_group_anim = new FlxUI(null, Stage_UI);
        tab_group_anim.name = "Anims";
        var updateAnim:FlxButton = new FlxButton(10, 10, "Update Anim", function()
        {
            for (i in selectedPiece.anims)
                if (i.anim == curAnimName)
                    selectedPiece.anims.remove(i); //remove the anim so it can be replaced 

            var animShit:PieceAnims = {
                anim: curAnimName,
                xmlname: curXmlName,
                frameRate: curFrameRate,
                loop: curLoopedToggle
            };
            selectedPiece.anims.push(animShit);
        });
        var removeAnim:FlxButton = new FlxButton(100, 10, "Remove Anim", function()
        {
            for (i in selectedPiece.anims)
                if (i.anim == curAnimName)
                    selectedPiece.anims.remove(i); //remove the anim so it can be replaced 
        });

        var curAnimNameLabel = new FlxText(10, 100, 0, "Anim Name: " + curAnimName);
        var animNameSelect:FlxButton = new FlxButton(100, 100, "Set Anim Name", function()
        {
            openSubState(new SelectionSubState('inputText', function(name:String)
            {
                curAnimName = name;
                curAnimNameLabel.text = "Anim Name: " + name;
            }, 'Enter Anim Name'));
        });
        var curXmlNameLabel = new FlxText(10, 125, 0, "Xml Prefix: " + curXmlName); //ik its technically not xmlname but prefix idc lol
        var xmlNameSelected:FlxButton = new FlxButton(100, 125, "Set Xml Prefix", function()
        {
            openSubState(new SelectionSubState('inputText', function(name:String)
            {
                curXmlName = name;
                curXmlNameLabel.text = "Xml Prefix: " + name;
            }, 'Enter Xml Prefix'));
        });
        var curFrameRateLabel = new FlxText(15, 150, 0, "Frame Rate: ");
        fpsStepper = new FlxUINumericStepper(30, 150, 1, 24, 0, 999, 0);
        fpsStepper.value = curFrameRate;
        fpsStepper.name = 'fps';
        var loopedBox = new FlxUICheckBox(10, 175, null, null, "Looped", 100);
		loopedBox.checked = false;
		loopedBox.callback = function()
		{
			curLoopedToggle = loopedBox.checked;
		};


        var animListSelection:FlxButton = new FlxButton(210, 120, "Pick Anim From List", function()
        {
            openSubState(new SelectionSubState('list', function(name:String)
            {
                for (i in selectedPiece.anims)
                    if (i.anim == name)
                    {
                        curAnimName = i.anim;
                        curXmlName = i.xmlname;
                        curFrameRate = i.frameRate;
                        curLoopedToggle = i.loop;
                        break;
                    }        
            }, '',getAnimList()));
        });

        var isAnimatedBox = new FlxUICheckBox(10, 250, null, null, "Is Animated", 100);
		isAnimatedBox.checked = false;
		isAnimatedBox.callback = function()
		{
			selectedPiece.animated = isAnimatedBox.checked;
		};

        var danceableBox = new FlxUICheckBox(10, 300, null, null, "Danceable", 100);
		danceableBox.checked = false;
		danceableBox.callback = function()
		{
			selectedPiece.danceable = danceableBox.checked;
		};

        tab_group_anim.add(isAnimatedBox);
        tab_group_anim.add(danceableBox);
        tab_group_anim.add(animListSelection);
        tab_group_anim.add(updateAnim);
        tab_group_anim.add(removeAnim);
        tab_group_anim.add(curAnimNameLabel);
        tab_group_anim.add(curXmlNameLabel);
        tab_group_anim.add(curFrameRateLabel);
        tab_group_anim.add(animNameSelect);
        tab_group_anim.add(xmlNameSelected);
        tab_group_anim.add(fpsStepper);
        tab_group_anim.add(loopedBox);
        Piece_UI.addGroup(tab_group_anim);
    }
    private function createPieceUI()
    {
        var tab_group_piece = new FlxUI(null, Stage_UI);
        tab_group_piece.name = "Pieces";

        var saveShit:FlxButton = new FlxButton(10, 10, "Save Piece", function()
        {
            savePiece();
        });
        tab_group_piece.add(saveShit);
        Piece_UI.addGroup(tab_group_piece);
    }

    override function update(elapsed:Float)
    {
        if (selectedPiece != null)
        {
            pieceText.text = "";
            pieceText.text += "Selected Piece: " + selectedPiece.part + "\n";
            pieceText.text += "X: " + selectedPiece.x + "\n";
            pieceText.text += "Y: " + selectedPiece.y + "\n";
            pieceText.text += "Scale: " + selectedPiece.scaleShit + "\n";
            pieceText.text += "Scroll factor: " + selectedPiece.scrollFactor.x + ", " + selectedPiece.scrollFactor.y + "\n";
            pieceText.text += "Flipped: " + selectedPiece.flipX + "\n";
            pieceText.text += "Layer Number: " + selectedPiece.layerNumber.text + "\n";
        }
        updateShit();




  
        if (FlxG.mouse.wheel != 0)
        {
            FlxG.camera.zoom += 0.1 * FlxG.mouse.wheel;
        }
        if (FlxG.keys.justPressed.E)
            FlxG.camera.zoom += 0.25;
        if (FlxG.keys.justPressed.Q)
            FlxG.camera.zoom -= 0.25;

        if (FlxG.keys.pressed.W || FlxG.keys.pressed.A || FlxG.keys.pressed.S || FlxG.keys.pressed.D)
        {
            var amount:Float = 1;
            if (FlxG.keys.pressed.SHIFT)
                amount *= 2;      

            if (FlxG.keys.pressed.W)
                camFollow.velocity.y = -350 * amount;
            else if (FlxG.keys.pressed.S)
                camFollow.velocity.y = 350 * amount;
            else
                camFollow.velocity.y = 0;

            if (FlxG.keys.pressed.A)
                camFollow.velocity.x = -350 * amount;
            else if (FlxG.keys.pressed.D)
                camFollow.velocity.x = 350 * amount;
            else
                camFollow.velocity.x = 0;
        }
        else
        {
            camFollow.velocity.set();

            //var bytes = Clipboard.get_image();
        }

        if (FlxG.keys.justPressed.TAB)
        {
            if (pieces.length > 1)
            {
                var idx = Std.parseInt(selectedPiece.layerNumber.text);
                for (shit in StagePieces)
                {
                    if (FlxG.keys.pressed.SHIFT)
                    {
                        if (Std.parseInt(shit.layerNumber.text) == idx - 1) //go back a layer
                        {
                            selectedPiece = shit;
                            break;
                        }
                    }
                    else 
                    {
                        if (Std.parseInt(shit.layerNumber.text) == idx + 1) //go forward a layer
                        {
                            selectedPiece = shit;
                            break;
                        }
                    }
                }
            }
        }

        if (selectedPiece != null)
        {
            var amount:Float = 1;
            if (FlxG.keys.pressed.SHIFT)
                amount *= 10;

            if (FlxG.keys.justPressed.LEFT)
                selectedPiece.posBox.x -= amount;
            else if (FlxG.keys.justPressed.RIGHT)
                selectedPiece.posBox.x += amount;
            else if (FlxG.keys.justPressed.UP)
                selectedPiece.posBox.y -= amount;
            else if (FlxG.keys.justPressed.DOWN)
                selectedPiece.posBox.y += amount;

            if (FlxG.keys.justPressed.F)
                selectedPiece.flipX = !selectedPiece.flipX;
            else if (FlxG.keys.justPressed.O)
                changeScale(1);
            else if (FlxG.keys.justPressed.L)
                changeScale(-1);
            else if (FlxG.keys.justPressed.U)
                changeScrollX(1);
            else if (FlxG.keys.justPressed.J)
                changeScrollX(-1);
            else if (FlxG.keys.justPressed.I)
                changeScrollY(1);
            else if (FlxG.keys.justPressed.K)
                changeScrollY(-1);
        }

        if (FlxG.keys.justPressed.SPACE)
        {
            FlxG.camera.zoom = 1;
        }
        
        

        if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new DebugState());

        super.update(elapsed);
    }

    function updateShit()
    {
        bfstepperx.value = bf.posBox.x;
        bfsteppery.value = bf.posBox.y;
        gfstepperx.value = gf.posBox.x;
        gfsteppery.value = gf.posBox.y;
        dadstepperx.value = dad.posBox.x;
        dadsteppery.value = dad.posBox.y;
        curFrameRate = Std.int(fpsStepper.value);
    }

    function changeScale(change:Int)
    {
        selectedPiece.scaleShit += (change * 0.1);
        selectedPiece.scaleShit = FlxMath.roundDecimal(selectedPiece.scaleShit, 1);
    }
    function changeScrollX(change:Int)
    {
        selectedPiece.scrollFactor.x += (change * 0.1);
        selectedPiece.scrollFactor.x = FlxMath.roundDecimal(selectedPiece.scrollFactor.x, 1);
    }
    function changeScrollY(change:Int)
    {
        selectedPiece.scrollFactor.y += (change * 0.1);
        selectedPiece.scrollFactor.y = FlxMath.roundDecimal(selectedPiece.scrollFactor.y, 1);
    }

    override function beatHit()
    {
        super.beatHit();

        StagePiece.daBeat = curBeat;
		for (piece in StagePieces.members)
        {
            if (piece.danceable)
                piece.dance();
        }
			
    }

    override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
    {
        if (id == FlxUICheckBox.CLICK_EVENT)
        {
            var check:FlxUICheckBox = cast sender;
            var label = check.getLabel().text;
            switch (label)
            {

            }
        }
        else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
        {
            var nums:FlxUINumericStepper = cast sender;
            var wname = nums.name;
            //FlxG.log.add(wname);
            switch (wname)
            {
                case "bfPosx": 
                    bf.posBox.x = nums.value;
                case "bfPosy": 
                    bf.posBox.y = nums.value;
                case "gfPosx": 
                    gf.posBox.x = nums.value;
                case "gfPosy": 
                    gf.posBox.y = nums.value;
                case "dadPosx": 
                    dad.posBox.x = nums.value;
                case "dadPosy": 
                    dad.posBox.y = nums.value;
                case "zoom": 
                    defaultCamZoom = nums.value;
                case "layer": 
                    tempLayerNum = Std.int(nums.value);
            }
        }
    }

    private function loadStage()
    {
        pieces = [];
        defaultCamZoom = 1.05;
        stageOffsets = [];
        offsetMap.clear();

        StagePiece.StageCheck(daStage);
        pieces = PlayState.stageData[0];
        defaultCamZoom = PlayState.stageData[2];
        offsetMap = PlayState.stageData[3];

        for (i in offsetMap.keys()) //convert map to array to so it can be saved into the json
        {
            var offset:StageOffset = {
                type: i,
                offsets: offsetMap[i]
            };
            stageOffsets.push(offset);
        }
    }
    private function loadPieces()
    {
        for (piece in StagePieces.members)
        {
            offsetMap[piece.part] = [piece.x, piece.y, piece.scaleShit, piece.scrollFactor.x, piece.scrollFactor.y]; //save current pos
        }
        StagePieces.clear();
        PiecePosBoxes.clear();
        layerNums.clear();
        if (pieces.length > 0)
        {
            for (i in 0...pieces.length)
            {
                var piece:DebugStagePiece = new DebugStagePiece(0, 0, pieces[i]);
    
                if (pieces[i] == 'bgDancer')
                    piece.x += (370 * (i - 2));
                
                if (offsetMap[pieces[i]] != null)
                {
                    piece.x += offsetMap[pieces[i]][0];
                    piece.y += offsetMap[pieces[i]][1];
                    piece.scaleShit = offsetMap[pieces[i]][2];
                    piece.scale.set(piece.scaleShit,piece.scaleShit);
                    piece.updateHitbox();
                    piece.scrollFactor.x = offsetMap[pieces[i]][3];
                    piece.scrollFactor.y = offsetMap[pieces[i]][4];
                }
                else 
                {
                    piece.x += piece.newx;
                    piece.y += piece.newy;
                }

                piece.posBox = new FlxSprite(piece.x, piece.y).makeGraphic(50,50,FlxColor.WHITE);
                piece.layerNumber = new FlxText(piece.x, piece.y,0, "");
                piece.layerNumber.text += i;
                piece.layerNumber.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
                //piece.posBox.scrollFactor.set(piece.scrollFactor.x, piece.scrollFactor.y);
                StagePieces.add(piece);
                PiecePosBoxes.add(piece.posBox);
                layerNums.add(piece.layerNumber);
            }
        }
    }

    private function savePiece()
    {
        if (selectedPiece == null)
            return;

        var json = {
            "position": [selectedPiece.x, selectedPiece.y], 
            "scale": selectedPiece.scaleShit,
            "flip": selectedPiece.flipX,
            "scrollFactor": [selectedPiece.scrollFactor.x, selectedPiece.scrollFactor.y],
            "aa": selectedPiece.antialiasing,
        
            "isAnimated": selectedPiece.animated,
            "anims": selectedPiece.anims,
            "animToPlay": selectedPiece.startAnim,
        
            "isDanceable": selectedPiece.danceable,
            "animToPlayOnDance": selectedPiece.danceAnim
        };

        var data:String = Json.stringify(json, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data.trim(), "data.json");
        }
    }

    private function saveStage()
    {
        var json = {
            "name": daStage,
            "camZoom": defaultCamZoom,
            "pieceArray": pieces,
            "offsets": [
                {
                    "type": 'bf',
                    "offsets": [bf.x - PlayState.bfDefaultPos[0], bf.y - PlayState.bfDefaultPos[1]] //remove the default pos so it offsets correctly in game
                },
                {
                    "type": 'gf',
                    "offsets": [gf.x - PlayState.gfDefaultPos[0], gf.y - PlayState.gfDefaultPos[1]]
                },
                {
                    "type": 'dad',
                    "offsets": [dad.x - PlayState.dadDefaultPos[0], dad.y - PlayState.dadDefaultPos[1]]
                }
            ]
        };

        var data:String = Json.stringify(json, "\t");

        if ((data != null) && (data.length > 0))
        {
            _file = new FileReference();
            _file.addEventListener(Event.COMPLETE, onSaveComplete);
            _file.addEventListener(Event.CANCEL, onSaveCancel);
            _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            _file.save(data.trim(), json.name.toLowerCase() + ".json");
        }
    }

    function onSaveComplete(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.notice("Successfully saved LEVEL DATA.");
    }

    /**
     * Called when the save file dialog is cancelled.
     */
    function onSaveCancel(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
    }

    /**
     * Called if there is an error while saving the gameplay recording.
     */
    function onSaveError(_):Void
    {
        _file.removeEventListener(Event.COMPLETE, onSaveComplete);
        _file.removeEventListener(Event.CANCEL, onSaveCancel);
        _file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        _file = null;
        FlxG.log.error("Problem saving Level data");
    }

    override function openSubState(SubState:FlxSubState)
    {
        persistentUpdate = false;
        super.openSubState(SubState);
    }
    override function closeSubState()
    {
        persistentUpdate = true;
        super.closeSubState();
    }


}




class DebugCharacter extends Character 
{
    public var posBox:FlxSprite;
    public var grabbed:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf', isPlayer:Bool = true, flip:Bool = false)
    {
        super(x, y, char, isPlayer, flip);
    }
    override function update(elapsed:Float)
    {
        if (posBox != null)
        {
            this.setPosition(posBox.x, posBox.y);
            var offset = this.posOffsets.get('pos');
            if (this.posOffsets.exists('pos'))
            {
                this.x += offset[0];
                this.y += offset[1];
            }
        }

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.mouse.overlaps(posBox))
            {
                grabbed = true;
            }
        }
        if (FlxG.mouse.justReleased)
            grabbed = false;


        if (grabbed)
        {
            color = 0x016BC5;
            posBox.setPosition(FlxG.mouse.x, FlxG.mouse.y);
        }
        else
            color = 0xFFFFFFFF;
    
    }
}

class DebugStagePiece extends StagePiece
{
    public var posBox:FlxSprite;
    public var grabbed:Bool = false;
    public var layerNumber:FlxText;

    public function new(x:Float = 0, y:Float = 0, ?piece:String = "stageFront")
    {
        super(x, y, piece);
    }
    override function update(elapsed:Float)
    {
        
        if (posBox != null)
        {
            this.setPosition(posBox.x, posBox.y);
            layerNumber.setPosition(this.x, this.y);
        }

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.mouse.overlaps(posBox))
            {
                grabbed = true;
                StageDebug.instance.selectedPiece = this;
            }
        }

        if (FlxG.mouse.justReleased)
            grabbed = false;

        if (grabbed)
        {
            color = 0x016BC5;
            posBox.setPosition(FlxG.mouse.x, FlxG.mouse.y);
        }
        else
            color = 0xFFFFFFFF;
            
    }
}