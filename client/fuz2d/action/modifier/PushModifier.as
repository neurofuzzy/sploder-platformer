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
	public class PushModifier extends Modifier {
		
		protected var _r:Number = 0;
		protected var _visuals:DisplayObject;
		
		protected var _vector:Vector2d;
		
		//
		//
		public function PushModifier (x:Number = 0, y:Number = 0) {
			
			super();
			
			_vector = new Vector2d(null, x, y);
			
		}
		
		override protected function init (parentClass:ModifierManager = null):void 
		{
			super.init(parentClass);
			
			_type = "Push";
			_lifeSpan = 250;
			
		}
		
		//
		//
		override public function update(e:Event):void 
		{
			super.update(e);

			MotionObject(_parentClass.simObject).applyImpulse(_vector);
		
		}

	}
	
}