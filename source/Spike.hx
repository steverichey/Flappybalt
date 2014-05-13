package;

import flixel.FlxG;
import flixel.FlxSprite;

class Spike extends FlxSprite
{
	public function new(IsTop:Bool = true)
	{
		super(0, IsTop ? 0 : FlxG.height - 16);
		
		makeGraphic(FlxG.width, 16, 0);
		
		
	}
}