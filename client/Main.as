package {
	
	import com.sploder.data.*;
	import com.sploder.util.PlayTimeCounter;
	import flash.display.Loader;
	import flash.net.URLRequest;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	
	import flash.utils.getQualifiedClassName;
	
	public class Main extends MovieClip {
		
		private var last_modified:String;
		
		public static var mainStage:Stage;
		public static var mainInstance:Main;
		public static var global:Object;
		public static var preloader:Preloader;
		
		public static var dataLoader:DataLoader;
		
		public static var debugmode:Boolean = true;
		public static var local:Boolean = false;
		
		protected var _game:Game;
		public function get game():Game { return _game; }
		public function set game(value:Game):void { _game = value; }
		
		public static var localContent:Boolean = false;
		
		protected var _originalBaseURL:String = "";
		
		//
		//
		public function Main(preloader:Preloader):void {
			
			Main.preloader = preloader;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			if (!Preloader.SFXLoaded) preloader.addEventListener(Preloader.SFX_LOADED, onSFXLoaded);
			if (!Preloader.SFX2Loaded) preloader.addEventListener(Preloader.SFX2_LOADED, onSFX2Loaded);
			
		}
		
		
		//
		//
		protected function init (e:Event = null):void {
			
			global = { };
			mainStage = preloader.stage;
			mainInstance = this;
			
			dataLoader = new DataLoader(stage.root);
			
			last_modified = "" + Math.floor(Math.random() * 100000);
			if (stage && stage.loaderInfo.parameters["modified"] != undefined) last_modified = stage.loaderInfo.parameters["modified"];
			
			Main.preloader.status = "Building game…";
			if (Preloader.testing) Main.preloader.status = "Testing game…";
			
			// TESTING
			if (Preloader.url.indexOf("file:///") != -1) {
			//User["data"] = '<project title="Simple%20Game" pubkey="" fast="0" isprivate="0" mode="2" author="geoff" date="Wednesday, June 5, 2013" id="proj3730014" comments="1" g="1" bitview="0"><levels id="levels"><level env="0,33cccc,666666,100" name="" music="">3,-150,-30|3,30,-30|3,-90,-30|3,-30,-30|3,90,30|3,90,-30|302,238,63|1,0,70</level></levels><graphics /></project>';
			//User["data"] = '<project title="Grenade%20Test" pubkey="" fast="0" isprivate="0" mode="2" author="geoff" date="Wednesday, June 5, 2013" id="proj3730014" comments="1" g="1" bitview="0"><levels id="levels"><level music="" env="5,336699,3300,100" name="">55,-270,30,0,0,0|3,90,330,0,0,0|3,-30,390,0,0,0|3,90,210,0,0,0|3,30,390,0,0,0|3,90,390,0,0,0|3,30,150,0,0,0|3,-30,150,0,0,0|3,-30,330,0,0,0|3,90,270,0,0,0|55,-330,30,0,0,0|3,-30,210,0,0,0|55,-210,30,0,0,0|55,-150,30,0,0,0|55,-90,30,0,0,0|55,-30,30,0,0,0|55,30,30,0,0,0|55,90,30,0,0,0|55,-390,30,0,0,0|3,90,150,0,0,0|302,165,67,0,0,0|1,26,242,0,0,0|155,60,360,0,0,0</level></levels></project>';
			}
			
			if (User["data"] != undefined && User["data"] != null) {
				
				debug(this, "Using embedded content...");
				localContent = true;
				
				_game = new Game(this, User["data"], this);
				if (Preloader.SFXLoaded) onSFXLoaded();
				if (Preloader.SFX2Loaded) onSFX2Loaded();
				
			} else {
				
				initializeData();
				
			}
			
		}
		
		
		//
		//
		public static function debug (reporter:Object, msg:String, errorType:String = "NOTICE"):void {
			
			if (debugmode) trace("(!) " + errorType + " from " + getQualifiedClassName(reporter) + ": " + msg);
			
		}
		
		//
		//
		protected function initializeData ():void {
			
			dataLoader.addEventListener(DataLoaderEvent.METADATA_ERROR, onDataError);
			
			if (Preloader.url.length > 0) {

				if (Preloader.url.indexOf("file:///") != -1) {
				
					debug(this, "testing locally");
					
					// TEMP
					//if (!Preloader.testing) User.s = "d0018txi"; // Laser Tag bug
					//if (!Preloader.testing) User.s = "d0018txe"; // Levels Testing
					//if (!Preloader.testing) User.s = "69pa3ajr"; // Shaolin Temple
					//if (!Preloader.testing) User.s = "gq0bg3rc"; // Transfer Station XKCD
					//if (!Preloader.testing) User.s = "d0019dwa"; // Pirate Adventure
					//if (!Preloader.testing) User.s = "xhrqnrtc"; // Genetic Lab Explosion
					//if (!Preloader.testing) User.s = "n08xf72k"; // Crumbling Pyramids
					//if (!Preloader.testing) User.s = "d0016gny"; // Local Testing
					//if (!Preloader.testing) User.s = "d0018txe"; // level testing local
					//if (!Preloader.testing) User.s = "d0018ty1"; // timer testing
					
					//if (!Preloader.testing) User.s = "d002gyvm"; // graphic test 1
					//if (!Preloader.testing) User.s = "d002gyvn"; // old stuff test 1
					//if (!Preloader.testing) User.s = "d002gyvo"; // graphics test 2
					//if (!Preloader.testing) User.s = "d002gyvq"; // data test 1
					//if (!Preloader.testing) User.s = "d002gyvs"; // raquzzic graphics test
					//if (!Preloader.testing) User.s = "d002xbm9"; // realm of fig by mat7772
					//if (!Preloader.testing) User.s = "d003kk9a"; // geoff bug test by gravitisy
					//if (!Preloader.testing) User.s = "d003kk5p"; // the device by ravicale
					//if (!Preloader.testing) User.s = "d003m7d6"; // dying bug
					//if (!Preloader.testing) User.s = "d003vsxr"; // avatar test
					if (!Preloader.testing) User.s = "d003xohb"; // avatar respawn test
					if (!Preloader.testing) User.s = "d003xoiy"; // levels and timer testing (sploder.home)
					
					dataLoader.baseURL = "http://sploder.home/";
					//dataLoader.baseURL = "http://www.sploder.com/";
					
					local = true;

				} else if (Preloader.url.indexOf("http://sploder.home") != -1 || Preloader.url.indexOf("http://192.168.") != -1) {
				
					dataLoader.baseURL = "";
					local = true;
					
				} else {
					
					dataLoader.baseURL = "http://www.sploder.com/";
					
				}
				
				if (Preloader.url.indexOf("clearspring_widget") != -1) {
					
					dataLoader.baseURL = "http://www.sploder.com/";
					
				}
				
				_originalBaseURL = dataLoader.baseURL;
				
			}
			
			var embed:Object = dataLoader.embedParameters;

			if (User.u > 0) {
				
				dataLoader.metadata.u = User.u;
				dataLoader.metadata.c = User.c;
				dataLoader.metadata.m = User.m;

				onMetadataLoaded();

			} else if (embed.s != null || User.s != null) {

				if (embed.s != undefined) User.s = embed.s;

				dataLoader.addEventListener(DataLoaderEvent.METADATA_LOADED, onMetadataLoaded);
				dataLoader.loadMetadata("/php/getgameprops.php?pubkey=" + User.s + "&modified=" + last_modified);
				
			} else if (Preloader.url.indexOf("clearspring") != -1) {

				User.s = Preloader.url.split("?s=")[1].split("&clear")[0];

				dataLoader.addEventListener(DataLoaderEvent.METADATA_LOADED, onMetadataLoaded);
				dataLoader.loadMetadata("/php/getgameprops.php?pubkey=" + User.s + "&modified=" + last_modified, true);

			} else {

				if (!Preloader.testing) {
					
					Preloader.instance.status = "Game not found.";
					
					var loader:Loader = new Loader();
					addChild(loader);
					loader.load(new URLRequest("gamelinks.swf"));
					
				}
				
			}
			
			if (embed.challenge != undefined && parseInt(embed.challenge) > 0) {
				PlayTimeCounter.showTime = true;
				if (embed.chtime != undefined && parseInt(embed.chtime) > 0) {
					PlayTimeCounter.timeLimit = parseInt(embed.chtime);
				}
			}
			
		}
		
		
		//
		//
		protected function onMetadataLoaded (e:DataLoaderEvent = null):void {
			
			dataLoader.removeEventListener(DataLoaderEvent.METADATA_LOADED, onMetadataLoaded);
			
			if (e != null) User.parseUserData(e.dataObject);
			
			dataLoader.addEventListener(DataLoaderEvent.DATA_LOADED, onDataLoaded);
			
			if (User.a == "1") {
				
				dataLoader.baseURL = "http://sploder.s3.amazonaws.com/";
				
				dataLoader.loadXMLData(User.projectpath + "game.xml?modified=" + last_modified);
				dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onDataArchiveError);
				
			} else {
		
				dataLoader.loadXMLData(User.projectpath + "game.xml?modified=" + last_modified);
				dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onDataError);
				
			}
			
		}
		
		//
		//
		protected function onDataLoaded (e:DataLoaderEvent = null):void {
			
			dataLoader.baseURL = _originalBaseURL;
			
			dataLoader.removeEventListener(DataLoaderEvent.DATA_LOADED, onDataLoaded);

			_game = new Game(this, e.dataObject, this);
			
			if (Preloader.SFXLoaded) onSFXLoaded();
			if (Preloader.SFX2Loaded) onSFX2Loaded();
			
		}
		
		//
		//
		protected function onDataArchiveError (e:DataLoaderEvent):void {

			dataLoader.removeEventListener(DataLoaderEvent.DATA_ERROR, onDataArchiveError);
			
			dataLoader.baseURL = _originalBaseURL;
			dataLoader.loadXMLData(User.projectpath + "game.xml");
			dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onDataError);
			
		}
		
		//
		//
		protected function onDataError (e:DataLoaderEvent):void {

			dataLoader.removeEventListener(DataLoaderEvent.DATA_ERROR, onDataError);

			Main.preloader.status = "Error Loading Game";
			
		}
		
		protected function onSFXLoaded (e:Event = null):void {	
			
			if (_game != null) {
				_game.createSFXLibrary(preloader.SFXClass);
			}
			
		}
		
		protected function onSFX2Loaded (e:Event = null):void {	
			
			if (_game != null) {
				_game.addSFX2toLibrary(preloader.SFX2Class);
			}
			
		}

	}
	
}