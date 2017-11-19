package com.sploder.builder 
{
	
	import com.adobe.images.PNGEncoder;
	import com.sploder.data.User;
	import com.sploder.Settings;
	import com.sploder.asui.ColorTools;
	import com.sploder.util.Base64;
	import com.sploder.util.Cleanser;
	import com.sploder.util.Textures;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorProject extends EventDispatcher {
		private var loadTimer:Timer;
		
		public static const EVENT_LOAD:String = "load";
		public static const EVENT_SAVE:String = "save";
		public static const EVENT_NEW:String = "new";
		public static const EVENT_TEST:String = "test";
		public static const NO_ID:String = "noid-unsaved-project";
		public static const NO_TITLE:String = "";
		
		protected var _creator:Creator;
		
		protected var _xml:XMLDocument;
		public function get xml():XMLDocument { return _xml; }
		public function set xml(value:XMLDocument):void { _xml = value;	}
		
		protected var _sharedObjectName:String = "creator2temp";
		public function get sharedObjectName():String { return _sharedObjectName; }

        public var previewWidth:Number = 480;
        public var previewHeight:Number = 360;
        public var isprivate:String;
        public var comments:String;
		public var fast:String;
		public var bitview:String;
        public var pubkey:String;

		public var title:String = NO_TITLE;
		public var author:String = "";
		public var projID:String = NO_ID;
		public var pubDate:Date;
		
		public var saved:Boolean = false;
		
		protected var _version:int = 3;
		public function get version():int { return _version; }
		
        public var gameXML:XMLDocument;
		
		protected var _newXMLString:String = '<project title="" g="1"><levels id="levels"><level></level></levels><graphics></graphics><textures lastid="0"></textures></project>';
		protected var _newOldXMLString:String = '<project title="" g="1"><env bkgd="1" fast="0" bitview="0" bgcolor="#003366" gdcolor="#333333" ambcolor="1"></env><objects>1,0,70,0</objects></project>';
		protected var _prevXMLString:String = "";
		
		
		protected var _saveURL:String = "";
		protected var _saveParams:String = "";
		protected var _publishURL:String = "";
		
		protected var _projectVars:URLVariables;
		protected var _projectRequest:URLRequest;
		protected var _projectSaver:URLLoader;
		
		protected var _gameVars:URLVariables;
		protected var _gameRequest:URLRequest;
		protected var _gameSaver:URLLoader;
		
		protected var _bigThumb:ByteArray;
		protected var _smallThumb:ByteArray;
		protected var _bigThumbRequest:URLRequest;
		protected var _smallThumbRequest:URLRequest;
		protected var _bigThumbSaver:URLLoader;
		protected var _smallThumbSaver:URLLoader;
		
		protected var _getProjectURL:String = "/php/getproject.php";
		protected var _thumbPostURL:String = "/php/savethumb.php";
		
		protected var _localSaveTimer:Timer;
		
		protected var _transferring:Boolean = false;
		
		public function get hasGraphics ():Boolean {
			return (_xml != null && _xml.firstChild.attributes.g == "1");
		}
		
		//
		//
		public function CreatorProject(creator:Creator, saveURL:String, saveParams:String = "", publishURL:String = "") {
			
			init(creator, saveURL, saveParams, publishURL);
			
		}
		
		//
		//
		protected function init (creator:Creator, saveURL:String, saveParams:String = "", publishURL:String = ""):void {
			
			_creator = creator;
			_saveURL = saveURL;
			_saveParams = saveParams;
			_publishURL = publishURL;
			
			projID = NO_ID;
			title = NO_TITLE;
			if (User.name != "") author = User.name;
			
			_sharedObjectName = "creator" + Creator.GAME_VERSION + "temp";
			
			_localSaveTimer = new Timer(10000, 0);
			_localSaveTimer.addEventListener(TimerEvent.TIMER, saveLocalProject);
			_localSaveTimer.start();
			
			
		}
		
		//
		//
		public function onManagerConfirm (e:Event):void {
			
			trace("MANAGER CONFIRM");
			
			if (_creator.ddmanager.mode == CreatorManager.MODE_LOAD) {
				
				loadProject();
				
			} else if (_creator.ddmanager.mode == CreatorManager.MODE_SAVE) {
				
				projID = NO_ID;
				
				title = unescape(_creator.ddmanager.currentProjectTitle);
				title = Cleanser.cleanse(title);
				if (title.length == 0) title = "My New Game";
				
				saveProject();
				
			}

		}
		
        //
        //
        //
        public function getObjects (level:uint = 0):String {
            
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					var objectsNode:XMLNode = _xml.idMap["levels"].childNodes[level];  
					return objectsNode.firstChild.nodeValue;
				
				}
			
			}
			
			return "";
            
        }
		
 		//
        //
        //
        public function getEnvironment (level:uint = 0):String {
            
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					var objectsNode:XMLNode = _xml.idMap["levels"].childNodes[level];  
					if (objectsNode != null && objectsNode.attributes["env"] != null) return objectsNode.attributes["env"];
				
				}
			
			}
			
			return "";
            
        }
		
