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
		super(FlxRandom.float(20, FlxG.width - 20), FlxRandom.chanceRoll() ? 0 : FlxG.height);
		
		loadGraphic("images/floatspike.png");
		
		FlxTween.tween(this, { y: FlxRandom.float(20, FlxG.height - 20 - height) }, FlxRandom.float(1, 3), { ease: FlxEase.cubeInOut } );
	}
}