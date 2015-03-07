package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

class Paddle extends FlxSprite
{
	public var targetY:Int = 0;
	
	inline static private var MIN_MOVE_TIME:Float = 0.75;
	inline static private var MAX_MOVE_TIME:Float = 1.5;
	
	public function new( X:Float = 0 )
	{
		super( X, FlxG.height );
		loadGraphic( "images/paddle.png" );
		setFacingFlip(FlxObject.LEFT, true, false);
		facing = X < FlxG.width / 2 ? FlxObject.RIGHT : FlxObject.LEFT;
	}
	
	public function randomize():VarTween
	{
		return FlxTween.tween(this, { y: FlxG.random.float(17, FlxG.height - 34 - height )}, FlxG.random.float(MIN_MOVE_TIME, MAX_MOVE_TIME), { ease: FlxEase.bounceOut } );
	}
	
	public function remove(X:Float = 0, Y:Float = 0):Void
	{
		#if mobile
		y = FlxG.height;
		#else
		FlxTween.tween(this, { y: FlxG.height }, FlxG.random.float(MIN_MOVE_TIME, MAX_MOVE_TIME), { ease: FlxEase.backIn } );
		#end
	}
}