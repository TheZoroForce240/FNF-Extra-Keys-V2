package;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionEvents:Array<NoteEvent>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}


typedef NoteEvent = 
{
	var type:String;
	var strumTime:Float;
	var arg1:Dynamic;
	var arg2:Dynamic;
	var arg3:Dynamic;
	var arg4:Dynamic;
	var arg5:Dynamic;
	var extraArgs:Array<Dynamic>;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];
	public var sectionEvents:Array<NoteEvent> = [];
	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
