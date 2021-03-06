package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class FloatingSpike extends FlxSprite
{
	public function new()
	{
		super(floatNotIn(20, FlxG.width / 2 - 20, FlxG.width / 2 + 20, FlxG.width - 20), FlxG.random.bool() ? 0 : FlxG.height);
		
		loadGraphic("images/floatspike.png");
		
		FlxTween.tween(this, { y: floatNotIn(20, FlxG.height / 2 - 20, FlxG.height / 2 + 20, FlxG.height - 20 - height) }, FlxG.random.float(1, 3), { ease: FlxEase.cubeInOut } );
		
		angle = FlxG.random.float( -360, 360);
		
		if (FlxG.random.bool())
		{
			angularVelocity = FlxG.random.float(30, 180);
		}
	}
	
	/**
	 * Poorly-named function to return a random value between Min1 and Max1 OR Min2 and Max2
	 * Basically used to prevent spawning spikes in the player spawn area
	 */
	private function floatNotIn(Min1:Float, Max1:Float, Min2:Float, Max2:Float):Float
	{
		return FlxG.random.bool() ? FlxG.random.float(Min1, Max1) : FlxG.random.float(Min2, Max2);
	}
}