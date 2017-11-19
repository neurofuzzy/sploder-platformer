package  
{
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.util.PlayTimeCounter;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.xml.XMLNode;
	import fuz2d.model.object.TextureBlock;
	import fuz2d.screen.shape.ViewSprite;
	
	import fuz2d.*;
	import fuz2d.action.animation.PoseEditor;
	import fuz2d.action.behavior.*;
	import fuz2d.action.control.*;
	import fuz2d.action.physics.*;
	import fuz2d.action.play.*;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.library.GestureFactory;
	import fuz2d.library.ObjectFactory;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.model.material.Material;
	import fuz2d.model.object.Object2d;
	import fuz2d.model.object.Symbol;
	import fuz2d.sound.SoundManager;
	import fuz2d.util.ColorTools;
	import fuz2d.util.Geom2d;
	import fuz2d.util.ReduceColors;
	import fuz2d.util.TileDefinition;
	import fuz2d.screen.BitView;
	import fuz2d.screen.BitViewPlus;
	import fuz2d.screen.View;
	import fuz2d.screen.shape.PlayerDisplay;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class GameLevel
	{
		private var _name:String;
		private var fastDraw:Boolean;
		private var bleed:uint;
		
		public static var gameEngine:Fuz2d;
		
		public static var player:BipedObject;
		public static var playerAvatar:int;
		public static var playerAttribs:Object;
		public static var playerHome:Point;
		public static var lives:int = 1;
		
		protected var _gameObjective:GameObjective;
		public function get gameObjective():GameObjective { return _gameObjective; }	
		
		protected var _levelNum:uint = 1;
		public function get levelNum():uint { return _levelNum; }
		
		protected var _firstLevelLoaded:Boolean = false;
		
		protected var _game:Game;
		public function get game():Game { return _game; }

		protected var _container:Sprite;
		
		protected var _fuz2d:Fuz2d;
		public function get fuz2d():Fuz2d { return _fuz2d; }
		
		protected var _levelNode:XMLNode;
		protected var _envData:Array;
		
		protected var _shadowLight:ShadowLight;
		
		protected var _lastBump:int = 0;
		
		protected var _newLifeTimer:Timer;
		public static var lostLifeTime:int;
		
		protected var _exiting:Boolean = false;
		protected var _exitTimer:Timer;
		
		public static function initialize ():void {
			
			lives = 1;
			playerHome = new Point();

		}
		
		public function GameLevel (game:Game, container:Sprite, levelNum:uint = 1, firstLevelLoaded:Boolean = false) 
		{
			init(game, container, levelNum, firstLevelLoaded);
		}
		
		protected function init (game:Game, container:Sprite, levelNum:uint = 1, firstLevelLoaded:Boolean = false):void {
			
			_game = game;
			_container = container;
			_levelNum = levelNum;
			_firstLevelLoaded = firstLevelLoaded;
			
			_gameObjective = new GameObjective(this);
			_gameObjective.addEventListener(Event.COMPLETE, onGameObjectiveComplete);
			
			_fuz2d = new Fuz2d(Main.mainStage, _game.LibrarySWF);
			_fuz2d.addEventListener(Fuz2d.INITIALIZED, buildGame);
			_fuz2d.playfield.addEventListener(PlayfieldEvent.PAUSE, _game.onPauseToggle);
			
			if (!ObjectFactory.isInitialized) {
				ObjectFactory.initialize(_fuz2d, ObjectFactory.getEmbeddedString(_game.definitions));
			} else {
				ObjectFactory.main = _fuz2d;
			}
			
			if (!GestureFactory.isInitialized) {
				GestureFactory.initialize(_fuz2d, GestureFactory.getEmbeddedString(_game.gestures));
			} else {
				GestureFactory.main = _fuz2d;
			}
			
			gameEngine = _fuz2d;
			
			playerHome = new Point();
			playerAvatar = 0;
			lostLifeTime = -3000;
			
		}
		
		//
		//
		public function buildGame (e:Event = null):void {
			
			_fuz2d.removeEventListener(Fuz2d.INITIALIZED, buildGame);
			
			_levelNode = _game.gameXML.firstChild.firstChild.childNodes[_levelNum - 1];
			
			// env format = "bgNum,bgColor,gdColor,ambColor"
			_name = (_levelNode.attributes.name) ? unescape(unescape(_levelNode.attributes.name)) : "";
			_envData = String(_levelNode.attributes.env).split(",");
			playerAvatar = (_levelNode.attributes.avatar) ? parseInt(_levelNode.attributes.avatar) : 0;
			
			var clip:MovieClip;
			
			Main.mainStage.scaleMode = StageScaleMode.NO_SCALE;
			
			if (!Preloader.testing && Main.mainStage.stageWidth > 0 && Main.mainStage.stageHeight > 0) {
				
				var viewScale:Number = Math.max(Main.mainStage.stageWidth / 640, Main.mainStage.stageHeight / 480);
				viewScale = 0.8;
				if (viewScale > 0 && viewScale <= 2) View.scale = viewScale;
				
			}
			
			_fuz2d.simulation.gravity = 800;
			buildEnvironment(_fuz2d.model.environment);
			
			TileDefinition.ambientColor = 0x000000;
			
			fastDraw = (_game.gameXML.firstChild.attributes.fast == "1");
			bleed = 0;
			
			if (_game.gameXML.firstChild.attributes.bitview == "1") {
				
				fastDraw = true;
				_fuz2d.viewClass = BitView;
				View.scale = 0.6;
				Fuz2d.library.use8bitStyle = true;
				BitView.pixelScale = 2;
				ReduceColors.dither = true;
				BipedObject.jumpScale = 1.2;				
				
			} else {
				
				//_fuz2d.viewClass = BitViewPlus;
				if (fastDraw == true) _fuz2d.viewClass = BitViewPlus;
				View.scale = 0.6667;
				BitView.pixelScale = 1;
				bleed = 60;
	
			}
			
			Fuz2d.library.cleanTextureQueue();

			populateGame();
			
			var has_textureblocks:Boolean = false;
			
			for each (var gobj:Object2d in _fuz2d.model.objects)
			{
				if (gobj is TextureBlock)
				{
					has_textureblocks = true;
					TextureBlock(gobj).preload();
				}
			}
			
			if (has_textureblocks) Main.mainStage.addEventListener(Event.ENTER_FRAME, checkTextureProgress);
			else initViewAndStart();	
		}
		
		
		private function checkTextureProgress (e:Event):void
		{
			if (EmbeddedLibrary.textureQueue.percentComplete < 1) {
				Main.preloader.status = "Rendering level: " + Math.floor((1 - EmbeddedLibrary.textureQueue.percentComplete) * 100) + "%";
			} else {
				Main.mainStage.removeEventListener(Event.ENTER_FRAME, checkTextureProgress);
				initViewAndStart();
			}
		}
		
		
		private function initViewAndStart ():void
		{
			if (player == null) {
				Main.preloader.status = "Error in game data!";
				return;
			}
			
			_fuz2d.simulation.focalPoint = player.simObject;

			_fuz2d.simulation.addEventListener(CollisionEvent.COLLISION, onCollision, false, 0, true);

			var ambientLevel:Number = parseInt(String(_envData[3])) / 100;
			if (isNaN(ambientLevel) || _envData[3] == undefined) ambientLevel = 1;
			
			Environment.ambientLevel = ambientLevel;
			
			_shadowLight = _fuz2d.model.environment.addLight(new ShadowLight(_fuz2d.playfield.map, ambientLevel, 0xffffff, 0.3, 8)) as ShadowLight;
			
			_fuz2d.initView(_fuz2d.model, _fuz2d.camera, 10000, _container, 0, 0, 0, 0, true, true, fastDraw, Main.local);
			
			_fuz2d.view.setViewSize(_game.width, _game.height, Model.GRID_WIDTH * 2 + bleed);			
			_fuz2d.view.camera.alignTo(player.object);
			
			_fuz2d.view.camera.startWatching(player.object, 5, null, true);
			_fuz2d.view.checkChanged(null, true);
			
			Main.preloader.hide();
			
			_game.removeLevelScreen();
			_game.updateConsole();
			
			_gameObjective.start();
			
			if (_levelNode.attributes["music"] && _levelNode.attributes.music != "" && SoundManager.hasSound) {
				Fuz2d.sounds.loadSong(_levelNode.attributes.music);
				Game.console.musicTrack = _levelNode.attributes.music;
			} else {
				Game.console.musicTrack = "";
			}	
			
			if (!_firstLevelLoaded) start();
		}
		
		//
		//
		public function rebuildGame ():void {
			
			populateGame();
			
		}
		
		//
		//
		protected function populateGame ():void {
			
			
			var attribs_cache:Dictionary = new Dictionary();
			
			var objects:Array = _levelNode.firstChild.nodeValue.split("|");
			var def:Array;
			
			var objID:int;
			var x:int;
			var y:int;
			var rotation:Number;
			var t:int;
			var g:int = 0;
			var gv:int = 0;
			var ga:int = 0;
			var data:Array;
			
			var pobj:PlayObject;
			
			var attribs:TextureAttributes;
			
			var hasGraphics:Boolean = _game.gameXML.firstChild.attributes.g == "1";
			
			
			
			for (var i:int = 0; i < objects.length; i++) {
				
				def = objects[i].split(",");
				
				objID = parseInt(def[0]);
				x = parseInt(def[1]);
				y = parseInt(def[2]);
				rotation = parseInt(def[3]) * Geom2d.dtr;
				t = (def.length > 3) ? parseInt(def[4]) : -1
				if (isNaN(t)) t = -1;
				
				data = null;
				
				/*
				if (def.length > 3) {
					data = def.concat();
					data.shift();
					data.shift();
					data.shift();
				}
				*/
				
				if (hasGraphics) {
					g = (def.length > 5) ? parseInt(def[5]) : 0;
					gv = (def.length > 6) ? parseInt(def[6]) : 0;
					ga = (def.length > 7) ? parseInt(def[7]) : 0;
					data = (def.length > 8) ? def.slice(8, def.length) : null;
				} else {
					data = (def.length > 5) ? def.slice(5, def.length) : null;
				}
				
				if (isNaN(rotation)) rotation = 0;
				
				if (objID > 0 && !isNaN(x) && !isNaN(y)) {
					
					pobj = ObjectFactory.createNew(String(objID), this, x, y, ObjectFactory.getZIndex(objID + ""), { rotation: rotation, tileID: t, data: data } ) as PlayObject;
				
				}
				
				if (objID == 800 || objID == 801)
				{
					if (data != null && data[0] != null)
					{
						attribs = attribs_cache[data[0]];
						if (attribs == null) attribs = new TextureAttributes().initWithData(data[0]);
						
						TextureBlock(pobj.object).txAttribs = attribs;
					}
				}
				
				if (g > 0 && pobj != null && pobj.object != null)
				{
					pobj.object.graphic = g;
					pobj.object.graphic_version = gv;
					pobj.object.graphic_animation = ga;
					
					if (pobj.simObject is CompoundObject)
					{
						var co:CompoundObject = pobj.simObject as CompoundObject;
						var simobj:SimulationObject;
						
						for (var j:int = 0; j < co.subSimObjects.length; j++)
						{
							simobj = co.subSimObjects[j];
							
							if (simobj.objectRef != null)
							{
								simobj.objectRef.graphic = g;
								simobj.objectRef.graphic_version = gv;
								simobj.objectRef.graphic_animation = ga;
								if (co.objectRef.graphic_rectnames && co.objectRef.graphic_rectnames.length > j + 1)
								{
									simobj.objectRef.graphic_rectnames = [co.objectRef.graphic_rectnames[j + 1]];
								}
							}
						}
					}
				}
				
				if (objID == 1) {
					
					player = pobj as BipedObject;
					
					playerHome.x = x;
					playerHome.y = y;
					trace("AVATAR:", playerAvatar);
					player.body.avatar = playerAvatar;
					
				}
				
			}
			
			if (player) {
				
				if (_firstLevelLoaded) playerAttribs = player.object.attribs;
				else restorePlayerStatus();
				
				playerAttribs["graphic"] = player.object.graphic;
				playerAttribs["graphic_animation"] = player.object.graphic_animation;
				playerAttribs["graphic_version"] = player.object.graphic_version;
				playerAttribs["graphic_rectnames"] = player.object.graphic_rectnames;
				
			}
			
			_game.onLevelLoaded();
			
		}
		
		//
		//
		public function onCollision (e:CollisionEvent):void {
			
			if (TimeStep.stepTime - _lastBump > 100 && MotionObject(e.collider).velocity.y < -500) {
				
				try {
					var symb:String = "puff";
					if (e.reactionType == ReactionType.FLOAT) symb = "puffwater"; 
					if (e.reactionType == ReactionType.BOUNCE || e.reactionType == ReactionType.FLOAT) _fuz2d.model.addObject(new Symbol(symb, Fuz2d.library, null, null, e.contactPoint.x, e.contactPoint.y, 100));
					
					Fuz2d.sounds.addSound(e.collider, "punch5");
					
					_lastBump = TimeStep.stepTime;

				} catch (e:Error) {
					trace("GameLevel:", e);
				}
				
			}		
			
		}
		
		
		//
		//
		protected function buildEnvironment (env:Environment):void {
			
			// env format = "bgNum,bgColor,gdColor,ambColor"
			
			var env:Environment = _fuz2d.model.environment;
			
			env.distanceCue = false;
			
			env.skyColor = parseInt(_envData[1], 16);
			if (env.skyColor == 0) env.skyColor = 0x336699;
			
			env.horizonColor = ColorTools.getTintedColor(env.skyColor, 0xffffff, 0.25);
			
			env.groundColorFar = parseInt(_envData[2], 16);
			if (env.groundColorFar  == 0) env.skyColor = 0x333333;
			
			env.groundColorNear = ColorTools.getTintedColor(env.groundColorFar, 0xffffff, 0.25);
			
			env.show = true;
			
			var backgroundNum:int = parseInt(_envData[0]);
			if (isNaN(backgroundNum)) backgroundNum = 0;
			
			env.midGroundSymbol = "background" + backgroundNum;
			env.skySymbol = "sky1";
			
		}
		

		//
		//
		public function losePlayerLife ():void {
			
			if (!Game.ended) {
				
				if (_newLifeTimer != null && _newLifeTimer.running) return;
				lostLifeTime = TimeStep.stepTime;
				
				if (lives > 1) {
					
					lives--;
					_newLifeTimer = new Timer(2000, 1);
					_newLifeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, createNewPlayer);
					_newLifeTimer.start();
					
				} else {
					
					Game.console.finishGame(false);
					
				}
			
			}
			
		}
		
		//
		//
		protected function createNewPlayer (e:TimerEvent):void {
			
			_newLifeTimer.stop();
			_newLifeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, createNewPlayer);
			_newLifeTimer = null;
			
			var pobj:PlayObject = ObjectFactory.createNew("1", this, playerHome.x, playerHome.y, ObjectFactory.getZIndex("1")) as PlayObject;
			
			player = pobj as BipedObject;
			player.stamina = 0;
			player.body.avatar = playerAvatar;
			trace("RESTORING AVATAR:" + playerAvatar);
			
			if (playerAttribs) {
				if (playerAttribs["blue"]) player.object.attribs["blue"] = 1;
				if (playerAttribs["green"]) player.object.attribs["green"] = 1;
				if (playerAttribs["yellow"]) player.object.attribs["yellow"] = 1;
				if (playerAttribs["purple"]) player.object.attribs["purple"] = 1;
				
				if (playerAttribs["graphic"] != null) player.object.graphic = playerAttribs["graphic"];
				if (playerAttribs["graphic_animation"] != null) player.object.graphic_animation = playerAttribs["graphic_animation"];
				if (playerAttribs["graphic_version"] != null) player.object.graphic_version = playerAttribs["graphic_version"];
				if (playerAttribs["graphic_rectnames"] != null) player.object.graphic_rectnames = playerAttribs["graphic_rectnames"];
			}
			
			playerAttribs = player.object.attribs;
			
			playerAttribs["graphic"] = player.object.graphic;
			playerAttribs["graphic_animation"] = player.object.graphic_animation;
			playerAttribs["graphic_version"] = player.object.graphic_version;
			playerAttribs["graphic_rectnames"] = player.object.graphic_rectnames;
			
			if (player.object.graphic > 0 || player.body.avatar > 0)
			{
				var vs:ViewSprite = _fuz2d.view.objectSprites[player.object];
				if (vs) vs.rebuild();
			}
			
			_fuz2d.simulation.focalPoint = player.simObject;
			
			_fuz2d.view.camera.alignTo(player.object);
			_fuz2d.view.camera.startWatching(player.object, 5, null, true);
			_fuz2d.view.checkChanged(null, true);
			
			var sym:Symbol = ObjectFactory.effect(this, "blingeffect", true, -10);
			sym.point = player.object.point;
			
			Game.console.registerPlayer();
			Game.console.radar.addBlip(player);
			Game.console.updateStatus();
			
			player.eventSound("rebirth");
			
		}
		
		protected static function savePlayerStatus ():void {
			
			if (player) {
				
				var p:Object = playerAttribs;
				p.stamina = player.stamina;
				
				if (player.body) {
					
					p.armor_level = player.body.armor.level;
					p.tools_back = player.body.tools_back;
					p.tools_head = player.body.tools_head;
					p.tools_lt = player.body.tools_lt;
					p.tools_rt = player.body.tools_rt;
					p.tools_lt_current = player.body.tools_lt.toolname;
					p.tools_rt_current = player.body.tools_rt.toolname;
					
					/*
					p.graphic = player.body.graphic;
					p.graphic_animation = player.body.graphic_animation;
					p.graphic_version = player.body.graphic_version;
					p.graphic_rectnames = player.body.graphic_rectnames;
					*/
				} else {
					trace("Player could not be copied");
				}
				
			}			
			
		}
		
		protected static function restorePlayerStatus ():void {
			
			var p:Object = playerAttribs;
			
			if (player) {
				
				player.object.attribs = p;
				player.setInitialHealth(p.health * player.maxHealth);
				player.stamina = p.stamina;
				
				if (player.body) {
					
					player.body.armor.level = playerAttribs.armor_level;
					player.body.avatar = playerAvatar;
					
					if (p.tools_back) player.body.tools_back.copyTools(p.tools_back);
					if (p.tools_head) player.body.tools_head.copyTools(p.tools_head);
					
					player.body.tools_lt.copyTools(p.tools_lt, true);
					player.body.tools_rt.copyTools(p.tools_rt, true);
					
					player.body.tools_lt.setTool(p.tools_lt_current);
					player.body.tools_rt.setTool(p.tools_rt_current);
					
					/*
					player.body.graphic = p.graphic;
					player.body.graphic_animation = p.graphic_animation;
					player.body.graphic_version = p.graphic_version;
					player.body.graphic_rectnames = p.graphic_rectnames;
					*/
				}
				
			}
		
			if (Game.console) {
				Game.console.updateStatus();
			}
			
		}
		
		protected function get hasExitGateway ():Boolean {
			trace(LevelDoorController.doors.length);
			return LevelDoorController.doors.length > 0;
			
		}
		
		public function get levelNode():XMLNode 
		{
			return _levelNode;
		}
		
		public function get name():String 
		{
			return _name;
		}
		
		//
		protected function onGameObjectiveComplete (e:Event):void {
			
			if (!_exiting) {
				
				if (hasExitGateway && _gameObjective.type != GameObjective.TYPE_ESCAPE) {
					
					var i:int = LevelDoorController.doors.length;
					var door:LevelDoorController;
					
					while (i--) {
						
						door = LevelDoorController.doors[i];
						door.unlock();
						
					}
					
					if (_gameObjective.type == GameObjective.TYPE_MELEE && PlayObject.totals["evil"] == null) return;
					
					Game.console.showTaskNotice("unlocked");
				
				} else {
					
					if (_gameObjective.type == GameObjective.TYPE_MELEE && PlayObject.totals["evil"] == null) return;
					exitIfComplete();
					
				}
				
			}
			
		}
		
		//
		public function start ():void {
			
			View.mainStage.focus = _fuz2d.view.container;
			_fuz2d.playfield.start();
			_gameObjective.onStatusChange();
			
			if (Game.startTime == 0) Game.startTime = TimeStep.stepTime;
			
		}
		
		//
		public function stop ():void {
			
			if (_fuz2d && _fuz2d.playfield) _fuz2d.playfield.stop();
			
		}
		
		//
		public function exitIfComplete ():void {
			
			if (!_exiting && _gameObjective.complete) {
				
				if (_levelNum == Game.totalLevels) {
					
					if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
					Game.console.finishGame(true);
					
				} else {
					
					Game.console.showTaskNotice("complete");
					
					if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
					_exiting = true;
					_exitTimer = new Timer(3000, 1);
					_exitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onExitTimerComplete);
					_exitTimer.start();
				
				}
				
			}
			
		}
		
		protected function onExitTimerComplete (e:TimerEvent):void {
			
			_exitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onExitTimerComplete);
			
			_game.nextLevel();
			
		}
		
		//
		//
		public function end ():void {
			
			trace("GAMELEVEL END");
			savePlayerStatus();
			
			if (_levelNode.attributes["music"] && _levelNode.attributes.music != "") {
				Fuz2d.sounds.unloadSong();
			}
			
			if (Game.console) {
				Game.console.unregisterPlayer(false);
				Game.console.unregisterPlayfield();
			}
			
			ObjectFactory.main = null;
			GestureFactory.main = null;
			LevelDoorController.doors = [];
			
			if (_shadowLight) {
				_shadowLight.destroy();
				_shadowLight = null;
			}
			
			if (_fuz2d) {
				if (_fuz2d.playfield) _fuz2d.playfield.removeEventListener(PlayfieldEvent.PAUSE, _game.onPauseToggle);
				if (_fuz2d.simulation) _fuz2d.simulation.removeEventListener(CollisionEvent.COLLISION, onCollision);
				_fuz2d.end();
				_fuz2d = null;
			}
			
			if (_gameObjective) {
				_gameObjective.removeEventListener(Event.COMPLETE, onGameObjectiveComplete);
				_gameObjective.end();
				_gameObjective = null;
			}
			
		}
		
	}

}