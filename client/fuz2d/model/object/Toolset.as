package fuz2d.model.object {
	
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import fuz2d.Fuz2d;
	import fuz2d.model.environment.OmniLight;
	import fuz2d.TimeStep;
	import fuz2d.util.Geom2d;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Toolset {
		
		public static const TOOL_CHANGE:String = "tool_change";
		public static const TOOL_COUNT:String = "tool_count";
		public static const TOOL_POSESS:String = "tool_possess";
		
		protected var _parentBone:Bone;
		
		protected var _scale:Number = 1;
		
		protected var _rotationOffset:Number = 0;
		
		protected var _tools:Array;
		public function get tools():Array { return _tools; }
		public function indexOf (toolName:String):int { return _tools.indexOf(toolName); }
		
		protected var _toolBelt:Object;
		public function get toolBelt ():Object { return _toolBelt; }
		
		protected var _toolStatuses:Array;

		protected var _tooltips:Array;

		protected var _toolRotations:Array;
		
		protected var _toolActions:Array;
		
		protected var _toolBlunts:Object;
		
		protected var _toolActiveClips:Object;
		
		protected var _toolSpawns:Array;
		
		protected var _toolSpawnAts:Array;
		
		protected var _toolSpawnDelays:Array;
		
		protected var _toolSpawnTimes:Array;
		
		protected var _toolSpawnTypes:Array;
		
		protected var _toolReleases:Array;
		
		protected var _toolCounts:Array;
		
		protected var _toolAmmo:Array;
		
		protected var _toolKeeps:Array;
		
		protected var _toolStrengths:Array;
		
		public var toolLights:Object;
		public var toolIllums:Object;
		
		public var toolHitPoint:Point;
		
		public var flip:Boolean = true;

		protected var _toolIndex:int = 0;
		public function get toolIndex():int { return _toolIndex; }
		
		public function get toolname ():String { return _tools[_toolIndex]; }
		public function get tooltip ():Point { 
		
			var pt:Point = Point(_tooltips[_toolIndex]).clone();
	
			pt.x *= _parentBone.scaleX;
			pt.y *= _parentBone.scaleY;
			
			Geom2d.rotatePoint(pt, _parentBone.worldRot);

			pt.x += _parentBone.worldX;
			pt.y = _parentBone.worldY - pt.y;
			
			return pt;
			
		}
		
		public function get toolStatus ():Boolean { return _toolStatuses[_toolIndex]; }

		public function get toolRotation ():Number { 
			// NOTE: removed + _rotationOffset to computation because it was causing errors.  Another change must have overridden this change
			return Geom2d.normalizeAngle(_parentBone.worldRot) + parseFloat(_toolRotations[_toolIndex]) * _parentBone.scaleX * _parentBone.scaleY; 
		}
		
		public function get localToolRotation ():Number {
			return (!isNaN(_toolRotations[_toolIndex])) ? parseFloat(_toolRotations[_toolIndex]) : 0;
		}

		public function get countable ():Boolean { return (_toolCounts[_toolIndex] != -1); }
		public function get spawns ():Boolean { return (_toolSpawns[_toolIndex] != "none"); }
		public function get spawnAt ():String { return _toolSpawnAts[_toolIndex]; }
		public function get spawnDelay ():int { return _toolSpawnDelays[_toolIndex]; }
		public function get spawnType ():String { return _toolSpawnTypes[_toolIndex]; }
		public function get hasAction ():Boolean { return (_toolActions[_toolIndex] != "none"); }
		
		public function get activeClip ():String { return (_toolActiveClips[_tools[_toolIndex]]); }
		
		public function get count ():int { 
			var ammo:int = _toolIndex;
			if (_toolAmmo[_toolIndex] != null) ammo = indexOf(_toolAmmo[_toolIndex]);
			return _toolCounts[ammo]; 
		}
		public function set count (value:int):void { 
			if (!countable) return;
			var ammo:int = _toolIndex;
			if (_toolAmmo[_toolIndex] != null) ammo = indexOf(_toolAmmo[_toolIndex]);
			_toolCounts[ammo] = Math.max(0, value);
			if (!_toolKeeps[_toolIndex]) {
				_toolStatuses[_toolIndex] = (value > 0);
				_toolStatuses[ammo] = (value > 0);
				if (_toolCounts[ammo] == 0) {
					prevEnabledTool();
				}
				visible = (value > 0 || !countable);
			}
			_events.dispatchEvent(new Event(TOOL_COUNT));
		}
		
		public function addToCount (tname:String, count:int = 0):void {
			var t:int = indexOf(tname);
			var ammo:int = (_toolAmmo[t] == null) ? t : indexOf(_toolAmmo[t]);
			_toolCounts[ammo] += count;
			if (count > 0) _toolStatuses[indexOf(tname)] = true;
			_events.dispatchEvent(new Event(TOOL_COUNT));
		}

		public function get spawn ():String { return _toolSpawns[_toolIndex]; }
		public function get action ():String { return _toolActions[_toolIndex]; }
		public function get blunt ():Boolean { return (_toolBlunts[toolname] == true); }
		public function get strength ():int { return _toolStrengths[_toolIndex]; }
		
		public function get canSpawn ():Boolean {
			return (spawn && (!countable || count > 0) && TimeStep.realTime - _toolSpawnTimes[_toolIndex] >= _toolSpawnDelays[_toolIndex]);
		}
		
		public function setSpawnTime ():void {
			_toolSpawnTimes[_toolIndex] = TimeStep.realTime;
		}
		
		public var active:Boolean = false;
		
		public var visible:Boolean = true;
		
		public function get numTools ():uint { return _tools.length; }
		
		protected var _events:EventDispatcher;
		public function get events():EventDispatcher { return _events; }
		
		//
		//
		public function Toolset (parentBone:Bone, parentClip:Sprite = null) {
			
			init(parentBone, parentClip);
			
		}
		
		//
		//
		protected function init (parentBone:Bone, parentClip:Sprite = null):void {
			
			var tooltip:Sprite;
			var origin:Point;
			
			_events = new EventDispatcher();
			
			_tools = [];
			_toolBelt = { };
			_tooltips = [];
			_toolRotations = [];
			_toolStatuses = [];
			_toolSpawns = [];
			_toolSpawnAts = [];
			_toolSpawnDelays = [];
			_toolSpawnTimes = [];
			_toolSpawnTypes = [];
			_toolReleases = [];
			_toolActions = [];
			_toolBlunts = { };
			_toolActiveClips = { };
			_toolCounts = [];
			_toolAmmo = [];
			_toolKeeps = [];
			_toolStrengths = [];
			
			toolLights = { };
			toolIllums = { };
			
			_scale = parentClip.scaleX;
			
			var clip:DisplayObject = parentClip.parent;
			
			while (clip != null) {
				
				_scale *= clip.scaleX;
				clip = clip.parent;
				
			}
			
			_parentBone = parentBone;
			
			if (parentClip == null) {

				_tools[0] = "none";
				_tooltips[0] = new Point(0, 0);
				return;
				
			}
			
			var currentTool:DisplayObject;
			
			for (var i:int = parentClip.numChildren - 1; i >= 0; i--) {
				
				if (parentClip.getChildAt(i) is Sprite && parentClip.getChildAt(i).name.indexOf("armor") == -1 && parentClip.getChildAt(i).name != "g" && parentClip.getChildAt(i).name != "g2c") {
					
					currentTool = parentClip.getChildAt(i);

					if (currentTool is MovieClip) {
						
						var p_has:Boolean = false;
						var p_action:Boolean = false;
						var p_spawn:Boolean = false;
						var p_spawn_at:Boolean = false;
						var p_spawn_delay:Boolean = false;
						var p_spawn_type:Boolean = false;
						var p_release:Boolean = false;
						var p_count:uint = 0;
						var p_ammo:Boolean = false;
						var p_countable:Boolean = false;
						var p_keep:Boolean = false;
						var p_strength:int = 0;
						
						for each (var lbl:FrameLabel in MovieClip(currentTool).currentLabels) {
							 
							var params:Array = lbl.name.split(" ");
							
							for (var p:int = 0; p < params.length; p++) {
								
								var pair:Array = params[p].split(":");
								
								var key:String = pair[0];
								var val:String = pair[1];

								switch (key) {
									
									case "has":
									
										_toolBelt[currentTool.name] = (!(val == "false" || val == "0"));
										p_has = true;
										break;
									
									case "action":
									
										_toolActions.push(val);
										p_action = true;
										break;
										
									case "blunt":
									
										_toolBlunts[currentTool.name] = (!(val == "false" || val == "0"));
										break;
									
									case "spawn":
									
										_toolSpawns.push(val);
										p_spawn = true;
										break;
										
									case "spawnat":
									
										if (val == "start" || val == "hold" || val == "complete") {
											_toolSpawnAts.push(val);
											p_spawn_at = true;
										} else {
											trace("ERROR: '" + val + "' invalid in " + currentTool.name + ". Tool parameter 'spawnat' must be one of the following: start, hold, complete");
										}
										break;			
										
									case "spawndelay":
									
										_toolSpawnDelays.push(parseInt(val));
										p_spawn_delay = true;
										break;
										
									case "spawntype":
									
										if (val == "launch" || val == "triple" || val == "ray" || val == "throw" || val == "spray" || val == "throwleft") {
											_toolSpawnTypes.push(val);
											p_spawn_type = true;
										} else {
											trace("ERROR: '" + val + "' invalid in " + currentTool.name + ". Tool parameter 'spawntype' must be one of the following: launch, triple, ray, throw, spray, throwleft");
										}
										break;
																				
										
									case "release":
									
										_toolReleases.push((val == "true" || val == "1"));
										p_release = true;
										break;
									
									case "count":
									
										p_count = parseInt(val);
										_toolCounts.push(parseInt(val));
										p_countable = true;
										break;
										
									case "ammo":
									
										_toolAmmo.push(val);
										break;
										
									case "keep":
										p_keep = (val == "true" || val == "1");
										break;

									case "strength":
									
										p_strength = parseInt(val);
										break;
										
									case "light":
									
										var lightVals:Array = val.split(",");

										toolLights[currentTool.name] = Fuz2d.environment.addLight(new OmniLight(_parentBone, 0, 0, lightVals[0], parseInt(lightVals[1], 16), 50, 300));
										OmniLight(toolLights[currentTool.name]).enabled = false;
										break;
										
									case "illum":
									
										toolIllums[currentTool.name] = val;
										break;
										
									case "active":
									
										_toolActiveClips[currentTool.name] = val;
										
										break;
										
										
								}
			
							}
	
						}
						
						if (!p_has) _toolBelt[currentTool.name] = true;
						if (!p_action) _toolActions.push("none");
						if (!p_spawn) _toolSpawns.push("none");
						if (!p_spawn_at) _toolSpawnAts.push("start");
						if (!p_spawn_delay) _toolSpawnDelays.push(1000);
						_toolSpawnTimes.push(0);
						if (!p_spawn_type) _toolSpawnTypes.push("launch");
						if (!p_release) _toolReleases.push(false);
						if (!p_ammo) _toolAmmo.push(null);
						if (!p_countable) _toolCounts.push( -1);

						_toolKeeps.push(p_keep);
						_toolStrengths.push(p_strength);
						
					}
					
					_tools.push(currentTool.name);
					_toolRotations.push(currentTool.rotation * Geom2d.dtr);
					_toolStatuses.push((!p_countable || (p_countable && p_count > 0)) ? true : false);
					
					if (currentTool["tooltip"] is Sprite) {
						
						tooltip = currentTool["tooltip"];
						
						var regPt:Point = new Point(tooltip.x, tooltip.y);
						
						Geom2d.rotatePoint(regPt, currentTool.rotation * Geom2d.dtr);
						
						regPt.x += currentTool.x;
						regPt.y += currentTool.y;
						
						regPt.x *= _scale;
						regPt.y *= _scale;
						
						_tooltips.push(regPt);
						
					} else {
						
						_tooltips.push(new Point(0,0));
						
					}
					
					parentClip.removeChild(parentClip.getChildAt(i));
					
				}
				
			}	
			
			if (_tools.length == 0) {

				_tools[0] = "none";
				_tooltips[0] = new Point(0, 0);
				
			}
			
		}
		
		//
		//
		public function update ():void {
			
			if (count > 0) visible = true;
			else nextEnabledTool();	
			
		}
		
		//
		//
		public function addToBelt (tname:String, switchTo:Boolean = false):Boolean {
			
			if (indexOf(tname) != -1) {
				
				_toolStatuses[indexOf(tname)] = _toolBelt[tname] = true;
				
				if (switchTo) setTool(tname);
				
				_events.dispatchEvent(new Event(TOOL_POSESS));

				return true;

			}
			
			return false;
			
		}
		
		//
		//
		public function removeFromBelt (tname:String):Boolean {
			
			if (indexOf(tname) != -1 && totalEnabledTools > 1) {
				
				_toolCounts[indexOf(tname)] = 0;
				_toolStatuses[indexOf(tname)] = _toolBelt[tname] = false;
				
				nextTool();
				
				return true;
				
			}
			
			return false;
			
		}
		
		//
		//
		public function setTool (tname:String):void {
			
			if (indexOf(tname) != -1) {
				
				if (toolLights[_tools[_toolIndex]] != null) OmniLight(toolLights[_tools[_toolIndex]]).enabled = false;
				
				_toolIndex = indexOf(tname);

				if (toolLights[tname] != null) OmniLight(toolLights[tname]).enabled = true;
		
				visible = true;
				active = false;
				
			}
			
		}
		
		//
		//
		public function nextTool ():void {
			
			if (toolLights[toolname] != null) OmniLight(toolLights[toolname]).enabled = false;
			
			_toolIndex++;	
			if (_toolIndex > _tools.length - 1) _toolIndex = 0;
			
			if (toolLights[toolname] != null) OmniLight(toolLights[toolname]).enabled = true;
	
			visible = true;
			active = false;
			
		}
		
		//
		//
		public function prevTool ():void {
			
			if (toolLights[toolname] != null) OmniLight(toolLights[toolname]).enabled = false;
			_toolIndex--;
	
			if (_toolIndex < 0) _toolIndex = _tools.length - 1;
			if (toolLights[toolname] != null) OmniLight(toolLights[toolname]).enabled = true;
			
			visible = true;
			active = false;
			
		}
		
		//
		//
		public function get totalEnabledTools ():int {
			
			var n:int = 0;
			
			var toolname:String;
			
			for (var i:int = 0; i < _tools.length; i++) {
				toolname = _tools[i];
				if (_toolStatuses[i] && _toolBelt[toolname]) n++;
			}
			
			return n;
			
		}
		
		public function get rotationOffset():Number { return _rotationOffset; }
		
		public function set rotationOffset(value:Number):void 
		{
			_rotationOffset = value;
		}


		//
		//
		public function nextEnabledTool ():void {
			
			if (totalEnabledTools > 0) {
				
				nextTool();
				
				while (_toolStatuses[_toolIndex] == false || _toolBelt[toolname] != true) nextTool();
				
				_events.dispatchEvent(new Event(TOOL_CHANGE));

			}
			
		}
		
		//
		//
		public function prevEnabledTool ():void {

			if (totalEnabledTools > 0) {
				
				prevTool();
				
				while (_toolStatuses[_toolIndex] == false || _toolBelt[toolname] != true) prevTool();
				
				_events.dispatchEvent(new Event(TOOL_CHANGE));

			}
			
		}
		
		//
		//
		public function setToolStatus (tname:String, status:Boolean):Boolean {
			
			if (_tools.indexOf(tname) != -1) {
				
				_toolStatuses[_tools.indexOf(tname)] = status;
				
				return true;
				
			}
			
			return false;
			
		}
		
		//
		//
		public function getToolStatus (tname:String):Boolean {
			
			if (_tools.indexOf(tname) != -1) {
				
				return _toolStatuses[indexOf(tname)];
				
			}
			
			return false;
			
		}
		
		//
		//
		public function getToolCount (tname:String):int {

			if (_tools.indexOf(tname) != -1) {
				
				var t:int = indexOf(tname);
				var ammo:int = (_toolAmmo[t] == null) ? t : indexOf(_toolAmmo[t]);
				return _toolCounts[ammo];
				
			}
			
			return 0;
			
		}
		
		public function copyTools (t:Toolset, noCounts:Boolean = false):void {
			if (t == null) return;
			for each (var tool:String in _tools) {
				trace(tool, t);
				if (t.getToolStatus(tool) && t.toolBelt[tool]) addToBelt(tool, true);
				if (!noCounts && t.getToolCount(tool) >= 0) {
					addToCount(tool, t.getToolCount(tool));
				} else {
					_toolCounts[indexOf(tool)] = t.getToolCount(tool);
				}
			}
			
		}
		
		
	}
	
}