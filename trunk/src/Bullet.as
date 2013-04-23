package
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.si.cml.extensions.BulletRunner;
	
	public class Bullet extends FlxSprite
	{
		public static var bullets:FlxGroup = new FlxGroup();
		
		public function Bullet(radius:int)
		{
			this.makeGraphic(radius, radius, 0xffff6633);
		}
		
		public function onCreate(br:BulletRunner):void
		{    
			bullets.add(this);
		}
		
		public function onUpdate(br:BulletRunner):void
		{
		}
		
		public function onDestroy(br:BulletRunner):void
		{    
			bullets.remove(this);
		}
		
		public function onNew(args:Array):BulletRunner
		{
			return null;
		}
		
		public function onFire(args:Array):BulletRunner
		{
			return null;
		}
		
		/**
		 * implements rotation for BulletRunner
		 */
		private var _rotation:Number;
		public function set rotation(value:Number):void {
			_rotation = value;
		}
		public function get rotation():Number {
			return _rotation;
		}
	}
}