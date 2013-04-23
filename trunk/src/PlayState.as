package
{
	import org.flixel.*;
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
	import flash.utils.setTimeout;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxParticle;

	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.si.cml.CMLObject;

	import org.si.cml.extensions.BulletRunner;

	public class PlayState extends FlxState
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
			//leap = new LeapMotion();
			//leap.controller.addEventListener( LeapEvent.LEAPMOTION_CONNECTED, onConnect );
			//leap.controller.addEventListener( LeapEvent.LEAPMOTION_FRAME, onFrame );
			
			
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
		
		public function overlapShotsEnemies(shot:Shoot, enemy:Enemy):void
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
}
