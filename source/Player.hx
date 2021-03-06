package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class Player extends FlxSprite
{
	public var score(default, null):Int = 0;
	public var button:FlxKey;
	public var lonely(get, never):Bool;
	
	private var _only:Bool = false;
	private var _lonelyTimer:Float = 0;
	
	private var _spawn:FlxPoint;
	private var _feathers:FlxEmitter;
	
	inline static private var HOW_LONG_UNTIL_LONELY:Float = 5;
	
	public function new(Button:FlxKey, First:Bool = false)
	{
		super();
		
		FlxSpriteUtil.screenCenter(this);
		
		loadGraphic( "images/dove.png", true, 8, 8);
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		animation.frameIndex = 2;
		animation.add("flap", [1, 0, 1, 2], 12, false);
		
		elasticity = 1;
		immovable = true;
		solid = false;
		
		button = Button;
		Reg.PS.registeredButtons.push(button);
		
		if (!First)
		{
			color = FlxColor.fromHSB(FlxG.random.int(0, 360), 1, 1);
			x += FlxG.random.float( -20, 20);
			y += FlxG.random.float( -20, 20);
		}
		
		_spawn = new FlxPoint(x, y);
		
		_feathers = new FlxEmitter();
		_feathers.loadParticles("images/feather.png", 10, 32);
		_feathers.color.set(color);
		_feathers.speed.set(-10, 10);
		_feathers.acceleration.set(10, 0);
		Reg.PS.add( _feathers );
	}
	
	override public function update(_):Void
	{
		if (justFlapped())
		{
			if ( acceleration.y == 0 || velocity.x == 0 )
			{
				acceleration.y = 500;
				velocity.x = 80;
				immovable = false;
				solid = true;
			}
			
			velocity.y = -240;
			
			FlxG.sound.play("flap");
			animation.play( "flap", true );
			Reg.PS.makeDust(x + width / 2, y);
		}
		else if (acceleration.y == 0 && velocity.x == 0)
		{
			_lonelyTimer += FlxG.elapsed;
		}
		
		if (velocity.x < 0)
		{
			facing = FlxObject.LEFT;
		}
		else
		{
			facing = FlxObject.RIGHT;
		}
		
		super.update(_);
	}
	
	private function get_lonely():Bool
	{
		return _lonelyTimer > HOW_LONG_UNTIL_LONELY;
	}
	
	public function bounce(IsBird:Bool = false):Void
	{
		score++;
		
		if (IsBird)
		{
			molt(2);
		}
	}
	
	private function justFlapped():Bool
	{
		#if !FLX_NO_TOUCH
		return FlxG.touches.getFirst() != null ? FlxG.touches.getFirst().justPressed : false;
		#else
		return FlxG.keys.anyJustPressed([button]);
		#end
	}
	
	override public function kill():Void
	{
		if (!exists)
		{
			return;
		}
		
		super.kill();
		
		molt(10);
		
		FlxG.sound.play("explode");
		FlxG.camera.flash( color, 0.25, onFlashDone );
		FlxG.camera.shake( 0.02, 0.25 );
	}
	
	override public function revive():Void
	{
		x = _spawn.x;
		y = _spawn.y;
		acceleration.set(0, 0);
		velocity.set(0, 0);
		score = 0;
		immovable = true;
		solid = false;
		
		super.revive();
	}
	
	private function molt(Amount:Int):Void
	{
		_feathers.x = x;
		_feathers.y = y;
		_feathers.start(true, 2, Amount);
	}
	
	public function onFlashDone():Void
	{
		revive();
		Reg.PS.reset();
	}
	
	override public function destroy():Void
	{
		Reg.PS.registeredButtons.remove(button);
		
		super.destroy();
	}
}