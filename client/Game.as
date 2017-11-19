package {
	
	import com.sploder.data.*;
	import com.sploder.GameConsole;
	import com.sploder.SignString;
	import com.sploder.texturegen_internal.TextureRendering;
	import com.sploder.texturegen_internal.util.ThreadedQueue;
	import com.sploder.util.Base64;
	import com.sploder.util.Cleanser;
	import com.sploder.util.PlayTimeCounter;
	import com.sploder.util.Textures;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.net.LocalConnection;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import fuz2d.action.play.PlayfieldEvent;
	import fuz2d.Fuz2d;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.sound.SoundManager;
	import fuz2d.TimeStep;
	import fuz2d.util.ColorTools;
	import Main;
	
	

	//import mdm.System;


	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Game {
	
		public static const START:String = "game_start";
		public static const END:String = "game_end";
		public static const PAUSE:String = "game_pause";
		public static const RESTART:String = "game_restart";
		public static const RESULT_SUBMIT:String = "game_result_submit";
		public static const RESULT_SUBMIT_DONE:String = "game_result_submit_done";
		
		public static var do_submit_score:Boolean = true;
		
		[Embed(source = "assets/library.swf", mimeType="application/octet-stream")]
		public var LibrarySWF:Class;
		
		protected var _uiLibrary:EmbeddedLibrary;
		
		[Embed(source = "assets/library_definitions.xml", mimeType = "application/octet-stream")]
		public var definitions:Class;
		
		[Embed(source = "assets/gesture_definitions.xml", mimeType = "application/octet-stream")]
		public var gestures:Class;
			
		protected var _main:Main;
		protected var _container:Sprite;
		protected var _levelContainer:Sprite;
		protected var _consoleContainer:Sprite;
		protected var _levelScreen:Sprite;
		
		protected var _width:int;
		protected var _height:int;
		
		protected var _currentLevel:GameLevel;
		protected var _currentLevelNum:uint = 0;
		protected var _firstLevel:Boolean = true;
		
		public static var gameInstance:Game;
			
		protected var _gameXML:XMLDocument;
		
		public static var s:String;
		
		public static var title:String = "Game Preview";
		public static var author:String = "You";
		public static var difficulty:int = 5;
		public static var rating:int = 3;
		
		public static var gamedata:URLVariables;
		
		public static var totalLevels:int = 1;
		public static var totalEnemies:int = 0;
		public static var totalCrystals:int = 0;

		public static var startTime:int = 0;
		public static var pauseTime:int = 0;
		public static var endTime:int = 0;
		
		public static var ended:Boolean = false;
		
		public static var wonGame:Boolean = false;
		public static var gameResultSubmitted:Boolean = false;
		
		private var _timer:Timer;
		public function get timer():Timer { return _timer; }
		
		public function get width():int { return _width; }
		
		public function get height():int { return _height; }
		
		public function get gameXML():XMLDocument { return _gameXML; }
		
		public function get currentLevel():GameLevel { return _currentLevel; }
		
		public function get uiLibrary():EmbeddedLibrary { return _uiLibrary; }
		
		public function get currentLevelNum():uint 
		{
			return _currentLevelNum;
		}
		
		public function set currentLevelNum(value:uint):void 
		{
			_currentLevelNum = value;
		}
		
		public static var console:GameConsole;
		
		public static var testing:Boolean = false;

		public var ctr:int = 0;
		
		public var gameResultLoader:URLLoader;
        public var gameResultVars:URLVariables;
		public var gameResultRequest:URLRequest;
		
		protected static var eventLC:LocalConnection;
		protected static var eventLCName:String = "_sploder_events";

		
		//
		//
		public function Game (main:Main, data:Object, container:Sprite = null) {

			init(main, data, container);
			
		}
		
		//
		//
		protected function init (main:Main, data:Object, container:Sprite = null):void {
			
			_main = main;

			testing = Preloader.testing;
			
			_gameXML = new XMLDocument();
			_gameXML.ignoreWhite = true;
			_gameXML.parseXML(String(data));
			
			if (_gameXML.firstChild.firstChild.nodeName != "levels") {
				convertOldXMLToNew();
			}
			
			extractGraphicsFromXMLDocument();
			
			title = unescape(_gameXML.firstChild.attributes.title);
			author = unescape(_gameXML.firstChild.attributes.author);
			
			s = User.s;
			
			_container = container;
			_levelContainer = new Sprite();
			_container.addChild(_levelContainer);
			_consoleContainer = new Sprite();
			_container.addChild(_consoleContainer);
			
			gameInstance = this;
			
			ended = wonGame = false;
			
			_currentLevelNum = 0;
			
			startTime = endTime = pauseTime = GameLevel.lostLifeTime = 0;
			
			totalLevels = _gameXML.firstChild.firstChild.childNodes.length;
			
			GameLevel.initialize();

			if (_container == null) _container = Sprite(Main.mainStage.addChild(new Sprite()));
			
			Main.mainStage.scaleMode = StageScaleMode.NO_SCALE;
			Main.mainStage.align = StageAlign.TOP_LEFT;
			
			_width = Math.min(720, Math.max(Main.mainStage.stageWidth, 360));
			_height = Math.min(540, Math.max(Main.mainStage.stageHeight, 240));
	
			if (Main.mainStage.stageWidth > 720) _container.x = (Main.mainStage.stageWidth - 720) / 2;
			if (Main.mainStage.stageHeight > 540) _container.y = (Main.mainStage.stageHeight - 540) / 2;
			
			Main.dataLoader.addEventListener(DataLoaderEvent.DATA_LOADED, onXML);
			
			if (!testing) {
				eventLC = new LocalConnection();
				eventLC.addEventListener(StatusEvent.STATUS, onEventStatus);
				eventLC.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onEventStatus);
			}
			
			if (gamedata == null && !Main.localContent) {
				Main.dataLoader.loadMetadata("/php/getgamedata.php?g=" + User.m, true, onGameDataLoaded);
			}
			
			_uiLibrary = new EmbeddedLibrary(LibrarySWF);
			_uiLibrary.addEventListener(Event.INIT, onUILibraryLoaded);
			
			ThreadedQueue.mainStage = TextureRendering.mainStage = Main.mainStage;
			
			new PlayTimeCounter().init();
			
		}
		
		//
		//
		//
		protected function convertOldXMLToNew ():void {
			
			// metadata
			//
			
			var id:String = _gameXML.firstChild.attributes.id;
			var pubkey:String = _gameXML.firstChild.attributes.pubkey;	
			var title:String = _gameXML.firstChild.attributes.title;
			var author:String = _gameXML.firstChild.attributes.author;
			
            var mode:String = _gameXML.firstChild.attributes.mode;
			var date:String = _gameXML.firstChild.attributes.date;
			var comments:String = _gameXML.firstChild.attributes.comments;
			var isprivate:String = _gameXML.firstChild.attributes.isprivate;
			var fast:String = _gameXML.firstChild.firstChild.attributes.fast;
			var bitview:String = _gameXML.firstChild.firstChild.attributes.bitview;
			
			// environment 
			//
			
			var envNode:XMLNode = _gameXML.firstChild.firstChild;
			var bgNum:int = 1;
			var bgColor:uint = 0x336699;
			var gdColor:uint = 0x333333;
			var ambColor:Number = 1;
			
			if (envNode.attributes.bkgd != undefined) {
				bgNum = parseInt(envNode.attributes.bkgd);
			}
			
			if (envNode.attributes.bgcolor != undefined) {
				bgColor = ColorTools.HTMLColorToNumber(envNode.attributes.bgcolor);
			}
			
			if (envNode.attributes.gdcolor != undefined) {
				gdColor = ColorTools.HTMLColorToNumber(envNode.attributes.gdcolor);
			}
			
			if (envNode.attributes.ambcolor != undefined) {
				ambColor = parseInt(envNode.attributes.ambcolor) / 100;
			}
			
			var env:Array = [bgNum.toString(), bgColor.toString(16), gdColor.toString(16), Math.floor(ambColor * 100).toString()];
			
			// objects
			//
			
			var objects:String = XMLNode(_gameXML.firstChild.firstChild.nextSibling).firstChild.nodeValue;
			
			// reparse XML
			//
			
			var newXML:String = "<level env=\"" + env.join(",") + "\">" + objects + "</level>";
			
			var template:String = '<project title=""><levels id="levels"><level></level></levels></project>';
			template = template.split("<level></level>").join(newXML);
			
			_gameXML = new XMLDocument();
			_gameXML.ignoreWhite = true;
			_gameXML.parseXML(template);
			
			_gameXML.firstChild.attributes.id = id;
			_gameXML.firstChild.attributes.pubkey = pubkey;	
			_gameXML.firstChild.attributes.title = title;
			_gameXML.firstChild.attributes.author = author;
			
            _gameXML.firstChild.attributes.mode = mode;
			_gameXML.firstChild.attributes.date = date;
			_gameXML.firstChild.attributes.comments = comments;
			_gameXML.firstChild.attributes.isprivate = isprivate;
			_gameXML.firstChild.attributes.fast = fast;
			_gameXML.firstChild.attributes.bitview = bitview;
			
		}
		
		//
		//
		public function onGameDataLoaded (e:Event):void {
			
			var loader:URLLoader = URLLoader(e.target);
			var urlVars:String = loader.data;
			trace(urlVars);
			if (urlVars.charAt(0) == "&") urlVars = urlVars.replace("&", "");
			
			gamedata = new URLVariables();
			try {
				
				gamedata.decode(urlVars);
			
				if (gamedata.username != null) author = gamedata.username;
				if (gamedata.difficulty != null && !isNaN(parseInt(gamedata.difficulty))) difficulty = parseInt(gamedata.difficulty);
				if (gamedata.rating != null && !isNaN(parseInt(gamedata.rating))) rating = parseInt(gamedata.rating);
				
			} catch (e:Error) {
				
				author = "Unknown";
				difficulty = 5;
				rating = 3;
				
			}
		}
		
		//
		//
		protected function onXML (e:DataLoaderEvent):void {
			
			_gameXML = new XMLDocument(Main.dataLoader.xml.toString());

			if (_gameXML != null) {
				
				initializeMediaManagers();
				
			}
			
		}
		
		
		protected function extractGraphicsFromXMLDocument ():void {
			
			if (_gameXML && 
				_gameXML.firstChild && 
				_gameXML.firstChild.firstChild && 
				_gameXML.firstChild.firstChild.nextSibling) {
				
				var graphicsNode:XMLNode = _gameXML.firstChild.firstChild.nextSibling;
				
				for (var i:int = 0; i < graphicsNode.childNodes.length; i++) {
					
					var name:String = XMLNode(graphicsNode.childNodes[i]).attributes.name;
					
					if (name)
					{
						var rects_string:String = XMLNode(graphicsNode.childNodes[i]).attributes.rects;
						if (rects_string)
						{
							var rects:Array = rects_string.split(";");
							
							for each (var rect_string:String in rects)
							{
								if (rect_string != null && rect_string.length > 0)
								{
									var rect_key:String = rect_string.split(":")[0];
									var rect_props:Array = rect_string.split(":")[1].split(",");
									var rect:Rectangle = new Rectangle(rect_props[0], rect_props[1], rect_props[2], rect_props[3]);
									Textures.addRectFor(name, rect_key, rect); 
								}
							}
						}
					}
					
					if (name && !Textures.isLoaded(name)) {
						
						var pngString:String = XMLNode(graphicsNode.childNodes[i]).firstChild.nodeValue;
						
						if (pngString) {
							
							var bytes:ByteArray = Base64.decodeToByteArray(pngString);
							
							if (bytes) {
								
								var loader:Loader = new Loader();
								loader.name = name;
								loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGraphicExtracted);
								loader.loadBytes(bytes);
								
							}
							
							
						}
						
					}
					
				}
				
			}
			
		}
		
		protected function onGraphicExtracted (e:Event):void {
			
			if (e.target is LoaderInfo) {
				var loader:Loader = LoaderInfo(e.target).loader;
				if (loader.content is Bitmap) {
					Textures.addBitmapDataToCache(loader.name, Bitmap(loader.content).bitmapData);
				} else {
					trace("Error: loaded file is not bitmap", loader.name, loader.content);
				}
			}
			
		}
		
		
		//
		//
		protected function initializeMediaManagers ():void {
			
			
		}
		
		//
		//
		protected function onUILibraryLoaded (e:Event):void {
			
			_uiLibrary.removeEventListener(Event.INIT, onUILibraryLoaded);
			
			startGame();
			
		}
		
		/**
		 * Create a sound effects library using an embedded SWF
		 * @param	librarySWF
		 */
		public function createSFXLibrary (SFXSWF:Class):void {
			
			Fuz2d.createSoundManager(SFXSWF);

		}
		
		public function addSFX2toLibrary (SFX2SWF:Class):void {
			
			if (Fuz2d.sounds) {
				Fuz2d.sounds.addSFX2(SFX2SWF);
			}
			
		}
		
		public function startGame ():void {
			
			nextLevel();
			
			Main.mainStage.addEventListener(Event.ENTER_FRAME, updateGame);
			Main.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
			
		}
		
		//
		public function updateGame (e:Event):void {
			
			if (!ended && User["done"] == true) {

				endGame(false);
				
				if (_currentLevel != null) {
					_currentLevel.end();
					_currentLevel = null;
				}
				
				unloadAllReferences();
	
			}

		}
		
		public function nextLevel ():void {
			
			if (_currentLevel) _currentLevel.end();
			
			_currentLevelNum = Math.min(totalLevels, _currentLevelNum + 1);
			
			if (totalLevels > 1) {
				Preloader.instance.hide();
				showLevelScreen(_currentLevelNum, GameObjective.getGameObjectiveForLevel(_currentLevelNum));
			}
			
			//forceGC();
			
			pauseTime = getTimer();
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
			
			_timer = new Timer(2000, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, loadNextLevel);
			_timer.start();
			
		}
		
		protected function loadNextLevel (e:TimerEvent):void {
			
			if (_timer) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, loadNextLevel);
				_timer = null;
			}
			
			if (ended) return;
			
			_currentLevel = new GameLevel(this, _levelContainer, _currentLevelNum, _firstLevel);
			
			_firstLevel = false;
			
		}
		
		public function onLevelLoaded ():void {
			
			var pauseLength:int = TimeStep.stepTime - pauseTime;
			startTime += pauseLength;
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.resume();
			
		}
		
		//
		//
		public function showLevelScreen (levelNum:uint = 1, gameType:int = 0):void {
			
			if (_levelScreen == null) _levelScreen = uiLibrary.getDisplayObject("leveldialogue") as Sprite;
			
			if (_levelScreen != null) {
				
				_levelScreen.mouseEnabled = true;
				_levelScreen.mouseChildren = true;
				_levelScreen.x = Math.floor(_width * 0.5 - _levelScreen.width * 0.5);
				_levelScreen.y = Math.floor(_height * 0.5 - _levelScreen.height * 0.5);
				_container.addChild(_levelScreen);
				
				initLevelScreen(levelNum, gameType);
				
			}	
		}
		
		//
		//
		public function removeLevelScreen ():void {
			
			if (_levelScreen != null && _container.getChildIndex(_levelScreen) != -1) _container.removeChild(_levelScreen);
			
		}
		
		protected function initLevelScreen (levelNum:uint = 1, gameType:int = 0):void {
					
			// title tf
			
			var tf:TextField = _levelScreen["title"];
			
			if (tf) tf.text = "LEVEL " + levelNum;
			
			// level mcs
			
			for (var i:int = 1; i <= 9; i++) {
				
				var mc:MovieClip = _levelScreen["level" + i];
				mc.alpha = (i < levelNum) ? 0.5 : 1;
				if (i <= levelNum) mc.gotoAndStop(i + 2);
				else if (i <= Game.totalLevels) mc.gotoAndStop("locked");
				else mc.gotoAndStop(1);
				
			}
			
			// level name
			
			var level_node:XMLNode = _gameXML.firstChild.firstChild.childNodes[levelNum - 1];
			if (level_node.attributes.name != null) 
			{
				var format:TextFormat = new TextFormat();
				format.letterSpacing = -2;
				TextField(_levelScreen["levelname"]).defaultTextFormat = format;
				_levelScreen["levelname"].text = Cleanser.cleanse(String(unescape(unescape(unescape(level_node.attributes.name))))).toUpperCase();
			}
			else _levelScreen["levelname"].text = "";
			
			// mission mc
			
			var mmc:MovieClip = _levelScreen["mission"];
			
			mmc.gotoAndStop(gameType + 1);
			
			
		}
		
		public function updateConsole ():void {
			
			if (console == null) {
				console = new GameConsole(this, _consoleContainer, _width, _height);
			} else {
				console.registerPlayfield(_currentLevel.fuz2d.playfield);
				console.registerPlayer();
				console.updateGameType();
			}
			
		}
		
		
		//
		public static function restartGame ():void {
			
			ended = wonGame = gameResultSubmitted = false;
			
			if (gameInstance) gameInstance.end();

			Preloader.restart();

		}
		
		public function forceGC ():void {
			
			trace("forcing GC");
			
			try {
			  	new LocalConnection().connect('foo');
			  	new LocalConnection().connect('foo');
			} catch (e:*) {
				trace("Game forceGC:", e);
			}
			
		}
		
		//
		public static function unloadAllReferences ():void {
			
			Main.global = null;
			GameLevel.gameEngine = null;
			GameLevel.player = null;
			GameLevel.playerHome = null;
			Fuz2d.sounds = null;
			console = null;
			Main.mainInstance = null;
			
		}
		
		//
		public function onPauseToggle (e:PlayfieldEvent):void {
			
			if (GameLevel.gameEngine.playfield.playing) {
				
				var pauseLength:int = TimeStep.stepTime - pauseTime;
				startTime += pauseLength;
				console.hidePauseScreen();
				
				if (_currentLevel.levelNode.attributes["music"] && 
					_currentLevel.levelNode.attributes.music != "" && 
					SoundManager.hasSound) {
						
					Fuz2d.sounds.resumeSong();
					
				}
				
			} else {
				
				pauseTime = TimeStep.stepTime;
				console.showPauseScreen();
				
				if (_currentLevel.levelNode.attributes["music"] && 
					_currentLevel.levelNode.attributes.music != "" && 
					SoundManager.hasSound) {
					
					Fuz2d.sounds.pauseSong();
					
				}
				
			}
			
		}
		
		
		//
		//
		//
		public static function endGame (win:Boolean):void {
			
			ended = true;
			
			if (gameInstance) {
				if (gameInstance.currentLevel) gameInstance.currentLevel.stop();
				Main.mainStage.removeEventListener(Event.ENTER_FRAME, gameInstance.updateGame);
				if ( gameInstance.currentLevel.gameObjective.type == GameObjective.TYPE_NONE) return;
			}
			
			if (PlayTimeCounter.mainInstance != null) {
				endTime = PlayTimeCounter.mainInstance.secondsCounted * 1000;
			} else {
				endTime = TimeStep.stepTime - startTime;
			}
			
			if (win) {
				wonGame = true;
				sendEvent(2);
			} else {
				wonGame = false;
				sendEvent(3);
			}
			
			if (!testing) {
				
				if (gameInstance) gameInstance.sendGameResult(win);
				
			}
			
		}
		
        //
        //
        //
        public function sendGameResult (win:Boolean):void {

            if (s == null && User.s == null) return;
            
			if (!do_submit_score) {
				gameResultSubmitted = true;
				return;
			}
			
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.complete = true;
			
            var winParam:String = (win) ? "true" : "false";
            
            gameResultVars = new URLVariables();
			gameResultVars.w = winParam;
			gameResultVars.gtm = Math.max(1, Math.floor(endTime / 1000));
			
            if (s != null) {
				gameResultVars.pubkey = s;
            } else if (User.s != null) {
                gameResultVars.pubkey = User.s;
            }
			
            gameResultRequest = new URLRequest(Main.dataLoader.baseURL + "/php/gameresults.php?ax=" + SignString.sign(s + gameResultVars.w + gameResultVars.gtm));
			gameResultRequest.method = "POST";
			gameResultRequest.data = gameResultVars;
			
			gameResultLoader = new URLLoader();
			gameResultLoader.addEventListener(Event.COMPLETE, onGameResultSent);
			gameResultLoader.load(gameResultRequest);
			
			
			if (win && PlayTimeCounter.mainInstance != null)
			{
				if (PlayTimeCounter.timeLimit > 0 && PlayTimeCounter.mainInstance.secondsCounted <= PlayTimeCounter.timeLimit)
				{
					sendEvent(12);
				} 
				
			}
            
        }
		
		//
		//
		public function onGameResultSent (e:Event):void {
			gameResultSubmitted = true;
		}
		
		//
		//
		public static function sendEvent (eventCode:Number):void {
			
			if (!testing) {
				trace("sending event " + eventCode + " " + title);
				eventLC.send(eventLCName, "onReceive", { e: eventCode, g: title, s: s } );
			}
			
		}
		
		//
		//
		public static function onEventStatus (e:Event):void {
			
			
		}
		
		//
		//
		protected function onKeyPress (e:KeyboardEvent):void {
			
			switch (e.charCode) {
				
				case String("y").charCodeAt(0):
					//restartGame();
					break;
					
				case String("u").charCodeAt(0):
				
					//nextLevel();
					
					break;
				
				
			}
			
		}
		
		//
		//
		public function end ():void {
			
			if (_timer && _timer.running) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, loadNextLevel);
				_timer.stop();
			}
			
			if (GameLevel.player != null && GameLevel.player.controller != null) {
				GameLevel.player.controller.end();
			}
			
			if (console) console.end();
			
			if (gameInstance) {
				if (gameInstance.currentLevel) gameInstance.currentLevel.end();
				gameInstance = null;
			}
			
			Main.mainStage.removeEventListener(Event.ENTER_FRAME, updateGame);
			Main.mainStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);
			
			unloadAllReferences();
			
		}
		
	}

}