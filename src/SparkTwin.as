package
{
	import org.flixel.FlxGame;
	[SWF(width="600", height="600", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]
	
	public class SparkTwin extends FlxGame
	{
		public function SparkTwin()
		{
			super(600, 600, PlayState, 1, 60, 30);
			forceDebugger = true;
		}
	}
}
