package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.util.FlxSpriteUtil;
import flixel.math.FlxPoint;

class City extends FlxSprite
{
	public function new()
	{
		super();
		
		makeGraphic(FlxG.width, FlxG.height, Reg.GREY_LIGHT);
		
		FlxSpriteUtil.drawPolygon(this, generateVertices(40, 120), Reg.GREY_BG_MED, {thickness: 1, color: Reg.GREY_BG_MED});
		FlxSpriteUtil.drawPolygon(this, generateVertices(80, 160), Reg.GREY_MED, { thickness: 1, color: Reg.GREY_MED } );
		
		//var bg:FlxSprite = new FlxSprite(0, 0, "assets/bg.png");
		//stamp(bg);
		/*
		// To make the game screen-width agnostic, add some faux backgrounds below the city graphic
		
		var bgWidth:Int = Std.int((FlxG.width - bg.width) / 2);
		var bgHeight:Int = Std.int(bg.y);
		
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
		
		if (bgHeight > 0)
		{
			var topLite:FlxSprite = new FlxSprite();
			topLite.makeGraphic(FlxG.width, bgHeight, Reg.GREY_LIGHT);
			add(topLite);
		}
		
		add(bg);*/
	}
	
	private function generateVertices(MinY:Int, MaxY:Int):Array<FlxPoint>
	{
		var vertices:Array<FlxPoint> = [];
		var xPos:Int = 0;
		var yPos:Int = Std.int((MaxY - MinY) / 2 + MinY);
		var current:Int = 0;
		var last:Int = 0;
		var move:Int = 0;
		
		while (xPos < FlxG.width)
		{
			vertices.push(new FlxPoint(xPos, yPos));
			
			current = FlxRandom.int(0, 4, [last]);
			
			switch (current)
			{
				case 0:
					xPos += FlxRandom.int(10, 30);
				case 1:
					if (last != 2) // prevent going straight down then up
					{
						yPos -= FlxRandom.int(5, 20);
						yPos = Std.int(FlxMath.bound(yPos, MinY, MaxY));
					}
				case 2:
					if (last != 1) // prevent going straight up then down
					{
						yPos += FlxRandom.int(10, 40);
					}
				case 3:
					yPos -= FlxRandom.int(10, 20);
					vertices.push(new FlxPoint(xPos, yPos));
					xPos -= FlxRandom.int(2, 5);
					vertices.push(new FlxPoint(xPos, yPos));
					yPos -= FlxRandom.int(3, 6);
					vertices.push(new FlxPoint(xPos, yPos));
					xPos += FlxRandom.int(9, 30);
				case 4:
					move = FlxRandom.int(10, 20);
					xPos += move;
					yPos += move;
			}
			
			last = current;
		}
		
		vertices.push(new FlxPoint(FlxG.width, yPos));
		vertices.push(new FlxPoint(FlxG.width, FlxG.height));
		vertices.push(new FlxPoint(0, FlxG.height));
		vertices.push(new FlxPoint(0, 80));
		
		return vertices;
	}
}