package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.flixel.FlxGame;
	[SWF(width="465", height="465", frameRate="30")]
	public class SparkTwin extends Sprite
	{
		public function SparkTwin() {
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			run();
		}
		
		private function run():void
		{
			this.addChild(new FlxGame(465, 465, PlayState, 1));
		}
	}
}

import com.leapmotion.leap.CircleGesture;
import com.leapmotion.leap.Gesture;
import com.leapmotion.leap.LeapMotion;
import com.leapmotion.leap.Screen;
import com.leapmotion.leap.Vector3;
import com.leapmotion.leap.events.LeapEvent;

import flash.display.Sprite;
import flash.geom.Point;
import flash.utils.setTimeout;

import org.flixel.FlxEmitter;
import org.flixel.FlxG;
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
	
	private var leap:LeapMotion;
	private var screenList:Vector.<Screen>;
	private var screen:Screen;
	private var screenWidth:uint;
	private var screenHeight:uint;
	//private var cursor:FlxSprite;
	private var currentVectorPlayer1:Vector3;
	private var currentVectorPlayer2:Vector3;
	override public function create():void
	{
		//FlxG.bgColor = 0xFF000000;
		_player = new Player(228, 400);
		_player.index = 1;
		_player2 = new Player(258, 400);
		_player2.index = 2;
		
		_player.targetPoint = _player2.playerPoint;
		_player2.targetPoint = _player.playerPoint;
		
		
		_shots = Player.shots;
		_enemies = Enemy.enemies;
		_bullets = Bullet.bullets;
		this.add(_player);
		this.add(_player2);
		this.add(_shots);
		this.add(_enemies);
		this.add(_bullets);
		
		_textfield = new FlxText(0, 0, 200, "SCORE : 0 / MISS : 0 / RANK : 0");
		this.add(_textfield);
		
		BulletRunner.setDefaultScope(0, 0, 465, 465);
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
		//leap.controller.enableGesture( Gesture.TYPE_CIRCLE );
	}
	
	private function onFrame( event:LeapEvent ):void
	{
		if ( event.frame.pointables.length > 1 && FlxG.stage && FlxG.stage.nativeWindow)
		{
			/*
			Optionally, you can call screen.intersect() with a position and direction Vector3:
			screen.intersect( event.frame.pointables[ 0 ].tipPosition, event.frame.pointables[ 0 ].direction, true );
			*/
			/*for each ( var gesture:Gesture in event.frame.gestures() )
			{
				if(gesture is CircleGesture )
				{
					trace('shoot');
				}
			}*/
			currentVectorPlayer1 = screen.intersectPointable( event.frame.pointables[ 0 ], true );
			_player.x = FlxG.width * currentVectorPlayer1.x - FlxG.worldBounds.x;
			_player.y = FlxG.height * ( 1 - currentVectorPlayer1.y ) - FlxG.worldBounds.y;
			
			currentVectorPlayer2 = screen.intersectPointable( event.frame.pointables[ 1 ], true );
			_player2.x = FlxG.width * currentVectorPlayer2.x - FlxG.worldBounds.x;
			_player2.y = FlxG.height * ( 1 - currentVectorPlayer2.y ) - FlxG.worldBounds.y; 
		}
	}
	override public function update():void
	{           
		BulletRunner.updateTargetPosition(_player.x, _player.y);
		BulletRunner.updateTargetPosition(_player2.x, _player2.y);
		//collide
		//FlxG.collide(_bullets, _player, overlapBulletsPlayer);
		//FlxG.collide(_bullets, _player2, overlapBulletsPlayer);
		FlxG.collide(_shots, _enemies, overlapShotsEnemies);
		
		_player.targetPoint = _player2.playerPoint;
		_player2.targetPoint = _player.playerPoint;
		
		super.update();
	}
	
	// callback by "n" command of root object
	public function onRootNew(args:Array):BulletRunner
	{
		return Enemy.create();
	}
	
	public function overlapBulletsPlayer(bullet:Bullet, player:Player):void
	{
		var emitter:FlxEmitter = createEmitter(0xffffffff, 8);
		emitter.at(_player);
		
		emitter.at(_player2);
		
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
			_player2.targetPoint = _player.playerPoint;

		} else {
			_player2 = new Player(236, 400);  
			_player2.index = 2;
			add(_player2);			
			_player.targetPoint = _player2.playerPoint;			
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
	
	private var aimAngle:Number = 0;
	private var radAngle:Number = 0;
	
	public var targetPoint:FlxPoint;
	public var playerPoint:FlxPoint;
	
	public var playerDistance:Number;
	
	private var shotToggle:Boolean = false;
	
	public function Player(x:int, y:int)
	{
		super(x, y);
		//if (index == 1) {
			this.makeGraphic(8, 8, 0xffffffff);
		//} else {
		//	this.makeGraphic(8, 8, 0xdfdfdfff);
		//}
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
	override public function update():void
	{
		var vx:int = 0;
		var vy:int = 0;
		
		var keys:Keyboard = FlxG.keys;
		
		var left:int;
		var right:int;
		var down:int;
		var up:int;
		
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
		if (targetPoint) {
			playerDistance = FlxU.getDistance(playerPoint, targetPoint);
			//aimAngle = setAimAngle(targetPoint, playerPoint);
			aimAngle =getAnglePrecise(targetPoint.x - (x + (width/2)), targetPoint.y - (y + (height/2)));
			//this.angle = aimAngle - 180;
		}

		if (keys.justPressed("SPACE")){
			shotToggle = !shotToggle;
		}

		
		if((keys.X || keys.SPACE || shotToggle)) {
			
			var shot:Shot = new Shot();
			//shot.x = this.x + this.width/2 - shot.width/2;
			//shot.y = this.y;
			shot.reset(this.x,this.y);
			shot.angle = aimAngle;
			//var rFireAngle:Number = (playerDistance * (Math.PI / 180));
			var rFireAngle:Number = (aimAngle * (Math.PI / 180));
			if (playerDistance < 300) {
				shot.velocity.x = Math.cos(rFireAngle) * 100;
				shot.velocity.y = Math.sin(rFireAngle) * 100;				
			} 
			
			
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
			shot.distance = playerDistance;
			setTimeout(shot.kill,1500);
			shots.add(shot);
			
		}
	}
}

class Shot extends FlxSprite
{
	public var distance:Number;	
	
	public function Shot()
	{
		this.makeGraphic(5, 5, 0xffffffff);
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
		if (distance < 150) {
			y -= 10;
		}
		
		
		if (y < 0 || y > 465) this.kill();
		if (x < 0 || x > 465) this.kill();
		super.update();
	}
}