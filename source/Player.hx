package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

#if !FLX_NO_TOUCH
import flash.events.TouchEvent;
import flash.Lib;
#end

class Player extends FlxSprite
{
	#if !FLX_NO_TOUCH
	private var _justTouched:Bool = false;
	#end
	
	public function new()
	{
		super( FlxG.width * 0.5 - 4, FlxG.height * 0.5 - 4 );
		loadGraphic( "assets/dove.png", true, 8, 8);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		animation.frameIndex = 2;
		animation.add("flap",[1,0,1,2],12,false);
		
		#if !FLX_NO_TOUCH
		Lib.current.stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchStart );
		Lib.current.stage.addEventListener( TouchEvent.TOUCH_END, onTouchEnd );
		#end
	}
	
	override public function update()
	{
		#if !FLX_NO_KEYBOARD
		if ( FlxG.keys.justPressed.SPACE ) {
		#elseif !FLX_NO_TOUCH
		if ( _justTouched ) {
		#end
			if ( acceleration.y == 0 ) {
				acceleration.y = 500;
				velocity.x = 80;
			}
			
			velocity.y = -240;
			
			animation.play( "flap", true );
		}
		
		#if !FLX_NO_TOUCH
		_justTouched = false;
		#end
		
		super.update();
	}
	
	#if !FLX_NO_TOUCH
	private function onTouchStart( t:TouchEvent ):Void
	{
		_justTouched = true;
	}
	
	private function onTouchEnd( t:TouchEvent ):Void
	{
		_justTouched = false;
	}
	#end
	
	override public function kill():Void
	{
		if(!exists)
			return;
		
		Reg.PS.launchFeathers( x, y, 10 );
		
		super.kill();
		
		FlxG.camera.flash( 0xffFFFFFF, 1, onFlashDone );
		FlxG.camera.shake( 0.02, 0.35 );
	}
	
	override public function revive():Void
	{
		x = FlxG.width * 0.5 - 4;
		y = FlxG.height * 0.5 - 4;
		acceleration.x = 0;
		acceleration.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		facing = FlxObject.RIGHT;
		
		super.revive();
	}
	
	public function onFlashDone():Void
	{
		PlayState.saveScore();
		revive();
		Reg.PS.reset();
	}
}