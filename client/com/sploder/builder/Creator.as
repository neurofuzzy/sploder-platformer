package com.sploder.builder {

	import com.sploder.builder.ui.DialogueMusicManager;
	import com.sploder.builder.ui.PanelLevelName;
	import com.sploder.data.*;
	import com.sploder.Settings;
	import com.sploder.SignString;
	import com.sploder.builder.ui.PanelGraphics;
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.texturegen_internal.TextureRendering;
	import com.sploder.texturegen_internal.util.ThreadedQueue;
	import com.sploder.asui.BButton;
	import com.sploder.asui.Cell;
	import com.sploder.asui.ClipButton;
	import com.sploder.asui.ComboBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.Create;
	import com.sploder.asui.Divider;
	import com.sploder.asui.HRule;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import com.sploder.asui.Tagtip;
	import flash.display.SimpleButton;
	import flash.text.Font;
	import flash.text.TextField;
	import fuz2d.util.Stats;
	import fuz2d.util.TileDefinition;

	import com.sploder.asui.Library;
	
	import com.sploder.util.StringUtils;
	import com.sploder.builder.CreatorFactory;
	import fuz2d.library.EmbeddedLibrary;
	import fuz2d.util.Key;

	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.xml.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Creator extends EventDispatcher {
		
		public static const INITIALIZED:String = "creator_initialized";
		public static const GAME_VERSION:String = "2";
		
		protected var _main:CreatorMain;
		protected var _container:Sprite;
		protected var _ui:Sprite;
		public function get ui():Sprite { return _ui; }
		public var uiContainer:Cell;
		
		protected static var _mainInstance:Creator;
		public static function get mainInstance():Creator { return _mainInstance; }
		
		protected var _solBucketName:String = "creator" + GAME_VERSION;
		
		protected var _levelSelector:ComboBox;
		public function get levelSelector():ComboBox { return _levelSelector; }
		
		protected var _addLevelButton:BButton;
		public function get addLevelButton():BButton { return _addLevelButton; }
		
		protected var _removeLevelButton:BButton;
		public function get removeLevelButton():BButton { return _removeLevelButton; }
		
		protected var _moveLevelButton:BButton;
		public function get moveLevelButton():BButton { return _moveLevelButton; }
		
		protected var _copyLevelButton:BButton;
		public function get copyLevelButton():BButton { return _copyLevelButton; }
		
		private var _nameLevelButton:BButton;
		public function get nameLevelButton():BButton { return _nameLevelButton; }
		
		protected var _musicButton:BButton;
		public function get musicButton():BButton { return _musicButton; }

		[Embed(source = "../../../assets/font_myriad.swf", mimeType="application/octet-stream")]
		protected var FontLibrarySWF:Class;
		public static var fontLibrary:Library;

		[Embed(source = "../../../assets/creator.swf", mimeType="application/octet-stream")]
		protected var CreatorSWF:Class;
		public static var UIlibrary:Library;
		
		[Embed(source = "../../../assets/TextureGen.swf", mimeType="application/octet-stream")]
		public var TextureGenSWF:Class;
		//public static var UIlibrary:Library;
		
		[Embed(source = "../../../assets/library.swf", mimeType="application/octet-stream")]
		protected var CreatorLibrarySWF:Class;

		public static var creatorlibrary:EmbeddedLibrary;
		
		[Embed(source = "../../../assets/library_definitions.xml", mimeType = "application/octet-stream")]
		protected var definitions:Class;
		
		public var gameMode:Number;
        
        public static var playfield:CreatorPlayfield;
        public static var navigator:CreatorNavigator;
		public static var levels:CreatorLevels;
		public static var environment:CreatorEnvDialogue;
		public var graphics:CreatorGraphics;
		
        public var deleteControl:MovieClip;
		
		public var ddtexture:CreatorTextureDialogue;
		public var ddtexturegen:CreatorTextureGenDialogue;
		public var ddgamedemo:CreatorDialogue;
		public var ddavatar:CreatorAvatarDialogue;
		public var ddlocalstorage:CreatorDialogue;
		public var ddlocalstorageShown:Boolean;
		public var ddoldgame:CreatorDialogue;
		public var ddalert:CreatorDialogue;
        public var ddconfirm:CreatorDialogue;
		public var ddprogress:CreatorDialogue;
        public var ddserver:CreatorDialogue;
		public var ddservercomplete:CreatorDialogue;
		public var ddserverpublished:CreatorDialogue;
		public var ddembedcode:CreatorDialogue;
        public var ddmanager:CreatorManager;
        public var ddpublish:CreatorDialogue;
		public var ddtextentry:CreatorDialogue;
        public var ddenvironment:CreatorEnvDialogue;
		public var ddMusic:DialogueMusicManager;
		public var ddGraphics:PanelGraphics;
		public var ddLevelName:PanelLevelName;
		public var graphicsPanelToggle:ClipButton;
		
        public var ddsessionexpire:CreatorDialogue;
        public var ddsavereminder:CreatorDialogue;
		public var ddjoin:CreatorDialogue;
		
		public var menu:CreatorMenu;
		public var buttons:CreatorButtons;
		public var objTray:CreatorObjectTray;
		public var objGhost:CreatorObjectGhost;
		
		public var testingMask:Sprite;
		public var demo:Boolean = false;
		
		public var selectionPrompt:TextField;
		
        protected var _project:CreatorProject;
		public function get project():CreatorProject { return _project; }
		
        public var resultXML:XML;
		
		public static var projectToLoad:String;
        
        public var todaysdate:Date;
        public var activedate:Date;
        public var today:String;
        public var todaycgi:String;
        public var activeday:String;
        public var activedaycgi:String;
		
        public var sessionExpired:Boolean = false;
        public var keepTimer:Timer;
        public var keepLoader:URLLoader;
        
        //
        //    Property: debugmode
        //    Set to true to receive debug information
        private var debugmode:Boolean = true;
		
		
		
		public var betaMode:Boolean = false;
		
		//
		//
		public function Creator (main:CreatorMain, container:Sprite = null) {

			init(main, container);
			
		}
		
		//
		//
		protected function init (main:CreatorMain, container:Sprite = null):void {
			
			_main = main;
			
			_container = container;
			
			_mainInstance = this;
			
			Component.mainStage = TextureRendering.mainStage = ThreadedQueue.mainStage = CreatorMain.mainStage;
			
			Styles.initialize();
			
			if (CreatorMain.dataLoader.baseURL.indexOf("http://sploder.home") == 0) betaMode = false;
			
			Key.initialize(CreatorMain.mainStage);
			
			_project = new CreatorProject(this, "/php/saveproject" + GAME_VERSION + ".php", "version=" + GAME_VERSION, "/php/savegamedata" + GAME_VERSION + ".php");
			
			initializeFontLibrary(FontLibrarySWF);
			
				
            gameMode = 2;

			if (CreatorMain.dataLoader.embedParameters.userid == undefined || 
				CreatorMain.dataLoader.embedParameters.userid == "demo") demo = true;
			
			if (demo) {
				 User.u = 1;
				 if (CreatorMain.dataLoader.embedParameters.creationdate != undefined) {
					 User.c = String(CreatorMain.dataLoader.embedParameters.creationdate);
				 } else {
					 User.c = "20061226154248";
				 }
			} else {
				User.u = parseInt(CreatorMain.dataLoader.embedParameters.userid);
				User.name = String(CreatorMain.dataLoader.embedParameters.username);
				_project.author = User.name;
				User.c = String(CreatorMain.dataLoader.embedParameters.creationdate);
			}
			     
            // 
            // 
            todaysdate = new Date();
            activedate = new Date();
            today = StringUtils.prettydatestring(todaysdate);
            todaycgi = StringUtils.cgidatestring(todaysdate);
            activeday = StringUtils.prettydatestring(todaysdate);
            activedaycgi = StringUtils.cgidatestring(todaysdate);
			   
            if (!demo) {
                keepTimer = new Timer(120000, 0);
				keepTimer.addEventListener(TimerEvent.TIMER, keepAlive);
				keepTimer.start();
            }

			CreatorMain.dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onServerError);
			CreatorMain.dataLoader.addEventListener(DataLoaderEvent.METADATA_ERROR, onServerError);
				
		}
		
		//
		//
		public function initializeFontLibrary (LibrarySWF:Class):void {
			
			if (fontLibrary == null) {
				
				fontLibrary = new Library(FontLibrarySWF, true);	
				fontLibrary.addEventListener(Event.INIT, onFontLibraryInitialized);		
					
			} else {
				
				initializeUILibrary(CreatorSWF);
				initializeLibrary(CreatorLibrarySWF);
				
			}
			
		}
		
		//
		//
		protected function onFontLibraryInitialized (e:Event):void {
			
			fontLibrary.removeEventListener(Event.INIT, onFontLibraryInitialized);
			
			initializeFonts(fontLibrary);
			
			initializeUILibrary(CreatorSWF);
			
		}
		
		//
		//
		public function initializeFonts (library:Library):void {
			
			var font:Class;
			font = library.getFont("myriad");
			Font.registerFont(font);
			font = library.getFont("myriad_bold");
			Font.registerFont(font);
			
		}
		
		//
		//
		public function initializeUILibrary (LibrarySWF:Class):void {
			
			if (UIlibrary == null) {
				
				UIlibrary = new Library(LibrarySWF, true);	
				UIlibrary.addEventListener(Event.INIT, onUILibraryInitialized);		
				
			}
			
		}
		
		//
		//
		protected function onUILibraryInitialized (e:Event):void {
			
			UIlibrary.removeEventListener(Event.INIT, onUILibraryInitialized);
			
			Component.library = UIlibrary;
			
			initializeLibrary(CreatorLibrarySWF);
			
		}
		
		//
		//
		public function initializeLibrary (LibrarySWF:Class):void {
			
			if (creatorlibrary == null) {
				
				creatorlibrary = new EmbeddedLibrary(LibrarySWF, true);
				creatorlibrary.smoothing = true;
				creatorlibrary.addEventListener(Event.INIT, onCreatorLibraryInitialized);		
				
			}
			
		}
		
		//
		//
		protected function onCreatorLibraryInitialized (e:Event):void {
			
			creatorlibrary.removeEventListener(Event.INIT, onCreatorLibraryInitialized);
			
			CreatorFactory.initialize(this, CreatorFactory.getEmbeddedString(definitions), creatorlibrary);

			dispatchEvent(new Event(INITIALIZED));
			
			buildUI();
			
		}
		
		//
		//
		protected function buildUI ():void {
			
			_ui = UIlibrary.getDisplayObject("ui") as Sprite;
			
			var c:Sprite = _ui["buttons"];

			var cc:Cell = new Cell(c, 683, 36);
			cc.x = 160;
			cc.y = 46;	
			
			var ccp:Position = new Position( { margin_right: 8, margin_top: 2 } , -1, Position.PLACEMENT_FLOAT);
			var ccp2:Position = new Position( { margin_right: 1 } , -1, Position.PLACEMENT_FLOAT);
			var ccp3:Position = new Position( { margin_top: -3 } , -1, Position.PLACEMENT_FLOAT_RIGHT);

			
			var ccs:Style = new Style( { border: 0 } );
			
			ccs.font = "Myriad Web";
			ccs.titleFont = "Myriad Web Bold";
			ccs.buttonFont = "Myriad Web Bold";
			ccs.embedFonts = true;
			ccs.fontSize = ccs.buttonFontSize = 11;
			ccs.buttonTextColor = 0xcccccc;
			
			var ccs2:Style = new Style();
			ccs2.fontSize = 10;
			ccs2.buttonFontSize = 10;

			var ccs3:Style = new Style();
			ccs3.borderWidth = 2;
			
				
			var drawPropsStyle:Style = new Style( {
				border: 0,
				selectedButtonColor: 0x003399,
				padding: 0,
				buttonColor: 0x000000,
				unselectedColor: 0x333333,
				backgroundColor: 0x555555,
				borderColor: 0xffffff,
				inactiveColor: 0x111111,
				round: 4
				} );

			_levelSelector = new ComboBox(null, "Level", ["Level 1"], 0, "Level", 120, ccp2, ccs2);
			cc.addChild(_levelSelector);
			
			var dv:Divider = new Divider(null, 1, 20, true, ccp, ccs3);
			cc.addChild(dv);
			
			_addLevelButton = new BButton(null, Create.ICON_PLUS, -1, 19, 19, false, false, false, ccp, ccs);
			_addLevelButton.alt = "Click to add a level to your game";
			cc.addChild(_addLevelButton);
			
			_removeLevelButton = new BButton(null, Create.ICON_MINUS, -1, 19, 19, false, false, false, ccp, ccs);
			_removeLevelButton.alt = "Click to remove this level from your game";
			cc.addChild(_removeLevelButton);
			_removeLevelButton.disable();
			
			_moveLevelButton = new BButton(null, Create.ICON_ARROW_UP, -1, 19, 19, false, false, false, ccp, ccs);
			_moveLevelButton.alt = "Click to move this level up so it plays before the previous level";
			cc.addChild(_moveLevelButton);
			_moveLevelButton.disable();
			
			var ccs4:Style = ccs.clone( { padding: 0 } );
			
			_copyLevelButton = new BButton(null, Create.ICON_COPY, -1, 19, 19, false, false, false, ccp, ccs4);
			_copyLevelButton.alt = "Click to copy this level to a new level";
			cc.addChild(_copyLevelButton);
			
			_nameLevelButton = new BButton(null, Create.ICON_EDIT, -1, 19, 19, false, false, false, ccp, ccs);
			_nameLevelButton.alt = "Click to edit the name of this level";
			cc.addChild(_nameLevelButton);
			
			_musicButton = new BButton(null, "Music", -1, 60, 19, false, false, false, ccp, ccs);
			_musicButton.alt = "Click to add music to this level";
			cc.addChild(_musicButton);
			_musicButton.disable();
			
			graphicsPanelToggle = new ClipButton(null, 
				"icon_graphics_panel", 
				"icon_graphics_panel", 
				1, 30, 30, 10, false, false, false, false,
				ccp3,
				drawPropsStyle
				);
				
			graphicsPanelToggle.name = "icon_graphics_panel";
			graphicsPanelToggle.alt = "Click to show graphics panel";
			graphicsPanelToggle.toggledAlt = "Click to hide graphics panel";
			cc.addChild(graphicsPanelToggle);
			
			var ccg:Cell = new Cell(_ui, _container.stage.stageWidth, 47, false, false, 0, Styles.floatPosition);
			ccg.x = 160;
			
			// GRAPHICS PANEL
			
			ddGraphics = new PanelGraphics(this);
			ddGraphics.create(ccg);
			
			ddLevelName = new PanelLevelName(this);
			ddLevelName.create(cc);
			
			if (_ui != null) {
				
				_container.addChild(_ui);
				rigUI();
				
			}
			
			/*
			if (_container.root.loaderInfo.url.indexOf("sploder.com") == -1) {
				var stats:Stats = new Stats();
				_container.addChild(stats);
			}
			*/
		}
		
		//
		//
		protected function rigUI ():void {
			
			Component.library = UIlibrary;
			
			ddgamedemo = new CreatorDialogue(this, _ui["dddemo"]);
			ddavatar = new CreatorAvatarDialogue(this, _ui["ddavatars"]);
			ddlocalstorage = new CreatorDialogue(this, _ui["ddlocalstorage"]);
			ddoldgame = new CreatorDialogue(this, _ui["ddoldgame"]);
			ddtexture = new CreatorTextureDialogue(this, _ui["ddtexture"]);
			ddtexturegen = new CreatorTextureGenDialogue(this, _ui["ddtexturegen"]);
			ddalert = new CreatorDialogue(this, _ui["ddalert"]);
			ddconfirm = new CreatorDialogue(this, _ui["ddconfirm"]);
			ddprogress = new CreatorDialogue(this, _ui["ddprogress"]);
			ddserver = new CreatorDialogue(this, _ui["ddserver"]);
			ddservercomplete = new CreatorDialogue(this, _ui["ddservercomplete"]);
			ddserverpublished = new CreatorDialogue(this, _ui["ddserverpublished"]);
			ddembedcode = new CreatorDialogue(this, _ui["ddembedcode"]);
			ddpublish = new CreatorDialogue(this, _ui["ddpublish"]);
			ddtextentry = new CreatorDialogue(this, _ui["ddtextentry"]);
			ddsessionexpire = new CreatorDialogue(this, _ui["ddsessionexpire"]);
			ddsavereminder = new CreatorDialogue(this, _ui["ddsavereminder"]);
			ddjoin = new CreatorDialogue(this, _ui["ddjoin"]);

			ddmanager = new CreatorManager(this, _ui["ddmanager"], "/php/getprojects.php", "version=" + GAME_VERSION);
			
			menu = new CreatorMenu(this, _ui["menu"]);
			menu.saveEnabled = menu.saveAsEnabled = menu.publishEnabled = (!demo);
			menu.publishEnabled = (!betaMode);
			
			buttons = new CreatorButtons(this, _ui["buttons"]);
			
			testingMask = _ui["testingmask"];
			testingMask.visible = false;
			
			CreatorHelp.textfield = _ui["prompt"];
			CreatorHelp.textfield.mouseEnabled = false;
			
			objGhost = new CreatorObjectGhost(this, _ui["ghost"]);
			objTray = new CreatorObjectTray(this, _ui["objtray"]);
			
			playfield = new CreatorPlayfield(this, _ui["zoomer"]["playfield"]);
			navigator = new CreatorNavigator(this, _ui["zoomer"], playfield, _ui["playmask"]);
			levels = new CreatorLevels(this);
			graphics = new CreatorGraphics();
			
			playfield.init();
			
			buttons.setSelectionListeners();
			buttons.setNavMode(CreatorButtons.MODE_PAN);
			
			levels.reset();
			
			ddenvironment = new CreatorEnvDialogue(this, _ui["ddenvironment"]);
			environment = ddenvironment;
			
			uiContainer = new Cell(ui, 860, 540);
			
			ddMusic = new DialogueMusicManager(this, 330, 480, "Add Music", ["Cancel", "Remove Music", "Select Music"]);
			ddMusic.create();
			
			ddMusic.listURL = "/music/modules/index.m3u";
			ddMusic.listParamString = "";
			
			_musicButton.addEventListener(Component.EVENT_CLICK, onMusicButtonClicked);
			
			graphicsPanelToggle.addEventListener(Component.EVENT_CLICK, onGraphicsPanelToggleClicked);
			ddGraphics.connect();
			
			_nameLevelButton.addEventListener(Component.EVENT_CLICK, onLevelNameButtonClicked);
			
			Tagtip.initialize(CreatorMain.mainStage);
			
			Settings.bucketName = String(_solBucketName + "_" + User.u);
			
			var demoXML:String;
			
			if (demo) {
				
				if (project.hasLocalProject) {
					
					demoXML = Settings.loadSetting(project.sharedObjectName) as String;
					
					if (demoXML.indexOf("geoff") == -1) {
						project.confirmLoadLocalProject();
					} else {
						project.newProject();
						ddgamedemo.show();
					}
					
				} else {	
					
					project.newProject();
					ddgamedemo.show();	
					
				}
				
			} else {
				
				if (!project.hasLocalProject) {
					
					Settings.bucketName = String(_solBucketName + "_1");

					if (project.hasLocalProject) {
						
						demoXML = Settings.loadSetting(project.sharedObjectName) as String;
						
						Settings.saveSetting(project.sharedObjectName, "");
						Settings.bucketName = String(_solBucketName + "_" + User.u);
						
						if (demoXML.indexOf("geoff") == -1) {
							Settings.saveSetting(project.sharedObjectName, demoXML);
						}

					} else {
						
						Settings.bucketName = String(_solBucketName + "_" + User.u);
						
					}
				
				}
				
				if (project.hasLocalProject) {
					project.confirmLoadLocalProject();
				} else {
					project.newProject();
				}

			}
			
			if (Settings.dispatcher != null) Settings.dispatcher.addEventListener(Settings.EVENT_ERROR, onSharedObjectError);
			
		}
		
		
		//
		//
		protected function onServerError (e:DataLoaderEvent):void {
			
			ddalert.show("There was an error communicating with the server.");
			ddserver.hide();
			ddmanager.hide();
			ddconfirm.hide();
			
		}
		
		//
		//
		protected function onSharedObjectError (e:Event):void
		{
			if (!ddlocalstorageShown)
			{
				ddlocalstorage.show();
				ddlocalstorageShown = true;
			}
		}
		
		//
		//
		protected function onMusicButtonClicked (e:Event):void {
			ddMusic.show();
		}
		
		//
		//
		protected function onLevelNameButtonClicked (e:Event):void {
			ddLevelName.show();
		}
		
		//
		//
		protected function onGraphicsPanelToggleClicked (e:Event):void {
			if (graphicsPanelToggle.toggled) ddGraphics.show();
			else ddGraphics.hide();
		}
		
        // 
        // 
        // RESETACTIVEDATE sets the active date to today
        public function resetactivedate():void {
            
            activedate = new Date();
            activeday = today;
            activedaycgi = todaycgi;
            
        }	
		
       /*    ----------------------------------------------------------
        *   Creator Functions
        *    ---------------------------------------------------------- */
            
        //
        //
        // SETGAMEMODE changes the game mode
        public function setGameMode (mode:Number):void {

            gameMode = (!isNaN(mode)) ? mode : gameMode;
            if (gameMode != 2) gameMode = 2;
    
        }

		
        //
        //
        //
        public function showTextureExplorer ():void {

			ddtexture.show();
            
        }
		
		//
        //
        //
        public function showTextureGenerator (attribs:TextureAttributes, tileBack:Boolean = false):void {

			ddtexturegen.attribs = attribs;
			ddtexturegen.tileBack = tileBack;
			ddtexturegen.show();
			
            
        }
		
        //
        //
        // KEEPALIVE pings the server to keept he session alive
        public function keepAlive (e:TimerEvent):void {
             
			keepLoader = new URLLoader();
			keepLoader.addEventListener(Event.COMPLETE, checkAlive);
			keepLoader.load(new URLRequest("php/keepalive.php" + CreatorMain.dataLoader.getCacheString()));
			
        }
    
        
        //
        //
        // CHECKALIVE checks to see if the session is still alive
        public function checkAlive (e:Event):void {

			// trace(e.target.data);
			
			if (e.target.data != "keepalive=1") {
				
				ddsessionexpire.show();
				project.saveLocalProject();
				sessionExpired = true;
				
			} else {
				
				ddsessionexpire.hide();
				
				if (sessionExpired == true) {
					sessionExpired = false;
				}
				
			}
            
        }
		
		//
		//
		public static function resetStaticValues ():void {
			
			TileDefinition.ambientColor = 0x000000;
		
			TileDefinition.grid_width = 60;
			TileDefinition.grid_height = 60;
			TileDefinition.scale = 1;	
			
			EmbeddedLibrary.grid_width = 60;
			EmbeddedLibrary.grid_height = 60;
			EmbeddedLibrary.scale = 1;
			
		}
		
		//
		//
		public function cleanBitmapData ():void {
			
			var protectedTiles:Array = [];
			for each (var adder:CreatorObjectAdder in objTray.adders) {
				if (adder.isTile) protectedTiles.push(adder.tileID);
			}
			for each (var obj:CreatorPlayfieldObject in playfield.objects) {
				if (obj.tile) protectedTiles.push(obj.tileID);
			}
			
			EmbeddedLibrary.purge(protectedTiles);			
			
		}

	}
	
}