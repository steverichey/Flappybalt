package;

import flixel.util.FlxSave;

class Save
{
	/**
	 * Saves a given score to the local file system.
	 */
	static public function saveScore(Score:Int):Void
	{
		save = new FlxSave();
		
		if(save.bind( SAVE_DATA ))
		{
			if (save.data.score == null || save.data.score < Score)
			{
				save.data.score = Score;
			}
		}
		
		save.flush(); // Saves to file system
	}
	
	/**
	 * Returns the saved score from the local save system.
	 */
	static public function loadScore():Int
	{
		save = new FlxSave();
		
		if(save.bind(SAVE_DATA))
		{
			if (save.data != null && save.data.score != null)
			{
				return save.data.score;
			}
		}
		
		return 0;
	}
	
	static private var save:FlxSave;
	inline static private var SAVE_DATA:String = "FLAPPYBALT";
}