package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.flixel.FlxGame;
	[SWF(width="600", height="600", frameRate="30")]
	public class SparkTwin3 extends Sprite
	{
		public function SparkTwin3() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.stageWidth = 600;
			stage.stageHeight = 600;
			run();
		}
		
		private function run():void
		{
			
			this.addChild(new Main());
		}
	}
}

import com.leapmotion.leap.CircleGesture;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.Frame;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.LeapMotion;
import com.leapmotion.leap.Screen;
import com.leapmotion.leap.Vector3;
import com.leapmotion.leap.events.LeapEvent;
import com.leapmotion.leap.util.LeapUtil;
import com.rhuno.Airxbc;
import com.rhuno.X360Gamepad;

import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.setTimeout;

import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGame;
import org.flixel.FlxGroup;
import org.flixel.FlxParticle;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxU;
import org.flixel.system.input.Keyboard;
import org.si.cml.CMLObject;
import org.si.cml.CMLSequence;
import org.si.cml.extensions.BulletRunner;

class Main extends FlxGame
{
	public function Main()
	{
		//FlxG.debug = true;
		super(600, 600, PlayState, 1, 60, 30);
		forceDebugger = true;
		//addChild(new Stats);
	}
}

class PlayState extends FlxState
{         
	//root sequence
	private var _rootCML:String = "py16[[px$??*216+216n{10}w40-$r*20]4l$r+=0.1]";
	
	private var _missCount:int;
	private var _score:int;
	private var _textfield:FlxText;
	
	private var _player:Player;
	private var _player2:Player;
	
	private var _shots:FlxGroup;
	private var _enemies:FlxGroup;
	private var _bullets:FlxGroup;
	
	private var _bg:FlxSprite;
	
	private var leap:LeapMotion;
	private var screenList:Vector.<Screen>;
	private var screen:Screen;
	private var screenWidth:uint;
	private var screenHeight:uint;
	//private var cursor:FlxSprite;
	private var currentVectorPlayer1:Vector3;
	private var currentVectorPlayer2:Vector3;
	private var _ext:Airxbc;
	public var _gamepad:X360Gamepad;
	
	[Embed(source = '../assets/bg.png')] private var bg:Class;
	
	override public function create():void
	{
		_ext = new Airxbc();
		FlxG.stage.addChild(new Stats);
		//FlxG.bgColor = 0xFF000000;
		_player = new Player(FlxG.width/2, FlxG.height/2);
		_player.index = 1;
		//_player2 = new Player(258, 400);
		//_player2.index = 2;
		
		//_player.targetPoint = _player2.playerPoint;
		//_player2.targetPoint = _player.playerPoint;
		
		_bg = new FlxSprite();
		_bg.loadGraphic(bg, false, false, 600, 600, true);
		
		this.add(_bg);
		
		_shots = Player.shots;
		_enemies = Enemy.enemies;
		_bullets = Bullet.bullets;
		this.add(_player);
		//this.add(_player2);
		this.add(_shots);
		this.add(_enemies);
		this.add(_bullets);
		
		_textfield = new FlxText(0, 0, 200, "SCORE : 0 / MISS : 0 / RANK : 0");
		this.add(_textfield);
		
		BulletRunner.setDefaultScope(0, 0, FlxG.width, FlxG.height);
		var br:BulletRunner = BulletRunner.apply( new Sprite() );//dummy?
		br.callbacks = {"onNew": onRootNew};
		br.runSequence(_rootCML);
		
		
		
		//FlxG.stage.align = StageAlign.TOP_LEFT;
		//stage.scaleMode = StageScaleMode.NO_SCALE;
		//stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
		//cursor = new FlxSprite();
		//cursor = cursor.makeGraphic(10, 10, 0x00ff00ff);
		//cursor.graphics.beginFill( 0xff0000 );
		//cursor.graphics.drawCircle( -5, -5, 10 );
		//cursor.graphics.endFill();
		//this.add( cursor );
		//FlxG.debug=true;
		leap = new LeapMotion();
		leap.controller.addEventListener( LeapEvent.LEAPMOTION_CONNECTED, onConnect );
		leap.controller.addEventListener( LeapEvent.LEAPMOTION_FRAME, onFrame );
		
	
		super.create();
	}
	
