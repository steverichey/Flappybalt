package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Bumper extends FlxSprite
{
	public var stationary:Bool = false;
	
	public function new(X:Float, Y:Float, Width:Int, Height:Int, Stationary:Bool = true)
	{
		super(X, Y);
		
		loadGraphic(drawBumper(Width, Height), true, Width, Height);
		animation.add("flash", [1, 0], 8, false);
		
		immovable = true;
		elasticity = 1;
		
		stationary = Stationary;
		
		if (!Stationary)
		{
			FlxTween.tween(this, { y: FlxRandom.int(20, Std.int(FlxG.height - 20 - height)) }, FlxRandom.float(0, 10), {ease: FlxEase.elasticOut} );
		}
	}
	
	public function bounce():Void
	{
		animation.play("flash");
		FlxG.sound.play("bounce");
	}
	
	/**
	 * Draws the bumpers. Useful for mobile devices with weird resolutions.
	 * Also used for the smaller bumpers on the desktop version.
	 * 
	 * @param   Width   The width of the bumper to draw.
	 * @param	Height	The height of the bumper to draw.
	 * @return	A BitmapData object representing the paddle.
	 */
	static public function drawBumper(Width:Int, Height:Int):BitmapData
	{
		// Background for the dull frame
		
		_bitmapData = new BitmapData( Width * 2, Height, false, Reg.GREY_MED );
		
		// Background for the light frame
		
		_rect = new Rectangle( Width, 0, Width, Height );
		_bitmapData.fillRect( _rect, Reg.GREY_LIGHT );
		
		// Left line for dull frame
		
		_rect = new Rectangle( 0, 1, 1, Height - 2 );
		_bitmapData.fillRect( _rect, Reg.GREY_DARK );
		
		// Right line for dull frame
		
		_rect.x = Width - 1;
		_bitmapData.fillRect( _rect, Reg.GREY_DARK );
		
		// Top line for dull frame
		
		_rect = new Rectangle( 1, 0, Width - 2, 1 );
		_bitmapData.fillRect( _rect, Reg.GREY_DARK );
		
		// Bottom line for dull frame
		
		_rect.y = Height - 1;
		_bitmapData.fillRect( _rect, Reg.GREY_DARK );
		
		// Left line for light frame
		
		_rect = new Rectangle(Width * 2, 1, 1, Height - 2 );
		_bitmapData.fillRect( _rect, Reg.WHITE );
		
		// Right line for light frame
		
		_rect.x = Width * 2 - 1;
		_bitmapData.fillRect( _rect, Reg.WHITE );
		
		// Top line for light frame
		
		_rect = new Rectangle( Width + 1, 0, Width - 2, 1 );
		_bitmapData.fillRect( _rect, Reg.WHITE );
		
		// Bottom line for light frame
		
		_rect.y = Height - 1;
		_bitmapData.fillRect( _rect, Reg.WHITE );
		
		return _bitmapData;
	}
	
	static private var _bitmapData:BitmapData;
	static private var _rect:Rectangle;
}