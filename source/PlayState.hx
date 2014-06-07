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
import flixel.math.FlxRandom;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKeyName;

class PlayState extends FlxState
{
	private var _birds:FlxTypedGroup<Player>;
	private var _bumpers:FlxTypedGroup<Bumper>;
	
	private var _paddleLeft:Paddle;
	private var _paddleRight:Paddle;
	private var _spikeBottom:Spike;
	private var _spikeTop:Spike;
	private var _scoreDisplay:FlxText;
	private var _feathers:FlxEmitter;
	private var _highScore:FlxText;
	
	private var bestCurrentScore:Int = 0;
	private var bestHighScore:Int = 0;
	
	private var _registeredButtons:Array<FlxKeyName>;
	
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
		
		var city:City = new City();
		add(city);
		
		// Current score.
		
		_scoreDisplay = new FlxText( 0, FlxG.height - 64, FlxG.width );
		_scoreDisplay.alignment = "center";
		_scoreDisplay.color = Reg.GREY_BG_MED;
		_scoreDisplay.size = 24;
		add( _scoreDisplay );
		
		// Display high score.
		
		_highScore = new FlxText( 0, 40, FlxG.width, "" );
		_highScore.alignment = "center";
		_highScore.color = 0xff868696;
		add( _highScore );
		
		Reg.highScore = loadScore();
		
		if ( Reg.highScore > 0 )
		{
			_highScore.text = Std.string( Reg.highScore );
		}
		
		_bumpers = new FlxTypedGroup<Bumper>();
		
		// The left and right main bumpers.
		
		_bumpers.add(new Bumper(1, 17, 4, FlxG.height - 34));
		_bumpers.add(new Bumper(FlxG.width - 5, 17, 4, FlxG.height - 34));
		
		add(_bumpers);
		
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
		
		// Stored buttons
		
		_registeredButtons = [];
		_registeredButtons.push("SPACE");
		
		// The birds.
		
		_birds = new FlxTypedGroup<Player>();
		_birds.add(new Player("SPACE", true));
		add(_birds);
		
		// A simple emitter to make some feathers when the bird gets spiked.
		
		_feathers = new FlxEmitter();
		_feathers.makeParticles( "assets/feather.png", 50, 32 );
		_feathers.setXSpeed( -10, 10 );
		_feathers.setYSpeed( -10, 10 );
		_feathers.gravity = 10;
		add( _feathers );
		
		FlxG.log.add("eypyp" + FlxRandom.int());
	}
	
	override public function update():Void
	{
		for (bird in _birds)
		{
			if ( FlxG.pixelPerfectOverlap( bird, _spikeBottom ) 
					|| FlxG.pixelPerfectOverlap( bird, _spikeTop ) 
					|| FlxG.pixelPerfectOverlap( bird, _paddleLeft )
					|| FlxG.pixelPerfectOverlap( bird, _paddleRight ) )
			{
				bird.kill();
			}
		}
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justPressed.ANY && !FlxG.keys.anyJustPressed(_registeredButtons))
		{
			_registeredButtons.push(FlxG.keys.firstPressed());
			_birds.add(new Player(FlxG.keys.firstPressed(), false));
		}
		#end
		
		FlxG.collide(_birds, _bumpers, birdBounce);
		FlxG.collide(_birds, _birds);
		
		super.update();
	}
	
	private function birdBounce(Bird:Player, Bump:Bumper):Void
	{
		Bird.bounce();
		Bump.animation.play( "flash" );
		
		if (Bird.score > bestCurrentScore)
		{
			bestCurrentScore = Bird.score;
			
			#if !mobile
			_scoreDisplay.color = Bird.color;
			#end
		}
		
		_scoreDisplay.text = Std.string( bestCurrentScore );
		
		if (Bird.x > FlxG.width / 2)
		{
			_paddleRight.randomize();
		}
		else
		{
			_paddleLeft.randomize();
		}
	}
	
	/**
	 * Launch a bunch of feathers at X and Y.
	 */
	public function launchFeathers( X:Float, Y:Float, Amount:Int, Color:Int ):Void
	{
		_feathers.x = X;
		_feathers.y = Y;
		
		for (feather in _feathers)
		{
			feather.color = Color;
		}
		
		_feathers.start( true, 2, 0, Amount, 1 );
	}
	
	/**
	 * Returns a random valid position for the paddle to slide to.
	 */
	public function randomPaddleY():Int
	{
		return FlxRandom.int(17, Std.int(FlxG.height - 34 - _paddleLeft.height));
	}
	
	/**
	 * Resets the state to its initial position without having to call FlxG.resetState().
	 */
	public function reset()
	{
		_paddleLeft.y = FlxG.height;
		_paddleRight.y = FlxG.height;
		Reg.highScore = loadScore();
		
		if ( Reg.highScore > 0 )
		{
			_highScore.text = Std.string( Reg.highScore );
		}
	}
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	static public function saveScore():Void
	{
		Reg.save = new FlxSave();
		
		if( Reg.save.bind( SAVE_DATA ) )
		{
			if ( ( Reg.save.data.score == null ) || ( Reg.save.data.score < Reg.highScore ) )
			{
				Reg.save.data.score = Reg.highScore;
			}
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
}