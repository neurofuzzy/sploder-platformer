package com.sploder.builder 
{
	import com.sploder.asui.ColorTools;
	import com.sploder.asui.Component;
	import com.sploder.util.Textures;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.xml.XMLDocument;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorLevels
	{
		public static const MAX_LEVELS:int = 12;
		
		protected var _creator:Creator;
		
		protected var _currentLevel:uint = 0;
		public function get currentLevel():uint { return _currentLevel; }
		
		public function get currentLevelDisplayNum ():String {
			
			return "Level " + (_currentLevel + 1);
			
		}
		
		public function get currentLevelName ():String {
			
			return _levelNames[_currentLevel];
			
		}
		
		public function set currentLevelName (value:String):void {
			_levelNames[_currentLevel] = value;
		}
		
		public function get totalLevels():uint { return _levelData.length; }
		
		protected var _levelData:Array;
		protected var _levelEnv:Array;
		protected var _levelNames:Array;
		protected var _levelMusic:Array;
		protected var _levelAvatars:Array;
		
		protected var _totalBackgrounds:int = 0;
		public function get totalBackgrounds():int { return _totalBackgrounds; }
	
		public function get bgNum ():int {
			if (getCurrentEnvParam(0)) return parseInt(getCurrentEnvParam(0));
			else return 1;
		}
		public function get bgColor ():uint {
			if (getCurrentEnvParam(1)) return parseInt(getCurrentEnvParam(1), 16);
			else return 0x336699;
		}
		public function get gdColor ():uint {
			if (getCurrentEnvParam(2)) return parseInt(getCurrentEnvParam(2), 16);
			else return 0x333333;
		}
		public function get ambColor ():Number {
			if (getCurrentEnvParam(3)) return parseInt(getCurrentEnvParam(3)) / 100;
			else return 1;
		}
		public function get music ():String {
			if (_levelMusic.length > _currentLevel) return _levelMusic[_currentLevel];
			else return "";
		}
		public function set music (val:String):void {
			_levelMusic[_currentLevel] = val;
		}
		public function get avatar ():int {
			if (_levelAvatars.length > _currentLevel) return _levelAvatars[_currentLevel];
			else return 0;
		}
		public function set avatar (val:int):void {
			_levelAvatars[_currentLevel] = val;
		}
		
		protected function getCurrentEnvParam (idx:uint):String {
			if (_levelEnv && _levelEnv[_currentLevel]) {
				//trace(_levelEnv[_currentLevel]);
				var env:Array = _levelEnv[_currentLevel].split(",");
				if (env[idx]) return env[idx];
			}
			return null;
		}
		
		protected var _defaultNum:uint;
		
		protected var _defaultName:String = "";
		protected var _defaultLevel:String = "1,0,70,0";
		protected var _defaultEnvironment:String = "1,0x003366,0x333333,1";
			
		public var bgColors:Array = [0x336699, 0x6699cc, 0xcc3300, 0xdd9900, 0xcc66cc, 0x009999, 0x6600cc, 0x33cccc, 0x999999, 0x668899];
		public var gdColors:Array = [0x333333, 0x666666, 0x009966, 0x009900, 0x660066, 0x006633, 0x660000, 0x663300, 0x003300, 0x003366];
				
		//
		//
		public function CreatorLevels (creator:Creator) 
		{
			init(creator);
		}
		
		//
		//
		protected function init (creator:Creator):void {
			
			_creator = creator;
			
			_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			_creator.addLevelButton.addEventListener(Component.EVENT_CLICK, addLevel);
			_creator.removeLevelButton.addEventListener(Component.EVENT_CLICK, removeLevel);
			_creator.removeLevelButton.disable();
			_creator.moveLevelButton.addEventListener(Component.EVENT_CLICK, moveLevel);
			_creator.copyLevelButton.addEventListener(Component.EVENT_CLICK, copyLevel);
			
			_creator.project.addEventListener(CreatorProject.EVENT_LOAD, onProjectLoaded);
			_creator.project.addEventListener(CreatorProject.EVENT_NEW, reset);
			
			while (Creator.creatorlibrary.getDisplayObject("background" + _totalBackgrounds) != null) {
				 _totalBackgrounds++;
			}
			
		}
		
		//
		//
		protected function get defaultLevel ():String {
			
			return _defaultLevel;
			
		}
		
		//
		//
		protected function get defaultEnvironment ():String {
			
			return _defaultEnvironment;
			
		}
		
 		//
        //
        public function getRandomEnvironment ():String {
            
			var bgNum:uint = 1;
            var bgColor:uint = 0x003366;
			var gdColor:uint = 0x333333;
			var ambColor:uint = 100;
			var color:uint;
			
			color = bgColors[Math.floor(Math.random() * bgColors.length) - 1];
            
            if (!isNaN(color) && color > 0) {
                bgColor = color;
            }
			
			color = gdColors[Math.floor(Math.random() * gdColors.length) - 1];
            
            if (!isNaN(color) && color > 0) {
                gdColor = color;
            }
			
			if (Creator.environment != null) {
				bgNum = Math.min(totalBackgrounds, Math.floor(Math.random() * totalBackgrounds));
			}
                
			var env:Array = [
				bgNum.toString(),
				bgColor.toString(16),
				gdColor.toString(16),
				ambColor.toString()
				];
				
			return env.join(",");
			
        }
		
        //
        //
        //
        public function get objects ():Array {
            
			if (_levelData != null && _levelData.length >= _currentLevel) {
				return String(_levelData[_currentLevel]).split("|");
			}
			
			return null;
            
        }
		
		//
		//
		public function hasObjectWithIDs (ids:Array):Boolean {
			
			var i:int;
			var lv:Array;
			var id:String;
			var idi:uint;
			
			for (var j:int = 0; j < _levelData.length; j++) {
				
				if (j != _currentLevel) {
					
					lv = String(_levelData[j] + "").split("|");
					
					for (i = 0; i < lv.length; i++) {
						
						id = lv[i].split(",")[0];
						idi = parseInt(id);
						if (ids.indexOf(id) != -1 || ids.indexOf(idi) != -1) return true;
						
					}
				
				}
				
			}
			
			for (i = 0; i < Creator.playfield.objects.length; i++) {
				
				id = CreatorPlayfieldObject(Creator.playfield.objects[i]).id + "";
				idi = CreatorPlayfieldObject(Creator.playfield.objects[i]).id;
				if (ids.indexOf(id) != -1 || ids.indexOf(idi) != -1) return true;
					
			}
			
			return false;
			
		}
		
		//
		//
		public function saveCurrentLevel ():void {
			
			if (Creator.playfield.objects.length > 0) {
				
				var data:Array = [];
				
				for (var i:int = 0; i < Creator.playfield.objects.length; i++) {
					
					data.push(CreatorPlayfieldObject(Creator.playfield.objects[i]).toString());
					
				}
				
				_levelData[_currentLevel] = data.join("|");
				
			}
			
		}
		
		//
		//
		public function saveCurrentEnvironment ():void {
			
			_levelEnv[_currentLevel] = Creator.environment.settings.join(",");
			
		}
		
		//
		//
		public function saveCurrentMusic ():void {
			
			_levelMusic[_currentLevel] = music;
			
		}
		
		//
		//
		public function clearCurrentLevel ():void {
			
			_levelData[_currentLevel] = "";
			
		}
		
		//
		//
		public function clearCurrentEnvironment ():void {
			
			_levelEnv[_currentLevel] = "";
			
		}
		
		//
		//
		public function clearCurrentMusic ():void {
			
			_levelMusic[_currentLevel] = "";
			
		}
		
		//
		//
		public function reset (e:Event = null):void {
			
			_creator.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			_levelData = [];
			_levelData.push(defaultLevel);
			_currentLevel = 0;
			_creator.levelSelector.choices = ["Level 1"];
			
			_creator.addLevelButton.enable();
			_creator.removeLevelButton.disable();
			_creator.moveLevelButton.disable();
			_creator.nameLevelButton.enable();
			_creator.copyLevelButton.enable();
			
			_levelNames = [];
			
			_levelEnv = [];
			_levelEnv.push(getRandomEnvironment());
			
			_levelMusic = [];
			_levelMusic.push("");
			
			_levelAvatars = [];
			
			if (Creator.environment) Creator.environment.updateSettings();
			Creator.playfield.reset();
			
			_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);

		}
		
		//
		//
		protected function onProjectLoaded (e:Event):void {
			
			_creator.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			_levelData = [];
			_levelEnv = [];
			_currentLevel = 0;
			var levels:Array = [];
			
			for (var i:int = 0; i < _creator.project.getTotalLevels(); i++) {
				importLevelData(i);
				importEnvironmentData(i);
				importMusicData(i);
				importAvatarData(i);
				importLevelName(i);
				levels.push("Level " + (i + 1));
			}
			
			_creator.levelSelector.choices = levels;
			_creator.levelSelector.select(0);
			
			if (_levelData.length > 1) _creator.removeLevelButton.enable();
			else _creator.removeLevelButton.disable();
			
			if (_levelData.length < MAX_LEVELS) _creator.addLevelButton.enable();
			else _creator.addLevelButton.disable();
			
			_creator.moveLevelButton.disable();
			
			Creator.environment.updateSettings();
			Creator.playfield.reset();
			
			_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
			_creator.levelSelector.enabled =
				_creator.addLevelButton.enabled =
				_creator.removeLevelButton.enabled = 
				_creator.copyLevelButton.enabled = 
				_creator.nameLevelButton.enabled = (_creator.project.version > 1);

		}
		
		//
		//
		public function importLevelData (level:int = -1):void {
			
			if (level >= 0) _levelData[level] = _creator.project.getObjects(level);
			
		}
		
		//
		public function importEnvironmentData (level:int = -1):void {
			
			if (level >= 0) _levelEnv[level] = _creator.project.getEnvironment(level);
			
		}
		
		//
		public function importMusicData (level:int = -1):void {
			
			if (level >= 0) _levelMusic[level] = _creator.project.getMusic(level);
			
		}
		
		//
		public function importAvatarData (level:int = -1):void {
			
			if (level >= 0) _levelAvatars[level] = _creator.project.getAvatar(level);
			
		}
		
		//
		public function importLevelName (level:int = -1):void {
			
			if (level >= 0) _levelNames[level] = _creator.project.getLevelName(level);
			
		}
		
		//
		//
		public function exportLevelData (level:int):String {
			
			if (_levelData.length > level) return _levelData[level];
			
			return "";
			
		}
		
		//
		//
		public function exportEnvironmentData (level:int):String {
			
			if (_levelEnv.length > level) return _levelEnv[level];
			
			return "";
			
		}
		
		//
		//
		public function exportMusicData (level:int):String {
			
			if (_levelMusic.length > level) return _levelMusic[level];
			
			return "";
			
		}
		
		//
		//
		public function exportAvatarData (level:int):int {
			
			if (_levelAvatars.length > level) return _levelAvatars[level];
			
			return 0;
			
		}
		
		//
		//
		public function exportLevels ():Array {
			
			var lv:Array = [];
			
			for (var i:int = 0; i < _levelData.length; i++) {
				
				lv.push(exportLevelData(i));
				
			}
			
			return lv;
			
		}
		
		//
		//
		public function exportEnvironments ():Array {
			
			var lv:Array = [];
			
			for (var i:int = 0; i < _levelEnv.length; i++) {
				
				lv.push(exportEnvironmentData(i));
				
			}
			
			return lv;
			
		}
		
		public function exportLevelName (level:uint = -1):String {
			if (level >= 0 && _levelNames != null && _levelNames[level] != null) return _levelNames[level];
			return "";
		}
		
		public function exportLevelNames ():Array {
			return _levelNames.concat();
		}
		
		//
		//
		public function exportGraphics ():Object {
			
			var graphics:Object = { };
			
			for (var j:int = 0; j < _levelData.length; j++) {
				
				var level_objects:Array = String(_levelData[j]).split("|");
			
				for (var i:int = 0; i < level_objects.length; i++) {
					
					if (level_objects[i] && String(level_objects[i]).length) {
						
						var objProps:Array = level_objects[i].split(",");
						
						if (parseInt(objProps[5]) > 0) {
							var name:String = parseInt(objProps[5]) + "_" + parseInt(objProps[6]);
							graphics[name] = Textures.getOriginal(name);
						}
						
					}
					
				}
				
			}
			
			return graphics;
			
		}
		
		//
		//
		public function exportMusics ():Array {
			
			var lv:Array = [];
			
			for (var i:int = 0; i < _levelMusic.length; i++) {
				
				lv.push(exportMusicData(i));
				
			}
			
			return lv;
			
		}	
		
		//
		//
		protected function changeLevel (e:Event):void {
			
			if (_creator.levelSelector != null) {
				
				if (_creator.levelSelector.value.length > 0) {
					
					var newLevel:uint = parseInt(_creator.levelSelector.value.split(" ")[1]) - 1;
					
					if (newLevel != _currentLevel) {
						
						saveCurrentLevel();
						saveCurrentEnvironment();
						
						_currentLevel = newLevel;
						
						Creator.playfield.reset();
						Creator.environment.updateSettings();
						
						if (_currentLevel == 0) _creator.moveLevelButton.disable();
						else _creator.moveLevelButton.enable();
						
					}
					
				}
				
			}
			
		}
		
		//
		//
		protected function addLevel (e:Event):void {
			
			saveCurrentLevel();
			saveCurrentEnvironment();
			
			var levels:Array = _creator.levelSelector.choices.concat();
			if (levels.length >= MAX_LEVELS) return;
			
			_creator.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			levels.push("Level " + (levels.length + 1));
			_creator.levelSelector.choices = levels;
			
			_creator.removeLevelButton.enable();
			
			if (levels.length >= MAX_LEVELS) {
				_creator.addLevelButton.disable();
				_creator.copyLevelButton.disable();
			}
			
			_levelData.push(defaultLevel);
			_levelEnv.push(getRandomEnvironment());
			
			_currentLevel = _levelData.length - 1;
			
			if (_currentLevel == 0) _creator.moveLevelButton.disable();
			else _creator.moveLevelButton.enable();
			
			Creator.playfield.reset();
			Creator.environment.updateSettings();
			
			_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
		}
		
		//
		//
		protected function copyLevel (e:Event):void {
			
			saveCurrentLevel();
			saveCurrentEnvironment();
			
			var levels:Array = _creator.levelSelector.choices.concat();
			
			if (levels.length >= MAX_LEVELS) return;
			
			_creator.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			
			levels.push("Level " + (levels.length + 1));
			_creator.levelSelector.choices = levels;
			
			_creator.removeLevelButton.enable();
			
			if (levels.length >= MAX_LEVELS) {
				_creator.addLevelButton.disable();
				_creator.copyLevelButton.disable();
			}
			
			_levelData.push(_levelData[_currentLevel]);
			_levelEnv.push(_levelEnv[_currentLevel]);
			_levelNames.push(_levelNames[_currentLevel]);
			_levelMusic.push(music);
			
			_currentLevel = _levelData.length - 1;
			
			_creator.moveLevelButton.enable();
			
			Creator.playfield.reset();
			Creator.environment.updateSettings();
			
			_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
		}
		
		
		//
		//
		protected function removeLevel (e:Event):void {
			
			_creator.ddconfirm.show("Removing this level will remove all of the contents of the level.");
			_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CONFIRM, onRemoveLevel);
			_creator.ddconfirm.addEventListener(CreatorDialogue.EVENT_CANCEL, onRemoveLevel);
			
		}
		
		protected function onRemoveLevel (e:Event):void {
			
			_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CONFIRM, onRemoveLevel);
			_creator.ddconfirm.removeEventListener(CreatorDialogue.EVENT_CANCEL, onRemoveLevel);
			_creator.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			if (e.type == CreatorDialogue.EVENT_CONFIRM) {
				
				var levels:Array = _creator.levelSelector.choices.concat();
				levels.pop();
				
				_creator.levelSelector.choices = levels;
				
				_levelData.splice(_currentLevel, 1);
				_levelEnv.splice(_currentLevel, 1);
				
				if (_levelData.length > 1) _creator.removeLevelButton.enable();
				else _creator.removeLevelButton.disable();
			
				if (_levelData.length < MAX_LEVELS) {
					_creator.addLevelButton.enable();
					_creator.copyLevelButton.enable();
				}
				
				_currentLevel = Math.max(0, Math.min(_currentLevel, _levelData.length - 1));
				
				if (_currentLevel == 0) _creator.moveLevelButton.disable();
				else _creator.moveLevelButton.enable();
				
				Creator.playfield.reset();
				Creator.environment.updateSettings();
				
			}
			
			_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
		}

		protected function moveLevel (e:Event):void {
			
			if (_currentLevel > 0) {
				
				saveCurrentLevel();
				
				var prevLevel:String = _levelData[_currentLevel - 1];
				_levelData[_currentLevel - 1] = _levelData[_currentLevel];
				_levelData[_currentLevel] = prevLevel;
				
				var prevEnv:String = _levelEnv[_currentLevel - 1];
				_levelEnv[_currentLevel - 1] = _levelEnv[_currentLevel];
				_levelEnv[_currentLevel] = prevEnv;
				
				_currentLevel -= 1;
				
				_creator.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
				
				_creator.levelSelector.select(_currentLevel);
				
				_creator.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
				
				if (_currentLevel == 0) _creator.moveLevelButton.disable();
				else _creator.moveLevelButton.enable();
				
				_creator.project.saveLocalProject();
				
			}
			
		}
		
	}

}