	private function onConnect( event:LeapEvent ):void
	{
		trace( "Connected" );
		screenList = leap.controller.calibratedScreens();
		screen = screenList[ 0 ];
		screenWidth = screen.widthPixels();
		screenHeight = screen.heightPixels();
		leap.controller.enableGesture( Gesture.TYPE_CIRCLE );
	}
	
	private function onFrame( event:LeapEvent ):void
	{
		
		var frame:Frame = event.frame;
		//trace( "Frame id: " + frame.id + ", timestamp: " + frame.timestamp + ", hands: " + frame.hands.length + ", fingers: " + frame.fingers.length + ", tools: " + frame.tools.length + ", gestures: " + frame.gestures().length );
		var hand:Hand;
		if ( frame.hands.length > 0 )
		{
			// Get the first hand
			hand = frame.hands[ 0 ];
			
			// Check if the hand has any fingers
			var fingers:Vector.<Finger> = hand.fingers;
			if ( !fingers.length == 0 )
			{
				// Calculate the hand's average finger tip position
				var avgPos:Vector3 = Vector3.zero();
				for each ( var finger:Finger in fingers )
				avgPos = avgPos.plus( finger.tipPosition );
				
				avgPos = avgPos.divide( fingers.length );
				//trace( "Hand has " + fingers.length + " fingers, average finger tip position: " + avgPos );
				
				//currentVectorPlayer1 = screen.intersectPointable( event.frame.pointables[ 0 ], true );
				currentVectorPlayer1 = screen.intersect( hand.palmPosition,hand.direction, true );
				var direction:Vector3 = hand.direction;
				var pitch:Number = LeapUtil.toDegrees( direction.pitch ) - 24;
				trace(pitch);
				if (pitch > 5 ) {
					_player.setClockwiseness('clockwise');
				} else if (pitch < -5 ){
					_player.setClockwiseness('counterclockwise');
				}
				_player.x = FlxG.width * currentVectorPlayer1.x - FlxG.worldBounds.x;
				_player.y = FlxG.height * ( 1 - currentVectorPlayer1.y ) - FlxG.worldBounds.y;
				
			}
			
			// Get the hand's sphere radius and palm position
			//trace( "Hand sphere radius: " + hand.sphereRadius + " mm, palm position: " + hand.palmPosition );
			
			// Get the hand's normal vector and direction
			var normal:Vector3 = hand.palmNormal;
			var direction:Vector3 = hand.direction;
			
			// Calculate the hand's pitch, roll, and yaw angles
			trace( "Hand pitch: " + LeapUtil.toDegrees( direction.pitch ) + " degrees, " + "roll: " + LeapUtil.toDegrees( normal.roll ) + " degrees, " + "yaw: " + LeapUtil.toDegrees( direction.yaw ) + " degrees\n" );
		}
		
		if ( event.frame.pointables.length > 0 && FlxG.stage && FlxG.stage.nativeWindow)
		{
			/*
			Optionally, you can call screen.intersect() with a position and direction Vector3:
			screen.intersect( event.frame.pointables[ 0 ].tipPosition, event.frame.pointables[ 0 ].direction, true );
			*/
			for each ( var gesture:Gesture in event.frame.gestures() )
			{
				if(gesture is CircleGesture )
				{
					var circle:CircleGesture = CircleGesture( gesture );
					var clockwiseness:String;
					var angle:Number = circle.pointable.direction.angleTo( circle.normal )
					if ( angle <= Math.PI / 4 )
					{
						// Clockwise if angle is less than 90 degrees
						clockwiseness = "clockwise";
					}
					else
					{
						clockwiseness = "counterclockwise";
					}
					//trace('shoot '+ angle);
					// Calculate angle swept since last frame
					var sweptAngle:Number = 0;
					if ( circle.state != Gesture.STATE_START )
					{
						var previousGesture:Gesture = leap.frame( 1 ).gesture( circle.id );
						if( previousGesture.isValid() )
						{
							var previousUpdate:CircleGesture = CircleGesture( leap.frame( 1 ).gesture( circle.id ) );
							sweptAngle = ( circle.progress - previousUpdate.progress ) * 2 * Math.PI;
						}
					}
					
					
					//_player.setClockwiseness(clockwiseness);
					//trace( "Circle id: " + circle.id + ", " + circle.state + ", progress: " + circle.progress + ", radius: " + circle.radius + ", angle: " + LeapUtil.toDegrees( sweptAngle ) + ", " + clockwiseness );

				}
			}
			
			
			
			//_player.angle = LeapUtil.toDegrees( sweptAngle ) * 180 / Math.PI;
			//currentVectorPlayer2 = screen.intersectPointable( event.frame.pointables[ 1 ], true );
			//_player2.x = FlxG.width * currentVectorPlayer2.x - FlxG.worldBounds.x;
			//_player2.y = FlxG.height * ( 1 - currentVectorPlayer2.y ) - FlxG.worldBounds.y; 
		}
	}
	override public function update():void
	{         
		
		try
		{
			//_ctrlField.text = "Controllers Connected: " + _ext.getNumControllers().toString();
			_gamepad = _ext.pollGamePad();	
			
			ResourceManager.gamepad = _gamepad;
			//_connectMsg.visible = false;
			//trace('gamepad connected');
		}
		catch (e:Error)
		{
			//_connectMsg.visible = true;
			//return;
			trace(e);
		}
		
		BulletRunner.updateTargetPosition(_player.x, _player.y);
		//BulletRunner.updateTargetPosition(_player2.x, _player2.y);
		//collide
		//FlxG.collide(_bullets, _player, overlapBulletsPlayer);
		//FlxG.collide(_bullets, _player2, overlapBulletsPlayer);
		FlxG.collide(_shots, _enemies, overlapShotsEnemies);
		
		//_player.targetPoint = _player2.playerPoint;
		//_player2.targetPoint = _player.playerPoint;
		
		super.update();
	}
	
