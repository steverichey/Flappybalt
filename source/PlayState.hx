package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	inline static private var SAVE_DATA:String = "FLAPPYBALT";
	
	public var player:Player;
	
	public var bounceLeft:FlxSprite;
	public var bounceRight:FlxSprite;
	
	public var paddleLeft:Paddle;
	public var paddleRight:Paddle;
	
	public var spikeBottom:FlxSprite;
	public var spikeTop:FlxSprite;
	
	public var scoreDisplay:FlxText;
	
	public var spikes:FlxGroup;
	public var feathers:FlxEmitter;
	public var highScore:FlxText;
	
	override public function create():Void
	{
		super.create();
		
		Reg.score = 0;
		Reg.PS = this;
		
		FlxG.camera.bgColor = 0xff646A7D;
		
		#if !FLX_NO_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		add( new FlxSprite( 0, 0, "assets/bg.png" ) );
		
		// Current score
		scoreDisplay = new FlxText( 0, 160, FlxG.width );
		scoreDisplay.alignment = "center";
		scoreDisplay.color = 0xff4d4d59;
		scoreDisplay.size = 24;
		add( scoreDisplay );
		
		// All-time high score
		Reg.highScore = loadScore();
		
		highScore = new FlxText( 0, 40, FlxG.width, "" );
		highScore.alignment = "center";
		add( highScore );
		
		if ( Reg.highScore > 0 )
			highScore.text = Std.string( Reg.highScore );
		
		bounceLeft = new FlxSprite( 1, 17 );
		bounceLeft.loadGraphic( Reg.getBounceImage( FlxG.height - 34 ), true, false, 4, 206 );
		bounceLeft.animation.add( "flash", [1,0], 8, false);
		add( bounceLeft );
		
		bounceRight = new FlxSprite( FlxG.width - 5, 17 );
		bounceRight.loadGraphic( Reg.getBounceImage( FlxG.height - 34 ), true, false, 4, 206 );
		bounceRight.animation.add( "flash", [1,0], 8, false );
		add( bounceRight );
		
		paddleLeft = new Paddle( 6, FlxObject.RIGHT );
		add( paddleLeft );
		
		paddleRight = new Paddle( FlxG.width-15, FlxObject.LEFT );
		add( paddleRight );
		
		spikeBottom = new FlxSprite( 0, 0, "assets/spike.png" );
		spikeBottom.y = FlxG.height - spikeBottom.height;
		add( spikeBottom );
		
		spikeTop = new FlxSprite( 0, 0 );
		spikeTop.loadRotatedGraphic( "assets/spike.png", 4 );
		spikeTop.angle = 180;
		spikeTop.y = -72;
		add( spikeTop );
		
		player = new Player();
		add( player );
		
		spikes = new FlxGroup();
		spikes.add( paddleLeft );
		spikes.add( paddleRight );
		spikes.add( spikeTop );
		spikes.add( spikeBottom );
		
		feathers = new FlxEmitter();
		feathers.makeParticles( "assets/feather.png", 50, 32 );
		feathers.setXSpeed( -10, 10 );
		feathers.setYSpeed( -10, 10 );
		feathers.gravity = 10;
		add( feathers );
	}
	
	override public function update():Void
	{
		super.update();
		
		if ( FlxG.pixelPerfectOverlap( player, spikeBottom ) || FlxG.pixelPerfectOverlap( player, spikeTop ) 
				|| FlxG.pixelPerfectOverlap( player, paddleLeft ) || FlxG.pixelPerfectOverlap( player, paddleRight ) ) {
			player.kill();
		} else if ( player.x < 5 ) {
			player.x = 5;
			player.velocity.x = -player.velocity.x;
			player.facing = FlxObject.RIGHT;
			Reg.score++;
			scoreDisplay.text = Std.string( Reg.score );
			bounceLeft.animation.play( "flash" );
			paddleRight.randomize();
		} else if ( player.x + player.width > FlxG.width - 5 ) {
			player.x = FlxG.width - player.width - 5;
			player.velocity.x = -player.velocity.x;
			player.facing = FlxObject.LEFT;
			Reg.score++;
			scoreDisplay.text = Std.string( Reg.score );
			bounceRight.animation.play( "flash" );
			paddleLeft.randomize();
		}
		
		#if !FLX_NO_KEYBOARD
		if( FlxG.keys.justPressed.E && ( FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.ALT ) )
		{
			clearSave();
			FlxG.resetState();
		}
		#end
	}
	
	public function reset()
	{
		paddleLeft.y = FlxG.height;
		paddleRight.y = FlxG.height;
		Reg.score = 0;
		scoreDisplay.text = "";
		Reg.highScore = loadScore();
		
		if ( Reg.highScore > 0 )
			highScore.text = Std.string( Reg.highScore );
	}
	
	/**
	 * Safely store a new high score into the saved session, if possible.
	 */
	static public function saveScore():Void
	{
		var save:FlxSave = new FlxSave();
		
		if(save.bind(SAVE_DATA))
		{
			if((save.data.score == null) || (save.data.score < Reg.score))
				save.data.score = Reg.score;
		}
	}
	
	/**
	 * Load data from the saved session (mostly used elsewhere).
	 * 
	 * @return	The total points.
	 */
	static public function loadScore():Int
	{
		var save:FlxSave = new FlxSave();
		
		if( save.bind( SAVE_DATA ) )
		{
			if( ( save.data != null ) && ( save.data.score != null ) )
				return save.data.score;
		}
		
		return 0;
	}
	
	/**
	 * Wipe save data.
	 */
	static public function clearSave():Void
	{
		var save:FlxSave = new FlxSave();
		
		if( save.bind( SAVE_DATA ) )
			save.erase();
	}
}