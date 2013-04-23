package
{
	import com.rhuno.X360Gamepad;
	
	import flash.display.Graphics;
	
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;

	public class ResourceManager
	{
		public static var gamepad:X360Gamepad;
		
		public function ResourceManager()
		{
		}
		
		/**
		 * Draw a circle to a sprite.
		 *
		 * @param   Sprite          The FlxSprite to draw to
		 * @param   Center          x,y coordinates of the circle's center
		 * @param   Radius          Radius in pixels
		 * @param   LineColor       Outline color
		 * @param   LineThickness   Outline thickness
		 * @param   FillColor       Fill color
		 */
		public static function drawCircle(Sprite:FlxSprite, Center:FlxPoint, Radius:Number = 30, LineColor:uint = 0xffffffff, LineThickness:uint = 1, FillColor:uint = 0xffffffff):void {
			
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			
			// Line alpha
			var alphaComponent:Number = Number((LineColor >> 24) & 0xFF) / 255;
			if(alphaComponent <= 0)
				alphaComponent = 1;
			
			gfx.lineStyle(LineThickness, LineColor, alphaComponent);
			
			// Fill alpha
			alphaComponent = Number((FillColor >> 24) & 0xFF) / 255;
			if(alphaComponent <= 0)
				alphaComponent = 1;
			
			gfx.beginFill(FillColor & 0x00ffffff, alphaComponent);
			
			gfx.drawCircle(Center.x, Center.y, Radius);
			
			gfx.endFill();
			
			Sprite.pixels.draw(FlxG.flashGfxSprite);
			Sprite.dirty = true;
		}
	}
}