	// callback by "n" command of root object
	public function onRootNew(args:Array):BulletRunner
	{
		/*var enemy:Enemy    = new Enemy();
		var br:BulletRunner = BulletRunner.apply(enemy);
		
		br.callbacks = enemy;
		return br;*/
		return Enemy.create();
	}
	
	public function overlapBulletsPlayer(bullet:Bullet, player:Player):void
	{
		var emitter:FlxEmitter = createEmitter(0xffffffff, 8);
		emitter.at(_player);
		
		//emitter.at(_player2);
		
		emitter.start();
		this.add(emitter);
		
		_bullets.kill();
		player.kill();
		
		_missCount++;
		updateText();
		
		BulletRunner.pause();
		setTimeout(reborn, 1000,player);
	}
	private function reborn(player:Player):void
	{	
		if (player.index == 1) {
			_player = new Player(216, 400);  
			_player.index = 1;
			add(_player);
			//_player2.targetPoint = _player.playerPoint;

		} else {
			//_player2 = new Player(236, 400);  
			//_player2.index = 2;
			//add(_player2);			
			//_player.targetPoint = _player2.playerPoint;			
		}
		
		_bullets = new FlxGroup();
		Bullet.bullets = _bullets;
		add(_bullets);
		
		BulletRunner.resume();
	}
	
	public function overlapShotsEnemies(shot:Shot, enemy:Enemy):void
	{
		var emitter:FlxEmitter = createEmitter(0xffff0000, 2);
		emitter.at(enemy);
		emitter.start();
		this.add(emitter);
		
		enemy.damage(0.2);
		_score++;
		updateText();
	}
	
	private function updateText():void
	{
		_textfield.text = "SCORE : " + _score.toString() + " / MISS : " + _missCount.toString() + " / RANK : " + CMLObject.globalRank.toFixed(1);
	}    
	
	private function createEmitter(color:uint, num:int):FlxEmitter
	{
		var emitter:FlxEmitter = new FlxEmitter();
		emitter.gravity = 0;
		emitter.maxRotation = 0;
		emitter.setXSpeed(-500, 500);
		emitter.setYSpeed(-500, 500);
		var particles:int = num;
		for(var i: int = 0; i < particles; i++) {
			var particle:FlxParticle = new FlxParticle();
			particle.makeGraphic(2, 2, color);
			particle.exists = false;
			emitter.add(particle);
		}
		return emitter;        
	}
}

class Enemy extends FlxSprite
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

class Bullet extends FlxSprite
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

class Player extends FlxSprite
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
			
			var shot:Shot = new Shot();
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

class Shot extends FlxSprite
{
	public var distance:Number;	
	
	public function Shot()
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