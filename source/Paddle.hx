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
	
	public function new( X:Float = 0 )
	{
		super( X, FlxG.height );
		loadGraphic( "images/paddle.png" );
		setFacingFlip(FlxObject.LEFT, true, false);
		facing = X < FlxG.width / 2 ? FlxObject.RIGHT : FlxObject.LEFT;
	}
	
	public function randomize():VarTween
	{
		return FlxTween.tween(this, { y: FlxRandom.float(17, FlxG.height - 34 - height )}, FlxRandom.float(0.75, 1.5), { ease: FlxEase.bounceOut } );
	}
}