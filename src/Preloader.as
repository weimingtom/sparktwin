package
{
	import org.flixel.system.FlxPreloader;
	
	public class Preloader extends FlxPreloader
	{
		public var ds:SparkTwin;
		public function Preloader()
		{
			className = "SparkTwin";
			super();
		}
	}
}
