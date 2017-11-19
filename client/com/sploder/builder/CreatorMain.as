package com.sploder.builder {
	
	import com.sploder.data.*;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.StageQuality;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	
	import flash.utils.getQualifiedClassName;
	
	public class CreatorMain extends MovieClip {
		
		public static var mainStage:Stage;
		public static var global:Object;
		public static var preloader:CreatorPreloader;
		
		public static var dataLoader:DataLoader;
		
		public static var debugmode:Boolean = true;
		
		protected static var _creator:Creator;
		public static function get creator():Creator { return _creator; }
		
		protected static var _gameLoader:Loader;
		protected static var _testButton:SimpleButton;
		protected static var _previewing:Boolean = false;
		
		public static var mainInstance:CreatorMain;
		
		protected static var testDomain:ApplicationDomain;
		
		protected static var firstTest:Boolean = true;
		
		//
		//
		public function CreatorMain(stage:Stage, preloader:CreatorPreloader):void {
			
			init(stage, preloader);
			
		}
		
		
		//
		//
		protected function init (stage:Stage, preloader:CreatorPreloader):void {
			
			global = { };
			mainStage = stage;
			mainInstance = this;
			CreatorMain.preloader = preloader;
			
			dataLoader = new DataLoader(stage.root);
			
			testDomain = new ApplicationDomain();
			
			initializeData();
			
			CreatorMain.preloader.status = "Initializing Creator…";

		}
		
		
		//
		//
		public static function debug (reporter:Object, msg:String, errorType:String = "NOTICE"):void {
			
			if (debugmode) trace("(!) " + errorType + " from " + getQualifiedClassName(reporter) + ": " + msg);
			
		}
		
		//
		//
		protected function initializeData ():void {
			
			if (CreatorPreloader.url.length > 0) {
				
				if (CreatorPreloader.url.indexOf("file:///") != -1) {
				
					debug(this, "testing locally");
					//User.s = "mgh2uzkh";
					dataLoader.baseURL = "http://192.168.2.51/";

				} else if (CreatorPreloader.url.indexOf("http://sploder.home") != -1 || CreatorPreloader.url.indexOf("http://192.168.") != -1) {
				
					dataLoader.baseURL = "";
					
				}
				
			}
			
			trace("BASE URL:", dataLoader.baseURL);
			
			if (dataLoader.embedParameters.userid == null || dataLoader.embedParameters.userid == "demo") {
				
				User.u = 0;
				User.c = "0000000000";
				User.m = "temp";
				
			} else {
				
				User.u = parseInt(dataLoader.embedParameters.userid);
				User.c = String(dataLoader.embedParameters.creationdate);
				
			}
			
			preloader.status = "Initializing...";
			
			_creator = new Creator(this, this);
			_creator.addEventListener(Creator.INITIALIZED, onCreatorInit);
			
		}
		
		//
		//
		public static function loadGamePreview ():void {
		
			if (!_previewing) {
				
				User["done"] = false;
				
				if (_testButton == null) {
					_testButton = Creator.creatorlibrary.getDisplayObject("testbutton") as SimpleButton;
					_testButton.x = 73;
					_testButton.y = 25;
					_testButton.tabEnabled = false;
					_testButton.addEventListener(MouseEvent.CLICK, onTestButtonClicked)
				}
			
				_gameLoader = new Loader();
				_gameLoader.tabEnabled = false;
				_gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPreviewLoaded);
				_gameLoader.contentLoaderInfo.addEventListener(Event.INIT, onPreviewInit);
				var beta:String = (_creator.betaMode) ? "b" : "";
				beta = "";
				
				if (testDomain.hasDefinition("com.sploder.data.User")) {
					var testUser:Object = testDomain.getDefinition("com.sploder.data.User");
					testUser["data"] = User["data"];
				} else {
					_gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTestGameLoad);
				}
				
				if (_creator.project.version < 2) {
					_gameLoader.load(new URLRequest("fullgame2.swf?testing=true"), new LoaderContext(false, testDomain));
				} else {
					//_gameLoader.load(new URLRequest("fullgame2_b10.swf"), new LoaderContext(false, testDomain));
					_gameLoader.load(new URLRequest("fullgame2_b17.swf?testing=true"), new LoaderContext(false, testDomain));
				}
				
				_creator.testingMask.visible = true;
				_previewing = true;
				
			}
			
		}
		
		//
		//
		public static function onTestGameLoad (e:Event):void {
			MovieClip(e.target.content).addEventListener(Event.ENTER_FRAME, onTestStart);	
		}
		
		public static function onTestStart (e:Event):void {
			
			if (testDomain.hasDefinition("com.sploder.data.User")) {
				
				MovieClip(e.target).removeEventListener(Event.ENTER_FRAME, onTestStart);
				var testUser:Object = testDomain.getDefinition("com.sploder.data.User");
				testUser["data"] = User["data"];
				
				if (firstTest) {
					var testPreloader:Object = testDomain.getDefinition("Preloader");
					testPreloader.restart();
					firstTest = false;
				}
				
			} else {
				trace("class not found");
			}
			
		}
		
		//
		//
		public static function onCreatorInit (e:Event):void {
			
			preloader.done();
			mainStage.quality = StageQuality.HIGH;
	
		}
		
		//
		//
		public static function onPreviewInit (e:Event):void {
			
			trace("INIT");
			mainInstance.addChild(_gameLoader);
			mainInstance.addChild(_testButton);
			
			if (_creator.ui.parent != null) _creator.ui.parent.removeChild(_creator.ui);
			_creator.ui.visible = false;
	
		}
		
		//
		//
		public static function onPreviewLoaded (e:Event):void {
			
			trace("COMPLETE");

		}
		
		//
		//
		public static function unloadPreview ():void {
			
			if (_gameLoader != null) {
				if (testDomain.hasDefinition("Preloader")) {
					var pre:Object;
					try {
						pre = testDomain.getDefinition("Preloader");
						pre.mainInstance.game.fuz2d.end();
					} catch (e:Error) {
						try {
							pre = testDomain.getDefinition("Preloader");
							pre.mainInstance.game.currentLevel.fuz2d.end();
						} catch (e:Error) {
							trace("Unable to stop test game:", e.getStackTrace());
						}
					}
				}
				if (mainInstance.getChildIndex(_gameLoader) != -1) {
					mainInstance.removeChild(_gameLoader);
				}
				User["done"] = true;

				if (testDomain.hasDefinition("com.sploder.data.User")) {

					var testUser:Object = testDomain.getDefinition("com.sploder.data.User");
					testUser["data"] = User["data"];
					testUser["done"] = true;
					firstTest = true;
					
				}
				
				_gameLoader.unload();
				_gameLoader = null;
				
				testDomain = new ApplicationDomain();
				
			}
			trace("unloading preview");
			mainStage.quality = StageQuality.HIGH;
			
			Creator.resetStaticValues();
			
		}
		
		//
		//
		public static function onTestButtonClicked (e:MouseEvent):void {
			
			mainInstance.removeChild(_testButton);
			unloadPreview();
			_gameLoader = null;
			_creator.testingMask.visible = false;
			mainInstance.addChild(_creator.ui);
			_creator.ui.visible = true;
			_previewing = false;
			
		}
		

	}
	
}