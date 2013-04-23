package
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.si.cml.CMLSequence;
	import org.si.cml.extensions.BulletRunner;
	
	public class Enemy extends FlxSprite
	{
		public static var enemies:FlxGroup = new FlxGroup();
		public static var sequences:Array = [
			new CMLSequence("v0,10i20v~bm5,120   [f4+$r*4{6}w20]3ay0.3"),         // 5 way barrage, repeat 3 times
			new CMLSequence("v0,10i20v~bm5,0,2   [f7-$r*3{5}w20]3ay0.3"),         // 5 straight bullets, repeat 3 times
			new CMLSequence("v0,10i20v~bm5,0,0,2 [f8+$r*6{3}w20]3 ay0.3"),        // 5 rapid-fire cannon, repeat 3 times
			new CMLSequence("v0,10i20v~bm8,15,4,2htx[f7+$r*3{4}w30]2ay0.3"),      // 5 "whip" type barrage, repeat 2 times
			new CMLSequence("v0,10i20v~br5,30,2,4[f8+$r*6{4}w30]2ay0.3"),         // 5 random bullets, repeat 2 times
			new CMLSequence("v0,10i20v~bm12,360  [f8{6i10v~vd6+$r*8}w30]2ay0.3"), // 12 round barrage, repeat 2 times
			new CMLSequence("v0,10i20v~bm24,360,0,1bm2,180 f4+$r*8{3}w60 ay0.3")  // doubled all range barrage
		];
		
		private var _bulletRunner:BulletRunner;
		private var _life:Number;
		
		public function Enemy()
		{
			this.makeGraphic(16, 16, 0xffff0000);
		}
		
		public static function create():BulletRunner
		{
			var enemy:Enemy    = new Enemy();
			var br:BulletRunner = BulletRunner.apply(enemy);
			br.callbacks = enemy;
			return br;
		}
		
		public function damage(d:Number) : void
		{
			_life -= d;
			if (_life <= 0) {
				_bulletRunner.destroy(1);
			}
		}
		
		public function onCreate(br:BulletRunner):void
		{    
			_bulletRunner = br;
			_life = 1;
			
			var i:int = int(Math.random() * sequences.length);
			br.runSequence( sequences[i] );
			enemies.add(this);
		}
		
		public function onUpdate(br:BulletRunner):void
		{
		}
		
		public function onDestroy(br:BulletRunner):void
		{
			enemies.remove(this);
		}
		
		public function onNew(args:Array):BulletRunner
		{
			return null;
		}
		
		public function onFire(args:Array):BulletRunner
		{
			var b:Bullet = new Bullet(4);
			var br:BulletRunner = BulletRunner.apply(b);
			br.callbacks = b;
			return br;
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