//
        //
        //
        public function getMusic (level:uint = 0):String {
            
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					var objectsNode:XMLNode = _xml.idMap["levels"].childNodes[level];  
					if (objectsNode != null && objectsNode.attributes["music"] != null) return objectsNode.attributes["music"];
				
				}
			
			}
			
			return "";
            
        }
		
		//
        //
        public function getAvatar (level:uint = 0):int {
            
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					var objectsNode:XMLNode = _xml.idMap["levels"].childNodes[level];  
					if (objectsNode != null && objectsNode.attributes["avatar"] != null) return parseInt(objectsNode.attributes["avatar"]);
				
				}
			
			}
			
			return 0;
            
        }
		
		//
        //
        //
        public function getLevelName (level:uint = 0):String {
            
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					var objectsNode:XMLNode = _xml.idMap["levels"].childNodes[level];  
					if (objectsNode != null && objectsNode.attributes["name"] != null) return unescape(unescape(objectsNode.attributes["name"]));
				
				}
			
			}
			
			return "";
            
        }

		//
		//
		public function getTotalLevels ():uint {
			
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				return _xml.idMap["levels"].childNodes.length;
				
			}
				
			return 0;
			
		}
		
		
        //
        //
        // BUILD BLANK PROJECT XML
        public function newDocument ():void {

            _xml = new XMLDocument(_newXMLString);
			pubkey = "";
			projID = NO_ID;
			title = NO_TITLE;
			comments = "1";
			isprivate = "0";
			fast = "0";
			bitview = "0";
			
			_version = 2;
			
			if (_creator.ddpublish != null) _creator.ddpublish.updateSettings();
			if (_creator.ddenvironment != null) _creator.ddenvironment.updateSettings();
			
			clearLocalProject();
			
		}
        
        //
        //
        //
        public function buildDocument (currentLevelOnly:Boolean = false, addGraphics:Boolean = false):void {
			
			Creator.levels.saveCurrentLevel();
			Creator.levels.saveCurrentEnvironment();
			
			var levelsNodes:String = "";
			
			var objectsNode:XMLNode;
			
			if (!currentLevelOnly) {
				
				for (var i:int = 0; i < Creator.levels.totalLevels; i++) {
					
					objectsNode = _xml.idMap["levels"].childNodes[i];
					levelsNodes += "<level name=\"" + escape(escape(Creator.levels.exportLevelName(i))) + "\" env=\"" + Creator.levels.exportEnvironmentData(i) + "\" music=\"" + Creator.levels.exportMusicData(i) + "\" avatar=\"" + Creator.levels.exportAvatarData(i) + "\">" + Creator.levels.exportLevelData(i) + "</level>";
				
				}
			
			} else {
				
				objectsNode = _xml.idMap["levels"].childNodes[Creator.levels.currentLevel];
				levelsNodes += "<level env=\"" + Creator.levels.exportEnvironmentData(Creator.levels.currentLevel) + "\" music=\"" + Creator.levels.exportMusicData(Creator.levels.currentLevel) + "\" avatar=\"" + Creator.levels.exportAvatarData(i) + "\">" + Creator.levels.exportLevelData(Creator.levels.currentLevel) + "</level>";
				
			}
			
			var template:String = _newXMLString;
			template = template.split("<level></level>").join(levelsNodes);
			
			// add graphics
			
			if (_version > 1 && addGraphics) {
				var graphics:Object = Creator.levels.exportGraphics();
				var graphicsNodes:String = "";
				for (var name:String in graphics) {
					var newGraphicsNode:String = "";
					try {
						if (graphics[name] is BitmapData && BitmapData(graphics[name]).width > 0 && BitmapData(graphics[name]).height > 0) {	
							var png:ByteArray = PNGEncoder.encode(BitmapData(graphics[name]));
							if (png is ByteArray) {
								var bString:String = Base64.encodeByteArray(png);
								if (Textures.getRectsFor(name))
								{
									var rects_obj:Object = Textures.getRectsFor(name);
									var rects_array:Array = [];
									
									for (var key:String in rects_obj)
									{
										if (rects_obj[key] is Rectangle)
										{
											var r:Rectangle = rects_obj[key];
											rects_array.push(key + ":" + Math.floor(r.x) + "," + Math.floor(r.y) + "," + Math.floor(r.width) + "," + Math.floor(r.height));
										}
									}
									
									newGraphicsNode = "<graphic rects=\"" + rects_array.join(";") + "\" name=\"" + name + "\">" + bString + "</graphic>";
								} else {
									newGraphicsNode = "<graphic name=\"" + name + "\">" + bString + "</graphic>";
								}
							}
						}
					} catch (e:Error) {
						if (e.errorID == 2015) {
							newGraphicsNode = "";
						}
					}
					graphicsNodes += newGraphicsNode;
				}
				template = template.split("<graphics></graphics>").join("<graphics>" + graphicsNodes + "</graphics>");
			}
			
			_xml = new XMLDocument(template);
			
			if (projID != null && projID.length > 0) _xml.firstChild.attributes.id = projID;
			else projID = NO_ID;
			
			_xml.firstChild.attributes.pubkey = pubkey;
			
			_xml.firstChild.attributes.title = escape(title);
			if (author != null && author.length > 0) _xml.firstChild.attributes.author = author;
			else _xml.firstChild.attributes.author = "demo";
			
            _xml.firstChild.attributes.mode = _creator.gameMode;
			_xml.firstChild.attributes.date = _creator.today;
			_xml.firstChild.attributes.comments = comments;
			_xml.firstChild.attributes.isprivate = isprivate;
			_xml.firstChild.attributes.fast = fast;
			_xml.firstChild.attributes.bitview = bitview;
        }
		
		//
		//
		//
		protected function convertOldXMLToNew ():void {
			
			// metadata
			//
			
			var id:String = _xml.firstChild.attributes.id;
			var pubkey:String = _xml.firstChild.attributes.pubkey;	
			var title:String = _xml.firstChild.attributes.title;
			var author:String = _xml.firstChild.attributes.author;
			
            var mode:String = _xml.firstChild.attributes.mode;
			var date:String = _xml.firstChild.attributes.date;
			var comments:String = _xml.firstChild.attributes.comments;
			var isprivate:String = _xml.firstChild.attributes.isprivate;
			var fast:String = _xml.firstChild.firstChild.attributes.fast;
			var bitview:String = _xml.firstChild.firstChild.attributes.bitview;
			
			// environment 
			//
			
			var envNode:XMLNode = _xml.firstChild.firstChild;
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
			
			var objects:String = XMLNode(_xml.firstChild.firstChild.nextSibling).firstChild.nodeValue;
			
			// reparse XML
			//
			
			var newXML:String = "<level env=\"" + env.join(",") + "\">" + objects + "</level>";
			
			var template:String = _newXMLString;
			template = template.split("<level></level>").join(newXML);
			
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(template);
			
			_xml.firstChild.attributes.id = id;
			_xml.firstChild.attributes.pubkey = pubkey;	
			_xml.firstChild.attributes.title = title;
			_xml.firstChild.attributes.author = author;
			
            _xml.firstChild.attributes.mode = mode;
			_xml.firstChild.attributes.date = date;
			_xml.firstChild.attributes.comments = comments;
			_xml.firstChild.attributes.isprivate = isprivate;
			_xml.firstChild.attributes.fast = fast;
			_xml.firstChild.attributes.bitview = bitview;
			
		}
		
		//
        //
        //
        public function getOldFormatGameXML ():XMLDocument {
			
			var gameXML:XMLDocument = new XMLDocument();
			gameXML.ignoreWhite = true;
			gameXML.parseXML(_newOldXMLString);
			
            var envNode:XMLNode = gameXML.firstChild.firstChild;
			
			envNode.attributes.bkgd = Creator.levels.bgNum + "";
			envNode.attributes.bgcolor = ColorTools.numberToHTMLColor(Creator.levels.bgColor);
			envNode.attributes.gdcolor = ColorTools.numberToHTMLColor(Creator.levels.gdColor);
			envNode.attributes.ambcolor = Math.floor(Creator.levels.ambColor * 100) + "";
			
            var objectsNode:XMLNode = gameXML.firstChild.firstChild.nextSibling.firstChild;
        	
            objectsNode.nodeValue = Creator.levels.exportLevelData(0);
			
			gameXML.firstChild.attributes.title = escape(title);
			if (author != null && author.length > 0) gameXML.firstChild.attributes.author = author;
            gameXML.firstChild.attributes.mode = _creator.gameMode;
			gameXML.firstChild.attributes.date = _creator.today;
			gameXML.firstChild.attributes.comments = comments;
			gameXML.firstChild.attributes.isprivate = isprivate;
			gameXML.firstChild.firstChild.attributes.fast = fast;
			gameXML.firstChild.firstChild.attributes.bitview = bitview;
			
			return gameXML;
            
        }
		
        //
        //
        //
        public function buildProject ():void {

			trace("Building Project...");
			_creator.ddserver.hide();
			
			_version = 2;
			
			if (_xml.firstChild.attributes.id != undefined) {
				projID = _xml.firstChild.attributes.id;
			} else {
				projID = NO_ID;
			}
			
			if (_xml.firstChild.attributes.title != undefined) {
				title = unescape(_xml.firstChild.attributes.title);
			} else {
				title = NO_TITLE;
			}
			
			if (_xml.firstChild.attributes.fast != undefined) {
				fast = _xml.firstChild.firstChild.attributes.fast;
			} else {
				fast = "0";
			}
			
			if (_xml.firstChild.attributes.bitview != undefined) {
				bitview = _xml.firstChild.attributes.bitview;
			} else {
				bitview = "0";
			}
			
			if (_xml.firstChild.attributes.mode != undefined) {
				_creator.setGameMode(parseInt(_xml.firstChild.attributes.mode));
			} else {
				_creator.setGameMode(2);
			}
			
			if (_xml.firstChild.attributes.comments != undefined) {
				comments = _xml.firstChild.attributes.comments;
			} else {
				comments = "1";
			}
			
			if (_xml.firstChild.attributes.isprivate != undefined) {
				isprivate = _xml.firstChild.attributes.isprivate;
			} else {
				isprivate = "0";
			}	
			
			_creator.ddpublish.updateSettings();
			_creator.ddenvironment.updateSettings();
			
			if (_xml.firstChild.attributes["id"] != undefined) {
				var projid:int = parseInt(_xml.firstChild.attributes.id.split("proj").join(""));
				updateCreatorForGameVersion(projid);
			} else {
				updateCreatorForGameVersion();
			}
			
			// convert old data format to new one that supports graphics
			if (_version > 1)
			{
				if (!hasGraphics)
				{
					var t:Number = getTimer();
					
					if (_xml.idMap['levels'])
					{
						var levels:XMLNode = _xml.idMap['levels'];
						var dummyGraphicData:Array = [0, 0, 0];
						
						for (var i:int = 0; i < levels.childNodes.length; i++)
						{
							var level:XMLNode = levels.childNodes[i];
							
							if (level.firstChild.nodeValue != null) {
								
								var objectsData:Array = level.firstChild.nodeValue.split("|");
								
								for (var j:int = 0; j < objectsData.length; j++)
								{
									if (objectsData[j] != null && objectsData[j] is String) {
										var objData:Array = objectsData[j].split(",");
										objData.splice(5, 0, dummyGraphicData);
										objectsData[j] = objData;
									}
								}
								
								level.firstChild.nodeValue = objectsData.join("|");
								
							}
							
						}
						_xml.firstChild.attributes.g = "1";
						trace("elapsed time to convert: " + (getTimer() - t) + "ms");
					}
				}
				
				extractGraphicsFromXMLDocument();
			}
			
        }
		
		
		protected function extractGraphicsFromXMLDocument ():void {
			
			_creator.graphics.clean();
			
			if (_xml && 
				_xml.firstChild && 
				_xml.firstChild.firstChild && 
				_xml.firstChild.firstChild.nextSibling) {
				
				var graphicsNode:XMLNode = _xml.firstChild.firstChild.nextSibling;
				
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
					trace("graphic extracted!");
					Textures.addBitmapDataToCache(loader.name, Bitmap(loader.content).bitmapData);
				} else {
					trace("Error: loaded file is not bitmap", loader.name, loader.content);
				}
			}
			
		}
		
		
		//
		//
		protected function updateCreatorForGameVersion (projid:Number = 0):void {
			
			var minGameId:Number = 2166683;
			var url:String = CreatorMain.dataLoader.baseURL;
			
			if (url.indexOf("sploder.home") != -1 || url.indexOf("192.168.") != -1) {
				
				minGameId = 1778000;
				
			}
			
			var disable:Boolean = (!isNaN(projid) && projid > 0 && projid < minGameId);
			
			// TEMP disable disabling in demo
			// if (_creator.demo == true) disable = false;
			
			if (disable) {
				_creator.ddoldgame.show();
				_version = 1;
			} else {
				_version = 2;
			}
			
			for each (var adder:CreatorObjectAdder in _creator.objTray.adders) {
				if (adder.version >= 2) {
					adder.disabled_btn.visible = disable;
				}
			}	
			
			_creator.levelSelector.enabled =
				_creator.addLevelButton.enabled =
				_creator.removeLevelButton.enabled = 
				_creator.musicButton.enabled =
				_creator.graphicsPanelToggle.enabled = !disable;
				
		}
			
        //
        //
        // GETPROJECT loads the project XML from the server
        public function getProject (id:uint):void {
            
            _creator.ddserver.show("Loading Project...");
			
			_transferring = true;
			
			CreatorMain.dataLoader.loadXMLData(
				_getProjectURL + CreatorMain.dataLoader.getCacheString("u=" + User.u + "&c=" + User.c + "&p=" + id), 
				true, 
				onProjectLoaded, onProjectLoadError
				);
            
        }
		
		//
		//
		public function onProjectLoaded (e:Event):void {
		
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(e.target.data);
			
			if (_xml.firstChild.firstChild.nodeName != "levels") {
				convertOldXMLToNew();
			}
			
			_transferring = false;
			
			_creator.ddserver.hide();
			
			buildProject();
			
			clearLocalProject();
			
			sendLoadEventDelayed();
			
		}
		
		//
		//
		public function onProjectLoadError (e:IOErrorEvent):void {
		
			_transferring = false;
			
			_creator.ddserver.hide();
			_creator.ddalert.show("Unable to load project.  There was a problem loading it from the server");
			
		}
		
        //
        //
        //
        public function newProject(e:Event = null):void {
            
			if (e != null) {
				_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CONFIRM, newProject);
			}
			
			if (e == null || e.type == CreatorDialogue.EVENT_CONFIRM) {
				
				_creator.graphics.clean();

				newDocument();
				
				pubkey = "";
				_creator.ddmanager.currentProjectID = null;
				_creator.ddmanager.currentProjectTitle = "";
				projID = NO_ID;
				
				dispatchEvent(new Event(EVENT_NEW));
				
				_transferring = false;
			
			}
			
			updateCreatorForGameVersion();
            
        }
		
		//
		//
		public function saveLocalProject (e:TimerEvent = null):void {
			
			if (!_transferring && !Creator.playfield.populating && Creator.playfield.objects.length > 1) {

				buildDocument(false, true);
				
				var xmlString:String = _xml.toString();
				
				if (xmlString != _prevXMLString) {

					Settings.saveSetting("creator2temp", xmlString);
					_prevXMLString = xmlString;
					
				}
			
			}
			
		}
		
		//
		//
		public function get hasLocalProject ():Boolean {
				
			return (Settings.loadSetting("creator2temp") != null && String(Settings.loadSetting("creator2temp")).length > 0);
			
		}
		
		//
		//
		public function confirmLoadLocalProject ():void {
			
			_creator.ddconfirm.show("Your project was saved in memory.  Click YES to restore it.");
			_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CANCEL, loadLocalProject);
			_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CONFIRM, loadLocalProject);
			
		}
		
		//
		//
		public function loadLocalProject (e:Event = null):void {

			if (e != null) {
				
				_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CANCEL, loadLocalProject);
				_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CONFIRM, loadLocalProject);

				if (e.type == CreatorDialogue.EVENT_CANCEL) {

					if (_xml == null) newProject();
					
					return;
					
				}
				
			}
			
			if (hasLocalProject) {
				
				_prevXMLString = Settings.loadSetting("creator2temp") as String;
				_xml = new XMLDocument(_prevXMLString);
				
				if (_xml.firstChild.firstChild.nodeName != "levels") {
					convertOldXMLToNew();
				}

				buildProject();
				
				sendLoadEventDelayed();
			}
			
		}
		
		private function sendLoadEventDelayed ():void
		{
			loadTimer = new Timer(100, 1);
			loadTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onProjectLoadComplete);
			loadTimer.start();
		}
		
		private function onProjectLoadComplete (e:TimerEvent):void
		{
			dispatchEvent(new Event(EVENT_LOAD));
		}
		
		//
		//
		public function clearLocalProject ():void {
			
			Settings.saveSetting("creator2temp", "");
			trace("clearing local project");
			_prevXMLString = _xml.toString();
			
		}
		
        //
        //
        //
        public function testProject (e:Event = null, currentLevelOnly:Boolean = false):void {
   
			buildDocument(currentLevelOnly, true);

			User["data"] = "";
			
			if (_version == 1) {
				User["data"] = getOldFormatGameXML().toString();
			} else {
				User["data"] = _xml.toString();
			}

			CreatorMain.loadGamePreview();
			
			dispatchEvent(new Event(EVENT_TEST));

        }
		
        //
        //
        //
        public function loadProject ():void {
            
			trace("loading project...");

			getProject(parseInt(_creator.ddmanager.currentProjectID.split("proj").join("")));

        }
		
		public function requestSaveProject ():void {
			
			if (projID != NO_ID && projID.length > 0) {
				saveProject();
			} else {
				requestSaveProjectAs();
			}
			
		}
		
		public function requestSaveProjectAs ():void {
			
			saveProjectAs();
			
		}
		
        //
        //
        //
        protected function saveProject ():void {

            if ((Creator.playfield.objects.length > 0) && !_creator.demo) {

				saveProjectData();
				
            }
            
        }
        
        //
        //
        // SAVEPROJECTAS shows the game manager to save games...
        protected function saveProjectAs ():void {
            
            if (Creator.playfield.objects.length > 0 && !_creator.demo) {
			
				_creator.ddmanager.title = "Save Your Game";
				_creator.ddmanager.currentProjectID = projID;
				_creator.ddmanager.currentProjectTitle = unescape(title);
				_creator.ddmanager.mode = CreatorManager.MODE_SAVE;
				_creator.ddmanager.loadList();

			}

        }
        
        //
        //
        // SAVECONFIRM Checks user confirmation and saves a show to the server
        public function saveConfirm (confirm:Boolean = false):void {

			_creator.ddconfirm.show("Saving this project will overwrite your previous project.");
			_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CONFIRM, overwriteProjectData);   
			_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CANCEL, overwriteProjectData);  
            
        }
		
		//
		//
		protected function overwriteProjectData (e:Event):void {
			
			_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CONFIRM, overwriteProjectData); 
			
			if (e.type == CreatorDialogue.EVENT_CONFIRM) {
				if (projID != null && projID.length > 0 && title != null && title.length > 0) {
					_xml.firstChild.attributes.id = projID;
					saveProjectData();
				}
			}
			
		}
        
        //
        //
        // SAVEPROJECTDATA saves the project XML to the server
        public function saveProjectData ():void {
            
			_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CONFIRM, saveProjectData);
			
			_creator.ddserver.show("Saving Game Project...");
			CreatorMain.mainStage.invalidate();
			
            buildDocument(false, true);

			_projectVars = new URLVariables();
			
            if (projID == NO_ID || projID.length == 0) {
                
                trace("saving unsaved project");
                projID = _xml.firstChild.attributes.id = NO_ID;
				
				trace("saving project", CreatorMain.dataLoader.baseURL, _saveURL, CreatorMain.dataLoader.getCacheString(_saveParams));
                _projectRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _saveURL + CreatorMain.dataLoader.getCacheString(_saveParams));

                
            } else {
                
                trace("saving previously saved project:", CreatorMain.dataLoader.baseURL + _saveURL + CreatorMain.dataLoader.getCacheString(_saveParams + "&projid=" + _xml.firstChild.attributes.id));
				_projectRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _saveURL + CreatorMain.dataLoader.getCacheString(_saveParams + "&projid=" + _xml.firstChild.attributes.id));
    
				
            }
			
            _xml.firstChild.attributes.title = escape(unescape(unescape(_xml.firstChild.attributes.title)));
			_projectVars.xml = _xml.toString();
			
			_projectRequest.method = URLRequestMethod.POST;
			_projectRequest.data = _projectVars;
			
			_projectSaver = new URLLoader();
			_projectSaver.addEventListener(Event.COMPLETE, saveResult);
			_projectSaver.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_projectSaver.load(_projectRequest);
			
			_transferring = true;
            
        }  
		
		//
		//
		public function onSaveError (e:Event):void {

			_projectSaver.removeEventListener(Event.COMPLETE, saveResult);
			_projectSaver.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			_creator.ddalert.show("There was an error saving your project. It has been saved to memory.  Please try again later.");
			
			_transferring = false;
			
			saveLocalProject();
			
		}
        
        
        //
        //
        //
        public function saveResult (e:Event):void {
			
			_projectSaver.removeEventListener(Event.COMPLETE, saveResult);
			_projectSaver.removeEventListener(IOErrorEvent.IO_ERROR, CreatorMain.dataLoader.onXMLDataError);
			
			try {
				var result:XML = new XML(e.target.data);
			} catch (err:Error) {
				_creator.ddserver.show("There was a problem saving your project.", e.target.data);
				//trace(e.target.data);
				return;
			}
			
			_creator.ddserver.hide();
			
			if (result.@result == "success") {
				
				var newID:String = result.@id;
				
				if (newID != null && newID.length > 0) {
					projID = _xml.firstChild.attributes.id = newID;
				} else {
					projID = NO_ID;
				}
				
				generateThumbnails();
				saveThumbnails();
			
				if (pubkey != null && pubkey.length > 0) {
					_creator.ddservercomplete.show("Your game was successfully saved.");	
				} else {
					_creator.ddservercomplete.show("Your game was successfully saved.  When you are done, don't forget to publish!");
				}
				
				clearLocalProject();
				
			} else {
				
				_creator.ddservercomplete.show("Sorry! save failed. Please try again in a few seconds.", result.@message);
				delete _xml.firstChild.attributes.id;
				
			}
			
			
			if (_xml.firstChild.attributes.id == NO_ID) {
				delete _xml.firstChild.attributes.id;
			}
			
			_transferring = false;
            
        }
		

        //
        //
        // PUBLISHGAME publishes the game
        public function publishGame ():void {
            
            if ((Creator.playfield.objects.length > 1) && !_creator.demo && (_xml.firstChild.attributes.id != NO_ID) && (_xml.firstChild.attributes.id != undefined)) {
                  
                _creator.ddpublish.show();
                
            } else {
                
				if (_creator.demo) {
					
					saveLocalProject();
					_creator.ddjoin.show();
					
				} else if ((_xml.firstChild.attributes.id == NO_ID) || (_xml.firstChild.attributes.id == undefined)) {
					
					_creator.ddalert.show("You must save your project before you publish it. Click 'Save' to save your work.");

				} else if (Creator.playfield.objects.length <= 1) {
					
					_creator.ddalert.show("You must have objects on the playfield to publish your game.  Drag some objects onto the playfield.");

				}

            }
            
        }
    
        //
        //
        // PUBLISHPROJECT saves the optimized XML for the game
        public function publishProject ():void {
            
            buildDocument(false, true);
			
			if (_version == 1) {
				gameXML = getOldFormatGameXML();
			} else {
				gameXML = new XMLDocument(_xml.toString());
			}
			
			_gameVars = new URLVariables();
			
            if ((_xml.firstChild.attributes.id == undefined) || (_xml.firstChild.attributes.id.length < 3)) {
                _gameRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _publishURL + CreatorMain.dataLoader.getCacheString("projid=temp"));        
            } else {
                _gameRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _publishURL + CreatorMain.dataLoader.getCacheString("projid=" + _xml.firstChild.attributes.id + "&comments=" + comments + "&private=" + isprivate));
            }
			
			_gameVars.xml = gameXML.toString();
			
            _creator.ddserver.show("Publishing Game ...");
			
			_gameRequest.method = URLRequestMethod.POST;
			_gameRequest.data = _gameVars;
			
			_gameSaver = new URLLoader();
			_gameSaver.addEventListener(Event.COMPLETE, publishResult);
			_gameSaver.addEventListener(IOErrorEvent.IO_ERROR, CreatorMain.dataLoader.onXMLDataError);
			_gameSaver.load(_gameRequest);
			
			_transferring = true;
            
        }    
    
    
        //
        //
        //
        public function publishResult (e:Event):void {
			
			_gameSaver.removeEventListener(Event.COMPLETE, publishResult);
			_gameSaver.removeEventListener(IOErrorEvent.IO_ERROR, CreatorMain.dataLoader.onXMLDataError);

			try {
				var result:XML = new XML(e.target.data);
			} catch (err:Error) {
				_creator.ddserver.show("There was a problem publishing your game.", e.target.data);
				//trace(e.target.data);
				return;
			}
			
			_creator.ddserver.hide();
			
			if (result.@result == "success") {
				
				pubkey = result.@pubkey;
				_creator.ddserverpublished.show("Playing published game.  If you are blocking pop-ups, click 'PLAY AGAIN'.");
				navigateToURL(new URLRequest("javascript: playPubMovie('" + pubkey + "',480);"), "_self");
				
			} else {
				
				_creator.ddservercomplete.show("Sorry! Publish failed. Please try again in a few seconds.", result.@message);
				
			}
			
			_transferring = false;

        }
		
		//
		//
		public function playPubMovie (e:MouseEvent):void {
			
			if (pubkey != null && pubkey.length > 0) navigateToURL(new URLRequest("javascript: playPubMovie('" + pubkey + "',480);"), "_self");
			
		}
		
		//
		//
		protected function generateThumbnails ():void {
			
			if (Creator.playfield.player == null) return;
			
			var player:CreatorPlayfieldObject = Creator.playfield.player;
			
			var oldx:Number = Creator.playfield.clip.x;
			var oldy:Number = Creator.playfield.clip.y;
			
			var r:Rectangle = Creator.playfield.clip.parent.scrollRect;
			Creator.playfield.clip.parent.scrollRect = null;
			
			Creator.playfield.clip.x = 0 - Creator.playfield.minx;
			Creator.playfield.clip.y = 0 - Creator.playfield.miny;
			
			var pwidth:Number = Creator.playfield.maxx - Creator.playfield.minx;
			var pheight:Number = Creator.playfield.maxy - Creator.playfield.miny;
			
			var bigScale:Number = Math.max(220 / pwidth, 220 / pheight);
		
			if (pwidth > pheight) {
				Creator.playfield.clip.x += 0 - (pwidth - pheight) / 2;
			} else {
				Creator.playfield.clip.y += 0 - (pheight - pwidth) / 2;
			}

			var bkgd1:Sprite = Creator.creatorlibrary.getDisplayObject("background" + Creator.levels.bgNum) as Sprite;
			if (bkgd1 != null) {
				bkgd1.y = 0 - bkgd1.height / 2;
				if (bkgd1.height > bkgd1.width) bkgd1.y = 0;
				bkgd1.x = Math.floor(player.x / bkgd1.width) * bkgd1.width;
				Creator.playfield.background.addChild(bkgd1);
			}
			var bkgd2:Sprite = Creator.creatorlibrary.getDisplayObject("background" + Creator.levels.bgNum) as Sprite;
			if (bkgd2 != null) {
				bkgd2.y = 0 - bkgd2.height / 2;
				if (bkgd2.height > bkgd2.width) bkgd2.y = 0;
				bkgd2.x = bkgd2.width + Math.floor(player.x / bkgd2.width) * bkgd2.width;
				Creator.playfield.background.addChild(bkgd2);
			}
			var bkgd3:Sprite = Creator.creatorlibrary.getDisplayObject("background" + Creator.levels.bgNum) as Sprite;
			if (bkgd3 != null) {
				bkgd3.y = 0 - bkgd3.height / 2;
				if (bkgd3.height > bkgd3.width) bkgd3.y = 0;
				bkgd3.x = 0 - bkgd3.width + Math.floor(player.x / bkgd3.width) * bkgd3.width;
				Creator.playfield.background.addChild(bkgd3);
			}
			
			Creator.playfield.grid.visible = false;
			Creator.playfield.selection.selectNone();

			var gon:MovieClip = Creator.UIlibrary.getDisplayObject("numlevels") as MovieClip;
			gon.gotoAndStop(Creator.levels.totalLevels);
			
			var bA:BitmapData = new BitmapData(220, 220, false, 0x000000);
			var m:Matrix = new Matrix();
			m.createBox(bigScale, bigScale, 0, 0, 0);
			bA.draw(Creator.playfield.clip.parent, m, null, null, null, true);
			m.createBox(1, 1, 0, 140, 140);
			bA.draw(gon);
			_bigThumb = PNGEncoder.encode(bA);
			
			Creator.playfield.clip.x = 0 - player.x + 440 + (Math.random() * 100 - 50);
			Creator.playfield.clip.y = 0 - player.y + 440 + (Math.random() * 60) + 40;
			
			// TEST
			// CreatorMain.mainStage.addChild(new Bitmap(bA));
			
			var bB:BitmapData = new BitmapData(80, 80, false, 0x000000);
			var m2:Matrix = new Matrix();
			m2.createBox((80 / 220) * 0.25, (80 / 220) * 0.25, 0, 0, 0);
			bB.draw(Creator.playfield.clip.parent, m2, null, null, null, true);
			bB.draw(gon);
			
			_smallThumb = PNGEncoder.encode(bB);
			
			if (bkgd1 != null && bkgd1.parent != null) bkgd1.parent.removeChild(bkgd1);
			if (bkgd2 != null && bkgd2.parent != null) bkgd2.parent.removeChild(bkgd2);
			if (bkgd3 != null && bkgd3.parent != null) bkgd3.parent.removeChild(bkgd3);
			
			Creator.playfield.grid.visible = true;
			Creator.playfield.clip.x = oldx;
			Creator.playfield.clip.y = oldy;
			
			Creator.playfield.clip.parent.scrollRect = r;
			
			// TEST
			// CreatorMain.mainStage.addChild(new Bitmap(bB));
			
			
		}
		
		//
		//
		protected function saveThumbnails ():void {
			
			_smallThumbRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _thumbPostURL + CreatorMain.dataLoader.getCacheString("projid=" + _xml.firstChild.attributes.id + "&size=small"));
			_smallThumbRequest.method = URLRequestMethod.POST;
			_smallThumbRequest.contentType = "application/octet-stream";
			_smallThumbRequest.data = _smallThumb;
			trace("SMALL PNG SIZE:" + _smallThumb.length);
			_smallThumbSaver = new URLLoader();
			_smallThumbSaver.addEventListener(IOErrorEvent.IO_ERROR, onSmallThumbError);
			_smallThumbSaver.addEventListener(Event.COMPLETE, onSmallThumbSaved);
			_smallThumbSaver.load(_smallThumbRequest);

		}
		
		//
		//
		protected function onSmallThumbError (e:IOErrorEvent):void {
			
			_smallThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onSmallThumbError);
			_smallThumbSaver.removeEventListener(Event.COMPLETE, onSmallThumbSaved);	
			_creator.ddalert.show("There was a problem saving your game thumbnail.");
			
		}
		
		//
		//
		protected function onSmallThumbSaved (e:Event):void {
			
			_smallThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onSmallThumbError);
			_smallThumbSaver.removeEventListener(Event.COMPLETE, onSmallThumbSaved);	
			
			_bigThumbRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _thumbPostURL + CreatorMain.dataLoader.getCacheString("projid=" + _xml.firstChild.attributes.id + "&size=big"));
			_bigThumbRequest.method = URLRequestMethod.POST;
			_bigThumbRequest.contentType = "application/octet-stream";
			_bigThumbRequest.data = _bigThumb;
			trace("BIG PNG SIZE:" + _bigThumb.length);
			_bigThumbSaver = new URLLoader();
			_bigThumbSaver.addEventListener(IOErrorEvent.IO_ERROR, onBigThumbError);
			_bigThumbSaver.addEventListener(Event.COMPLETE, onBigThumbSaved);
			_bigThumbSaver.load(_bigThumbRequest);
			
		}
		
		//
		//
		protected function onBigThumbError (e:IOErrorEvent):void {
			
			_bigThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onBigThumbError);
			_bigThumbSaver.removeEventListener(Event.COMPLETE, onBigThumbSaved);
			_creator.ddalert.show("There was a problem saving your game thumbnail.");

		}
		
		//
		//
		protected function onBigThumbSaved (e:Event):void {
			
			_bigThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onBigThumbError);
			_bigThumbSaver.removeEventListener(Event.COMPLETE, onBigThumbSaved);

		}
	
	}
	
}