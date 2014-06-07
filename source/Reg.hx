package;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.util.FlxSave;

class Reg
{
	/**
	 * High score storage.
	 */
	static public var highScore:Int = 0;
	
	/**
	 * A reference to the active playstate. Lets you call Reg.PS globally to access the playstate.
	 */
	static public var PS:PlayState;
	
	/**
	 * Used for saving and loading high scores.
	 */
	static public var save:FlxSave;
	
	inline static public var WHITE:Int = 0xffFFFFFF;
	inline static public var GREY_LIGHT:Int = 0xffB0B0BF;
	inline static public var GREY_MED:Int = 0xff646A7D;
	inline static public var GREY_DARK:Int = 0xff35353D;
	inline static public var GREY_BG_MED:Int = 0xff868696;
}