/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.play {
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getQualifiedClassName;
	import fuz2d.library.ObjectDefinition;
	import fuz2d.library.ObjectFactory;
	import fuz2d.library.ObjectTemplate;
	
	import fuz2d.Fuz2d;
	import fuz2d.action.behavior.*;
	import fuz2d.action.control.*;
	import fuz2d.action.physics.*;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	

	public class PlayObject extends ObjectTemplate {
		
		public static const EVENT_DIE:String = "die";
		public static const EVENT_HEALTH:String = "health";
		
		override public function set main(value:Fuz2d):void 
		{
			super.main = value;
			_model = _main.model;
			_simulation = _main.simulation;
			_playfield = _main.playfield;
			
		}
		
		protected var _model:Model;
		protected var _simulation:Simulation;
		
		protected var _global:Boolean = false;
		public function get global():Boolean { return _global; }
		public function set global(value:Boolean):void { _global = value; }
		
		override public function set type(value:String):void { 
			_type = value;
			if (_simObjectRef != null) _simObjectRef.type = type;
		}
		
		override public function set group(value:String):void 
		{
			if (_global && group != null && !isNaN(counts[group])) counts[group]--;
			
			super.group = value;
			if (_simObjectRef != null) _simObjectRef.group = _group;
			
			if (_global) {
				
				if (totals[group] == undefined) totals[group] = 0;
				totals[group]++;
				
				if (counts[group] == undefined) counts[group] = 0;
				counts[group]++;
			
			}
			
		}
		
		protected var _playfield:Playfield;
		public function get playfield():Playfield { return _playfield; }

		protected var _modelObjectRef:Object2d;
		protected var _simObjectRef:SimulationObject;

		public function get model():Model { return _model; }
		public function get object ():Object2d { return _modelObjectRef; }
		public function get simObject ():SimulationObject { return _simObjectRef; }

		protected var _map:Boolean = false;
		public function get map():Boolean { return _map; }
		
		protected var _submap:Boolean = false;
		public function get submap():Boolean { return _submap; }
		
		protected var _buttress:Boolean = false;
		public function get buttress():Boolean { return _buttress; }
		
		public static var totals:Object;
		public static var counts:Object;
		
		public static var linkControllers:Array;
		public static var linkableObjects:Array;
		
		public function get data ():Array { return (_def && _def.data) ? _def.data : []; }
		
		public function get zDepth ():Number {
			
			if (_modelObjectRef) return _modelObjectRef.zDepth;
			return 1;
			
		}
	
		//
		//
		public function PlayObject (type:String, creator:Object, main:Fuz2d, def:ObjectDefinition) {
			
			super(type, creator, main, def);
			
			_model = main.model;
			_simulation = main.simulation;
			_playfield = main.playfield;	
			
			if (totals == null) totals = { };
			if (counts == null) counts = { };
			
			init();

		}
		
		//
		//
		override protected function init ():void { 
			
			super.init();
			
		}
		
		//
		//
		override protected function create():void {
			
			super.create();
			
			_modelObjectRef = _def.newModelObject();
			_simObjectRef = _def.newSimulationObject();

			if (_modelObjectRef != null) {
				_modelObjectRef.simObject = _simObjectRef;
				if (this is PlayObjectControllable) {_modelObjectRef.controlled = true;
				}
			}
			else {
				trace("ERROR: Object not created. " + type + " not found.");
			}

			_map = _def.isMappable;
			_submap = _def.isSubMappable;
			_buttress = _def.doButtress;
			
			if (_def.linkable) {
				linkableObjects.push(this);
			}

			if (_simObjectRef != null) _simObjectRef.type = _type;
			
			_playfield.addObject(this);
			
			if (_def.useCreateSound) _def.eventSound("create");
			
		}


		//
		//
		public function place (x:Number = NaN, y:Number = NaN, z:Number = NaN, rotation:Number = 0, useRadians:Boolean = true):void {
			
			var conversion:Number = 1;
			
			if (!isNaN(x)) _modelObjectRef.x = x;
			if (!isNaN(y)) _modelObjectRef.y = y;
			if (!isNaN(z)) _modelObjectRef.z = z;
			
			if (!useRadians) conversion = Geom2d.dtr;

			if (!isNaN(rotation)) _modelObjectRef.rotation = rotation;

			if (_simObjectRef != null) {
				
				_simObjectRef.getPosition();
				_simObjectRef.getOrientation();
				_simulation.updateObject(_simObjectRef);
				
			}
			
			if (_map) _playfield.map.updatePlayObject(this);
			
		}
		
		//
		//
		public static function launchNew (symbol:String, creator:PlayObject, toolset:Toolset = null, power:Number = 100, target:PlayObject = null, tripleFire:Boolean = false, launchPoint:Point = null, launchDir:Number = 0):Object {
		
			if (launchPoint == null) {
				
				if (toolset != null) {
					launchPoint = toolset.tooltip;
					launchDir = toolset.toolRotation;
				} else {
					launchPoint = new Point(creator.object.worldX, creator.object.worldY);
					if (target == null) launchDir = creator.object.rotation;
					else launchDir = 0 - Geom2d.angleBetween(creator.object, target.object);
				}
			
			}

			if (power == 0) power = 1;
			var newVel:Vector2d = new Vector2d(null, power, 0);
			newVel.rotate(0 - launchDir);

			var obj:Object = ObjectFactory.createNew(symbol, creator, launchPoint.x, launchPoint.y, 50, { velocity: newVel, rotation: launchDir } );
			if (obj is PlayObject && creator != null) PlayObject(obj).group = creator.group;
			
			//trace("LAUNCHING NEW", creator, PlayObject(obj).creator);		
			
			if (tripleFire) {
				
				newVel = newVel.copy;
				newVel.rotate(Geom2d.HALFPI / 3);
				launchDir -= Geom2d.HALFPI / 3;
				obj = ObjectFactory.createNew(symbol, creator, launchPoint.x, launchPoint.y, 50, { velocity: newVel, rotation: launchDir, useCreateSound: false } );
				if (obj is PlayObject && creator != null) PlayObject(obj).group = creator.group;
				
				newVel = newVel.copy;
				newVel.rotate(0 - Geom2d.HALFPI / 1.5);
				launchDir += Geom2d.HALFPI / 1.5;
				obj = ObjectFactory.createNew(symbol, creator, launchPoint.x, launchPoint.y, 50, { velocity: newVel, rotation: launchDir, useCreateSound: false } );
				if (obj is PlayObject && creator != null) PlayObject(obj).group = creator.group;
				
			}
			
			return obj;
			
		}
		
		//
		//
		public function repel (obj:PlayObjectMovable, power:Number = 0):void {

			var ang:Number;
			var v:Vector2d;

			if (obj.simObject != null && obj.simObject is MotionObject) {
				
				if (!obj.deleted && obj.object != null && !obj.object.deleted) {
					
					ang = Geom2d.angleBetweenPoints(_modelObjectRef.point, obj.object.point);
					v = new Vector2d(null, power, 0);
					v.rotate(ang);
					
					MotionObject(obj.simObject).addForce(v);
				
				}
				
			}

		}
		
		//
		//
		public static function hitTestTool (playObject:PlayObject, toolset:Toolset, collisionObjectType:int = -1, reactionType:int = -1, tolerance:Number = 0, overridePoint:Point = null):PlayObject {
		
			var pt:Point = (overridePoint == null) ? toolset.tooltip : overridePoint;
			var obj:SimulationObject = playObject.simObject.simulation.getObjectAtPoint(pt, playObject.simObject, collisionObjectType, reactionType, tolerance);
			
			if (obj != null) return playObject.playfield.playObjects[obj];
			
			return null;
			
		}
		
		public static function boundingTest (playObject:PlayObject, point:Point):Boolean {
			
			var obj:Object2d = playObject.object;
			
			return (point.x >= obj.x - obj.width * 0.5 &&
				point.x <= obj.x + obj.width * 0.5 &&
				point.y >= obj.y - obj.height * 0.5 &&
				point.y <= obj.y + obj.height * 0.5);
				
		}
		
		//
		//
		public static function hitTestSegment (playObject:PlayObject, toolset:Toolset, length:Number):Object {
		
			var ptA:Point = toolset.tooltip;
			var ptB:Point = Point.polar(length, 0 - toolset.toolRotation);
			ptB = ptB.add(ptA);
			
			var result:Object = playObject.simObject.simulation.getObjectAtSegment(ptA, ptB, playObject.simObject);
			
			if (result != null && playObject.playfield.playObjects[result.obj] != undefined) return { obj: playObject.playfield.playObjects[result.obj], pt: result.pt };
			
			return null;
			
		}
		
		//
		//
		public function eventSound (eventName:String, volFactor:Number = 1):SoundChannel {
			
			var s:SoundChannel = _def.eventSound(eventName);
			if (s && volFactor != 1) {
				var st:SoundTransform = s.soundTransform;
				st.volume = Math.min(1, volFactor);
				s.soundTransform = st;
			}
			return s;
			
		}
		
		//
		//
		protected function die ():void {
			
			if (!_deleted && _global && _group != null && _group.length > 0 && !isNaN(counts[_group])) {
				counts[_group]--;
			}			
			
		}
		
		//
		//
		override public function destroy ():void {
			
			_playfield.dispatchEvent(new PlayfieldEvent(PlayfieldEvent.REMOVE, false, false, this));
	
			_playfield.removeObject(this);
			
			if (_modelObjectRef != null) _modelObjectRef.destroy();
			if (_simObjectRef != null) _simObjectRef.destroy();

			_modelObjectRef = null;
			_simObjectRef = null;
			
			_deleted = true;
			
			eventSound("destroy");
			
			super.destroy();

			delete this;

		}
		
	}
	
}
