package fuz2d.action.modifier  {
	
	import flash.events.Event;
	import fuz2d.action.behavior.JumpBehavior;
	import fuz2d.action.modifier.*;
	import fuz2d.action.physics.MotionObject;
	import fuz2d.action.physics.Vector2d;
	import fuz2d.action.play.BipedObject;
	import fuz2d.model.object.Biped;
	
	import flash.display.DisplayObject;

	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class RollModifier extends Modifier {
		
		protected var _r:Number = 0;

		protected var _biped:BipedObject;
		protected var _vector:Vector2d;
		
		protected var _rollSpeed:Number = 20;
		
		//
		//
		public function RollModifier () {
			
			super();
			
		}
		
		override protected function init (parentClass:ModifierManager = null):void 
		{
			super.init(parentClass);
			
			_type = "Roll";
			_lifeSpan = 1000;
			
			var x:Number = 0;
			
			_biped = BipedObject(_parentClass.playObject);
			
			if (_biped.lastJump && _biped.lastJump.direction != JumpBehavior.CENTER) {
				
				if (_biped.lastJump.direction == JumpBehavior.LEFT) x = 0 - _rollSpeed;
				else x = _rollSpeed;

			} else {
				if (_biped.body.facing == Biped.FACING_LEFT) x = 0 - _rollSpeed;
				else if (_biped.body.facing == Biped.FACING_RIGHT) x = _rollSpeed;
				else {
					end();
					return;
				}
			}
			
			_biped.body.state = Biped.STATE_ROLLING;
			_biped.rolling = true;
			
			_vector = new Vector2d(null, x, 0);
			
		}
		
		//
		//
		override public function update(e:Event):void 
		{
			super.update(e);

			MotionObject(_parentClass.simObject).applyImpulse(_vector);
			
			if (!_biped.crouching) {
				deactivate(true);
				end();
			}
		
		}
		
		override public function deactivate(callEnd:Boolean = false):void 
		{
			_biped.body.state = Biped.STATE_NORMAL;
			_biped.rolling = false;
			
			super.deactivate(callEnd);
		}

	}
	
}