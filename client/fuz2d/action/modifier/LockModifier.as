package fuz2d.action.modifier  {
	
	import flash.events.Event;
	import fuz2d.action.modifier.*;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.Vector2d;
	
	import flash.display.DisplayObject;

	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class LockModifier extends Modifier {
		
		//
		//
		public function LockModifier (duration:Number) {
			
			super();
			
			_lifeSpan = duration;
			
		}
		
		override protected function init (parentClass:ModifierManager = null):void 
		{
			super.init(parentClass);
			
			_type = "Lock";
			
			_parentClass.playObject.locked = true;
			
		}
		
		//
		//
		override public function update(e:Event):void 
		{
			super.update(e);
			
			if (!_parentClass.playObject.locked) _parentClass.playObject.locked = true;
			if (_complete) end();
			
		}
		
		override public function deactivate(callEnd:Boolean = false):void 
		{
			_parentClass.playObject.locked = false;
			super.deactivate(callEnd);
		}
		
		override public function end():void 
		{
			_parentClass.playObject.locked = false;
			super.end();
		}

	}
	
}