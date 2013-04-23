package
{
	import flash.geom.Point;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.system.input.Keyboard;

	public class Player extends FlxSprite
	{
		public static var shots:FlxGroup = new FlxGroup();
		
		public var index:uint = 1;
		
		
		//public var anotherPlayer:Player;
		
		public var aimAngle:Number = 0;
		private var radAngle:Number = 0;
		
		public var targetPoint:FlxPoint;
		public var playerPoint:FlxPoint;
		
		public var playerDistance:Number;
		
		private var shotToggle:Boolean = false;
		
		public function Player(x:int, y:int)
		{
			super(x, y);
			//if (index == 1) {
			this.makeGraphic(12, 12, 0xffffffff);
			//} else {
			//	this.makeGraphic(8, 8, 0xdfdfdfff);
			//}
			angle = 270;
		}
		public function setAimAngle(point2:FlxPoint, point1:FlxPoint):Number
		{
			//return FlxU.getAngle(point2, point1);
			
			//aimAngle = FlxU.getAngle((point2.x - (point1.x + (width/2))), (point2.y - (point1.y + (height/2))));
			return Math.atan2(point1.y - point2.y, point1.x - point2.x);
			//return aimAngle;
		}
		public function getAnglePrecise(X:Number, Y:Number):Number
		{
			return Math.atan2(Y,X) * 180 / Math.PI;
		}
		
		public function setClockwiseness(s:String):void {
			if (s == 'counterclockwise') {
				angle -= 10;
			}
			if (s == 'clockwise') {
				angle += 10;
			}
		}
		override public function update():void
		{
			
			doInput();
			
			var vx:int = 0;
			var vy:int = 0;
			
			var keys:Keyboard = FlxG.keys;
			
			var left:int;
			var right:int;
			var down:int;
			var up:int;
			
			var rotateright:int;
			var rotateleft:int;
			/*
			if (index == 1) {
			left = keys.LEFT ? 1 : 0;
			right = keys.RIGHT ? 1 : 0;
			down = keys.DOWN ? 1 : 0;
			up = keys.UP ? 1 : 0;
			} else {
			left = keys.A ? 1 : 0;
			right = keys.D ? 1 : 0
			down = keys.S ? 1 : 0;
			up = keys.W ? 1 : 0;
			}
			*/
			left = keys.A ? 1 : 0;
			right = keys.D ? 1 : 0
			down = keys.S ? 1 : 0;
			up = keys.W ? 1 : 0;
			
			rotateleft = keys.LEFT ? 1 : 0;
			rotateright = keys.RIGHT ? 1 : 0;
			
			if ( (ResourceManager.gamepad.isDPadLeftPressed() || ResourceManager.gamepad.leftStickX < -15000))
			{
				left = 1;
			}
			
			if ( (ResourceManager.gamepad.isDPadRightPressed() || ResourceManager.gamepad.leftStickX > 15000))
			{
				right = 1;
			}
			
			if ( (ResourceManager.gamepad.isDPadUpPressed() || ResourceManager.gamepad.leftStickY > 15000))
			{
				up = 1;
			}
			
			if ( (ResourceManager.gamepad.isDPadDownPressed() || ResourceManager.gamepad.leftStickY < -15000))
			{
				down = 1;
			}
			
			//right pad
			
			var rightStickPoint:Point = new Point(ResourceManager.gamepad.rightStickY, ResourceManager.gamepad.rightStickX);
			
			
			rightStickPoint.normalize(1);
			
			var rightStickAngle:Number = getAnglePrecise(rightStickPoint.x,rightStickPoint.y);
			
			//trace(rightStickPoint,rightStickAngle);
			
			angle = rightStickAngle + 252.16;
			//angle = 270;
			//trace(angle);
			
			if (rotateleft) {
				angle -= 10;
			}
			if (rotateright) {
				angle += 10;
			}
			
			vx = 4 * right - 4 * left;
			vy = 4 * down - 4 * up;
			x += vx;
			y += vy;
			x = (x < 0)? 0 : ((x > FlxG.width-width)? FlxG.width-width : x);
			y = (y < 0)? 0 : ((y > FlxG.height-height)? FlxG.height-height : y);
			
			super.update();
			
			var dist:Point;
			
			//targetPoint = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
			playerPoint = new FlxPoint(x + width / 2, y + height / 2);
			/*if (targetPoint) {
			playerDistance = FlxU.getDistance(playerPoint, targetPoint);
			//aimAngle = setAimAngle(targetPoint, playerPoint);
			aimAngle =getAnglePrecise(targetPoint.x - (x + (width/2)), targetPoint.y - (y + (height/2)));
			//this.angle = aimAngle - 180;
			}*/
			
			if (keys.justPressed("SPACE")){
				shotToggle = !shotToggle;
			}
			
			
			if((keys.X || keys.SPACE || shotToggle || ResourceManager.gamepad.isAPressed() || ResourceManager.gamepad.rightTriggerAsPercent > 0.5)) {
				
				var shot:Shoot = new Shoot();
				shot.x = this.x + this.width/2 - shot.width/2;
				shot.y = this.y;
				//shot.reset(this.x,this.y);
				//shot.angle = aimAngle;
				//var rFireAngle:Number = (playerDistance * (Math.PI / 180));
				aimAngle = angle;
				var rFireAngle:Number = (aimAngle * (Math.PI / 180));
				//if (playerDistance < 300) {
				//shot.velocity.x = Math.cos(rFireAngle) * 10;
				//shot.velocity.y = Math.sin(rFireAngle) * 10;				
				//} 
				
				
				//shot.velocity.y = 0;
				//var angle:Number = FlxU.getAngle(new FlxPoint(x,y), new Point(anotherPlayer.x,anotherPlayer.y));			
				//dist = Point.interpolate(new Point(x,y),new Point(anotherPlayer.x,anotherPlayer.y),0.5);
				//trace(dist);
				//var dd:Number = Point.distance(new Point(x,y),new Point(anotherPlayer.x,anotherPlayer.y));
				
				//dist.normalize(1);
				//shot.direction = dist;
				//trace('player: '+index + ' -> '+aimAngle + ' distance '+playerDistance);
				//shot.x = this.x + this.width/2 - shot.width/2;
				//shot.y = this.y;
				shot.distance = y;
				shot.angle = angle;
				//shot.
				//setTimeout(shot.kill,800);
				shots.add(shot);
				
				
			}
		}
		
		/**
		 * doInput
		 * Handle input from the xbox 360 controller
		 */
		private function doInput():void
		{
			// A button jumps
			if (ResourceManager.gamepad.isAPressed())
			{
				//doJump();
				trace('aaaaaaaaa');
			}
			
			/**
			 * Another way to test button presses
			 * _gamepad.isButtonDown(X360Gamepad.GAMEPAD_A);
			 * 
			 * You can also now check for button releases 
			 * for face buttons, dpad, start, back and shoulders. 
			 * Not available for sticks and triggers.
			 * _gamepad.wasAReleased();
			 * _gamepad.wasButtonReleased(X360Gamepad.GAMEPAD_A);
			 */
			/*
			if (_gamepad.wasButtonReleased(X360Gamepad.GAMEPAD_LEFT_SHOULDER))
			{
			_curColor = (_curColor - 1 >= 0) ? _curColor - 1 : _colors.length - 1;
			updatePlayerColor();
			}
			
			if (_gamepad.wasButtonReleased(X360Gamepad.GAMEPAD_RIGHT_SHOULDER))
			{
			_curColor = (_curColor + 1 < _colors.length) ? _curColor + 1 : 0;
			updatePlayerColor();
			}
			
			if (_gamepad.isLeftStickButtonPressed()) trace('left');
			if (_gamepad.isRightStickButtonPressed()) trace('right');
			*/
			/**
			 * Triggers can now be gotten as a percentage
			 * _gamepad.rightTriggerAsPercent
			 * 
			 * They can also be gotten as a standard value 
			 * _gamepad.rightTrigger
			 */
			/*
			// right trigger fires
			if (_gamepad.rightTriggerAsPercent > 0.5)
			{
			doFire();
			_isFiring = true;
			}
			else
			{
			_isFiring = false;
			}
			
			// use the dpad or left stick to move
			if ( (_gamepad.isDPadLeftPressed() || _gamepad.leftStickX < -15000) && _player.x - 8 > 0)
			{
			_player.x -= 8;
			}
			
			if ( (_gamepad.isDPadRightPressed() || _gamepad.leftStickX > 15000) && _player.x + 8 < 800)
			{
			_player.x += 8;
			}
			
			// right stick controls the crosshairs
			// utilizing analog input (movement adjusts depending on how far the stick is pushed in a given direction)
			if (_gamepad.rightStickX < -10000)
			{
			_xhairs.x -= (50 * (_gamepad.rightStickX + 10000) / -32000);
			}
			else if (_gamepad.rightStickX > 10000)
			{
			_xhairs.x += (50 * (_gamepad.rightStickX - 10000) / 32000);
			}
			
			if (_gamepad.rightStickY > 10000)
			{
			_xhairs.y -= (50 * (_gamepad.rightStickY - 10000) / 32000);
			}
			else if (_gamepad.rightStickY < -10000)
			{
			_xhairs.y += (50 * (_gamepad.rightStickY + 10000) / -32000);
			}
			
			// limit xhairs to the display area
			if (_xhairs.x < -16)	_xhairs.x = -16;
			if (_xhairs.x > 784)	_xhairs.x = 784;
			if (_xhairs.y < -16)	_xhairs.y = -16;
			if (_xhairs.y > _ground.y - 16) _xhairs.y = _ground.y - 16;
			*/
		}
	}
}