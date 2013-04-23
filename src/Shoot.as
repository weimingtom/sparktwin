package
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class Shoot extends FlxSprite
	{
		public var distance:Number;	
		
		public function Shoot()
		{
			this.makeGraphic(2, 2, 0xffffffff);
		}
		
		override public function update():void
		{
			/*
			if (direction.x > 0) {
			x -= 10;			
			}
			if (direction.x < 0) {
			x += 10;			
			}
			if (direction.y > 0) {
			y -= 10;			
			}
			if (direction.y < 0) {
			y += 10;			
			}
			*/
			//if (distance < 150) {
			//	y -= 10;
			//}
			//angle = 90;
			
			//var aimAngle:Number = 90;
			var rFireAngle:Number = (angle * (Math.PI / 180));
			//if (playerDistance < 300) {
			this.x += Math.cos(rFireAngle) * 10;
			this.y += Math.sin(rFireAngle) * 10;				
			//} 
			
			//if (distance && (distance - this.y) > 100){
			//	this.kill();
			//}
			
			if (y < 0 || y > FlxG.height) this.kill();
			if (x < 0 || x > FlxG.width) this.kill();
			super.update();
		}
	}
}