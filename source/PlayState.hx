package;

import flash.Lib;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxRandom;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	private var _player:Player;
	private var _bounceLeft:FlxSprite;
	private var _bounceRight:FlxSprite;
	private var _paddleLeft:Paddle;
	private var _paddleRight:Paddle;
	private var _spikeBottom:Spike;
	private var _spikeTop:Spike;
	private var _scoreDisplay:FlxText;
	private var _feathers:FlxEmitter;
	private var _highScore:FlxText;
	
	#if !FLX_NO_MOUSE
	private var _dragging:Bool = false;
	#end
	
	inline static private var SAVE_DATA:String = "FLAPPYBALT";
	
	override public function create():Void
	{
		super.create();
		
		// Keep a reference to this state in Reg for global access.
		
		Reg.PS = this;
		
		// Set background color identical to the bottom of the "city", so on tall screens there's not a big black bar at the bottom.
		
		FlxG.camera.bgColor = 0xff646A7D;
		
		// Hide the mouse.
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		// The background city.
		
		var bg:FlxSprite = new FlxSprite(0, 0, "assets/bg.png");
		FlxSpriteUtil.screenCenter(bg);
		
		// To make the game screen-width agnostic, add some faux backgrounds below the city graphic
		
		var bgWidth:Int = Std.int((FlxG.width - bg.width) / 2);
		
		if (bgWidth > 0)
		{
			var leftLite:FlxSprite = new FlxSprite();
			leftLite.makeGraphic(bgWidth, Std.int(bg.y + 79), Reg.GREY_LIGHT);
			
			var rightLite:FlxSprite = new FlxSprite(bg.x + bg.width, 0);
			rightLite.makeGraphic(bgWidth, Std.int(bg.y + 93), Reg.GREY_LIGHT);
			
			var leftMed:FlxSprite = new FlxSprite(0, leftLite.y + leftLite.height);
			leftMed.makeGraphic(bgWidth, 61, Reg.GREY_BG_MED);
			
			var rightMed:FlxSprite = new FlxSprite(bg.x + bg.width, rightLite.y + rightLite.height);
			rightMed.makeGraphic(bgWidth, 7, Reg.GREY_BG_MED);
			
			add(rightMed);
			add(leftMed);
			add(rightLite);
			add(leftLite);
		}
		
		add(bg);
		
		// Current score.
		
		_scoreDisplay = new FlxText( 0, 180, FlxG.width );
		_scoreDisplay.alignment = "center";
		_scoreDisplay.color = 0xff868696;
		_scoreDisplay.size = 24;
		add( _scoreDisplay );
		
		// Update all-time high score.
		
		Reg.highScore = loadScore();
		
		// Display high score.
		
		_highScore = new FlxText( 0, 40, FlxG.width, "" );
		_highScore.alignment = "center";
		_highScore.color = 0xff868696;
		add( _highScore );
		
		if ( Reg.highScore > 0 )
			_highScore.text = Std.string( Reg.highScore );
		
		// The left bounce panel. Drawn via code in Reg to fit screen height.
		
		_bounceLeft = new FlxSprite( 1, 17 );
		_bounceLeft.loadGraphic( Reg.getBounceImage( FlxG.height - 34 ), true, 4, FlxG.height - 34 );
		_bounceLeft.animation.add( "flash", [1,0], 8, false);
		add( _bounceLeft );
		
		// The right bounce panel.
		
		_bounceRight = new FlxSprite( FlxG.width - 5, 17 );
		_bounceRight.loadGraphic( Reg.getBounceImage( FlxG.height - 34 ), true, 4, FlxG.height - 34 );
		_bounceRight.animation.add( "flash", [1,0], 8, false );
		add( _bounceRight );
		
		// The left spiky paddle
		
		_paddleLeft = new Paddle( 6, FlxObject.RIGHT );
		add( _paddleLeft );
		
		// The right spiky paddle
		
		_paddleRight = new Paddle( FlxG.width-15, FlxObject.LEFT );
		add( _paddleRight );
		
		// Spikes at the bottom of the screen
		
		_spikeBottom = new Spike(false);
		add( _spikeBottom );
		
		// Spikes at the top of the screen.
		
		_spikeTop = new Spike(true);
		add(_spikeTop);
		
		// The bird.
		
		_player = new Player();
		add( _player );
		
		// A simple emitter to make some feathers when the bird gets spiked.
		
		_feathers = new FlxEmitter();
		_feathers.makeParticles( "assets/feather.png", 50, 32 );
		_feathers.setXSpeed( -10, 10 );
		_feathers.setYSpeed( -10, 10 );
		_feathers.gravity = 10;
		add( _feathers );
	}
	
	override public function update():Void
	{
		if ( FlxG.pixelPerfectOverlap( _player, _spikeBottom ) || FlxG.pixelPerfectOverlap( _player, _spikeTop ) 
				|| FlxG.pixelPerfectOverlap( _player, _paddleLeft ) || FlxG.pixelPerfectOverlap( _player, _paddleRight ) ) {
			_player.kill();
		} else if ( _player.x < 5 ) {
			_player.x = 5;
			_player.velocity.x = -_player.velocity.x;
			_player.facing = FlxObject.RIGHT;
			Reg.score++;
			_scoreDisplay.text = Std.string( Reg.score );
			_bounceLeft.animation.play( "flash" );
			_paddleRight.randomize();
		} else if ( _player.x + _player.width > FlxG.width - 5 ) {
			_player.x = FlxG.width - _player.width - 5;
			_player.velocity.x = -_player.velocity.x;
			_player.facing = FlxObject.LEFT;
			Reg.score++;
			_scoreDisplay.text = Std.string( Reg.score );
			_bounceRight.animation.play( "flash" );
			_paddleLeft.randomize();
		}
		
		#if !FLX_NO_KEYBOARD
		if( FlxG.keys.justPressed.E && ( FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.ALT ) )
		{
			clearSave();
			FlxG.resetState();
		}
		#end
		
		// This is supposed to enable window movement for desktop releases, but it doesn't work ATM.
		
		#if !FLX_NO_MOUSE
		if (FlxG.mouse.justPressed)
		{
			_dragging = true;
		}
		
		if (FlxG.mouse.justReleased)
		{
			_dragging = false;
		}
		
		//if (_dragging && Lib.current.stage.parent != null)
		//{
		//	Lib.current.stage.parent.x = FlxG.mouse.x - 10;
		//	Lib.current.stage.parent.y = FlxG.mouse.y - 10;
		//}
		//if (_dragging)
		//{
		//	Lib.current.parent.x -= 1;
		//}
		#end
		
		super.update();
	}
	
	/**
	 * Launch a bunch of feathers at X and Y.
	 */
	public function launchFeathers( X:Float, Y:Float, Amount:Int ):Void
	{
		_feathers.x = X;
		_feathers.y = Y;
		_feathers.start( true, 2, 0, Amount, 1 );
	}
	
	/**
	 * Returns a random valid position for the paddle to slide to.
	 */
	public function randomPaddleY():Int
	{
		return FlxRandom.intRanged( Std.int( _bounceLeft.y ), Std.int( _bounceLeft.y + _bounceLeft.height - _paddleLeft.height ) );
	}
	
	/**
	 * Resets the state to its initial position without having to call FlxG.resetState().
	 */
	public function reset()
	{
		_paddleLeft.y = FlxG.height;
		_paddleRight.y = FlxG.height;
		Reg.score = 0;
		_scoreDisplay.text = "";
		Reg.highScore = loadScore();
		
		if ( Reg.highScore > 0 )
			_highScore.text = Std.string( Reg.highScore );
	}
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	static public function saveScore():Void
	{
		Reg.save = new FlxSave();
		
		if( Reg.save.bind( SAVE_DATA ) )
		{
			if( ( Reg.save.data.score == null ) || ( Reg.save.data.score < Reg.score ) )
				Reg.save.data.score = Reg.score;
		}
		
		// Have to do this in order for saves to work on native targets!
		
		Reg.save.flush();
	}
	
	/**
	 * Load data from the saved session.
	 * 
	 * @return	The total points of the saved high score.
	 */
	static public function loadScore():Int
	{
		Reg.save = new FlxSave();
		
		if( Reg.save.bind( SAVE_DATA ) )
		{
			if( ( Reg.save.data != null ) && ( Reg.save.data.score != null ) )
				return Reg.save.data.score;
		}
		
		return 0;
	}
	
	/**
	 * Wipe save data.
	 */
	static public function clearSave():Void
	{
		Reg.save = new FlxSave();
		
		if( Reg.save.bind( SAVE_DATA ) )
			Reg.save.erase();
	}
}