package fuz2d.action.modifier 
{
	import fuz2d.action.modifier.*;
	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class InvisibleModifier extends Modifier {
		
		protected var _r:Number = 0;
		//
		//
		public function InvisibleModifier (parentClass:ModifierManager = null) {
			
			super(parentClass);
			
		}
		

        //
        //
        override public function init (parentClass:ModifierManager = null):void {
			
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
		override public function deactivate(end:Boolean = false):void {
			
			super.deactivate(end);
			_parentClass.obj.alpha = 1;
			_parentClass.obj.invisible = false;
			
		}
		
		
	}
	
}