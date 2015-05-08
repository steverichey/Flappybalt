package;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flixel.FlxGame;

class Main extends Sprite
{
	static public function main():Void
	{
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();

		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		#if portrait
		addChild(new FlxGame(160, 240, PlayState));
		#else
		addChild(new FlxGame(600, 300, PlayState));
		#end
	}
}