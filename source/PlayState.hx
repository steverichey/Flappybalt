package;

import flash.Lib;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.math.FlxRandom;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKeyName;

class PlayState extends FlxState
{
	private var _birds:FlxTypedGroup<Player>;
	private var _bumpers:FlxTypedGroup<Bumper>;
	private var _spikes:FlxTypedGroup<FloatingSpike>;
	
	private var _paddleLeft:Paddle;
	private var _paddleRight:Paddle;
	private var _spikeBottom:Spike;
	private var _spikeTop:Spike;
	private var _scoreDisplay:FlxText;
	private var _highScore:FlxText;
	private var _dust:FlxEmitter;
	
	private var bestCurrentScore:Int = 0;
	private var bestHighScore:Int = 0;
	
	public var registeredButtons:Array<FlxKeyName>;
	
	inline static private var BUMPER_CHANCE:Float = 15;
	inline static private var SPIKE_CHANCE:Float = 100;
	
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
		
		bestHighScore = Save.loadScore();
		
		if ( bestHighScore > 0 )
		{
			_highScore.text = Std.string( bestHighScore );
		}
		
		_bumpers = new FlxTypedGroup<Bumper>();
		
		// The left and right main bumpers.
		
		_bumpers.add(new Bumper(1, 17, 4, FlxG.height - 34));
		_bumpers.add(new Bumper(FlxG.width - 5, 17, 4, FlxG.height - 34));
		
		add(_bumpers);
		
		// Floating spike objects
		
		_spikes = new FlxTypedGroup<FloatingSpike>();
		add(_spikes);
		
		// The left spiky paddle
		
		_paddleLeft = new Paddle(6);
		add( _paddleLeft );
		
		// The right spiky paddle
		
		_paddleRight = new Paddle(FlxG.width-15);
		add( _paddleRight );
		
		// Spikes at the bottom of the screen
		
		_spikeBottom = new Spike(false);
		add( _spikeBottom );
		
		// Spikes at the top of the screen.
		
		_spikeTop = new Spike(true);
		add(_spikeTop);
		
		// Stored buttons
		
		registeredButtons = [];
		
		// The birds.
		
		_birds = new FlxTypedGroup<Player>();
		_birds.add(new Player("SPACE", true));
		add(_birds);
		
		// Some dust
		
		_dust = new FlxEmitter();
		
		for (i in 0...50)
		{
			var mote:FlxParticle = new FlxParticle();
			var size:Int = FlxRandom.int(1, 3);
			mote.makeGraphic(size, size, FlxColor.WHITE);
			mote.alpha = FlxRandom.float(0.1, 0.9);
			_dust.add(mote);
		}
		
		_dust.yVelocity.set( -5, 20);
		_dust.gravity = 15;
		_dust.life.set(0.5, 1);
		_dust.endAlpha.set(0, 0);
		add(_dust);
	}
	
	override public function update():Void
	{
		for (bird in _birds)
		{
			if ( FlxG.pixelPerfectOverlap( bird, _spikeBottom ) 
					|| FlxG.pixelPerfectOverlap( bird, _spikeTop ) 
					|| FlxG.pixelPerfectOverlap( bird, _paddleLeft )
					|| FlxG.pixelPerfectOverlap( bird, _paddleRight )
					|| FlxG.overlap(bird, _spikes) )
			{
				bird.kill();
			}
			
			if (bird.lonely && _birds.length > 1)
			{
				_birds.remove(bird, true);
				bird.destroy();
				bird = null;
			}
		}
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.justPressed.ANY && !FlxG.keys.anyJustPressed(registeredButtons))
		{
			_birds.add(new Player(FlxG.keys.firstPressed(), false));
		}
		#end
		
		FlxG.collide(_birds, _bumpers, birdBounce);
		FlxG.collide(_birds, _birds, birdOnBirdViolence);
		
		super.update();
	}
	
	private function birdBounce(Bird:Player, Bump:Bumper):Void
	{
		Bird.bounce();
		Bump.bounce();
		
		if (Bird.score > bestCurrentScore)
		{
			bestCurrentScore = Bird.score;
			
			#if !mobile
			_scoreDisplay.color = Bird.color;
			
			if (bestCurrentScore > bestHighScore)
			{
				bestHighScore = bestCurrentScore;
				_highScore.text = Std.string(bestHighScore);
				_highScore.color = _scoreDisplay.color;
			}
			#end
		}
		
		_scoreDisplay.text = Std.string( bestCurrentScore );
		
		if (Bump.stationary)
		{
			if (Bird.x < FlxG.width / 2)
			{
				_paddleRight.randomize();
			}
			else
			{
				_paddleLeft.randomize();
			}
		}
		
		#if !mobile
		if (FlxRandom.chanceRoll(BUMPER_CHANCE))
		{
			_bumpers.add(new Bumper(FlxRandom.int(20, FlxG.width - 20), FlxRandom.chanceRoll() ? 0 : FlxG.height, FlxRandom.int(4, 16), FlxRandom.int(4, 16), false));
		}
		
		if (FlxRandom.chanceRoll(SPIKE_CHANCE))
		{
			_spikes.add(new FloatingSpike());
		}
		
		// Facing direction is flipped at this point. I think.
		
		if (Bird.facing == FlxObject.RIGHT)
		{
			makeDust(Bird.x + Bird.width, Bird.y + Bird.height / 2);
		}
		else
		{
			makeDust(Bird.x, Bird.y + Bird.height / 2);
		}
		#end
	}
	
	private function birdOnBirdViolence(Bird:Player, AnotherBird:Player):Void
	{
		FlxG.sound.play("hurt");
		Bird.bounce(true);
		AnotherBird.bounce(true);
	}
	
	private function makeDust(X:Float, Y:Float, Direction:DustDirection = DustDirection.BOTH):Void
	{
		_dust.x = X;
		_dust.y = Y;
		
		if (Direction == DustDirection.LEFT)
		{
			_dust.xVelocity.set( -20, 0);
		}
		else if (Direction == DustDirection.RIGHT)
		{
			_dust.xVelocity.set( 0, 20);
		}
		else
		{
			_dust.xVelocity.set( -20, 20);
		}
		
		_dust.start(true, 0.5, 0, 5, 1);
	}
	
	public function reset()
	{
		_paddleLeft.remove();
		_paddleRight.remove();
	}
}

@:enum
abstract DustDirection(Int)
{
	var LEFT = 0;
	var RIGHT = 1;
	var BOTH = 2;
}