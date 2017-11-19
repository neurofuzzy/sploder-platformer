package fuz2d.library {
	
	import flash.events.EventDispatcher;
	import fuz2d.action.physics.SimulationObject;
	import fuz2d.action.play.PlayObject;
	
	import fuz2d.*;

	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class ObjectTemplate extends EventDispatcher {
		
		protected var _main:Fuz2d;
		public function get main():Fuz2d { return _main; }
		public function set main(value:Fuz2d):void 
		{
			_main = value;
		}

		protected var _def:ObjectDefinition;
		
		protected var _type:String;
		public function get type ():String  { return _type; }
		public function set type(value:String):void { _type = value; }
				
		
		protected var _group:String;
		protected var _startGroup:String;
		public function get group ():String  { return _group; }
		public function set group(value:String):void { 
			if (_startGroup == null) _startGroup = value; 
			_group = value;
			}
		public function resetGroup ():void { _group = _startGroup; }
		
		protected var _creator:Object;
		public function get creator():Object { return _creator; }
		public function isCreator (obj:Object):Boolean {
			if (obj is PlayObject) {
				return (PlayObject(obj) == _creator);
			} else if (obj is SimulationObject) {
				if (_creator is PlayObject) {
					return (obj == PlayObject(_creator).simObject);
				} else if (_creator is SimulationObject) {
					return (obj == _creator);
				}
			}
			return false;
		}
	
		protected var _deleted:Boolean = false;
		public function get deleted():Boolean { return _deleted; }

		//
		//
		public function ObjectTemplate (type:String, creator:Object, main:Fuz2d, def:ObjectDefinition) {
			
			_type = type;
			_creator = creator;
			_def = def;
			if (_def != null) _def.child = this;
			
			_main = main;	
			
		}
		
		//
		//
		protected function init ():void { 
			
			create();
			
		}
		
		//
		//
		protected function create ():void {
			

		}
		
		//
		//
		public function destroy ():void {
	
			_deleted = true;

			delete this;

		}
		
		//
		//
		public function isType (type:String):Boolean {
			
			return (type == _type);
			
		}
		
	}
	
}