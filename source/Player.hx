package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKeyName;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	public var score(default, null):Int = 0;
	
	private var _button:FlxKeyName;
	private var _only:Bool = false;
	private var _spawn:FlxPoint;
	
	public function new(Button:FlxKeyName, First:Bool = false)
	{
		super();
		
		FlxSpriteUtil.screenCenter(this);
		
		loadGraphic( "assets/dove.png", true, 8, 8);
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		animation.frameIndex = 2;
		animation.add("flap", [1, 0, 1, 2], 12, false);
		
		elasticity = 1;
		allowCollisions = FlxObject.NONE;
		
		_button = Button;
		
		if (!First)
		{
			color = FlxRandom.color( { max: 64 } );
			x += FlxRandom.float( -20, 20);
			y += FlxRandom.float( -20, 20);
		}
		
		_spawn = new FlxPoint(x, y);
	}
	
	override public function update():Void
	{
		if (justFlapped())
		{
			if ( acceleration.y == 0 || velocity.x == 0 )
			{
				acceleration.y = 500;
				velocity.x = 80;
				allowCollisions = FlxObject.ANY;
			}
			
			velocity.y = -240;
			
			animation.play( "flap", true );
		}
		
		if (velocity.x < 0)
		{
			facing = FlxObject.LEFT;
		}
		else
		{
			facing = FlxObject.RIGHT;
		}
		
		super.update();
	}
	
	public function bounce():Void
	{
		score++;
	}
	
	private function justFlapped():Bool
	{
		#if !FLX_NO_TOUCH
		return FlxG.touches.getFirst() != null ? FlxG.touches.getFirst().justPressed : false;
		#else
		return FlxG.keys.anyJustPressed([_button]);
		#end
	}
	
	override public function kill():Void
	{
		if(!exists)
			return;
		
		Reg.PS.launchFeathers( x, y, 10, color );
		
		super.kill();
		
		if (score < Reg.highScore)
		{
			Reg.highScore = score;
		}
		
		FlxG.camera.flash( color, 0.25, onFlashDone );
		FlxG.camera.shake( 0.02, 0.25 );
	}
	
	override public function revive():Void
	{
		x = _spawn.x;
		y = _spawn.y;
		acceleration.x = 0;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		score = 0;
		
		super.revive();
	}
	
	public function onFlashDone():Void
	{
		revive();
		Reg.PS.reset();
	}
}