package fuz2d.screen.effect 
{
	import com.sploder.*;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class InvisibleEffect extends Effect {
		
		protected var _r:Number = 0;
		//
		//
		public function InvisibleEffect (parentClass:EffectManager = null) {
			
			super(parentClass);
			
		}
		

        //
        //
        override public function init (parentClass:EffectManager = null):void {
			
			super.init(parentClass);
			
			_type = "Invisible";
			_lifeSpan = 15000;
			
		}
		
		//
		//
		override public function update ():void {
			
			super.update();

		}
		
		//
		//
		override public function activate():void {
			
			super.activate();
			_parentClass.obj.alpha = 0.4;
			_parentClass.obj.invisible = true;
			
		}
		
		//
		//
		override public function deactivate(callEnd:Boolean = false):void {
			
			super.deactivate(callEnd);
			_parentClass.obj.alpha = 1;
			_parentClass.obj.invisible = false;
			
		}
		
		
	}
	
}