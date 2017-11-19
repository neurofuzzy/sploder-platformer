package fuz2d.action.modifier  {
	
	import fuz2d.action.modifier.*;
	
	import flash.display.DisplayObject;

	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class InvincibleModifier extends Modifier {
		
		protected var _r:Number = 0;
		protected var _visuals:DisplayObject;
		
		//
		//
		public function InvincibleModifier (parentClass:ModifierManager = null) {
			
			super(parentClass);
			
		}
		

        //
        //
        override public function init (parentClass:ModifierManager = null):void {
			
			super.init(parentClass);
			
			_type = "Invincible";
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
			_visuals = _parentClass.obj.attachMovie("invincibleSymbol");
			_parentClass.obj.invincible = true;
			
		}
		
		//
		//
		override public function deactivate (callEnd:Boolean = false):void {
			
			if (_parentClass.obj.getChildIndex(_visuals) != -1) _parentClass.obj.removeChild(_visuals);
			_parentClass.obj.invincible = false;
			
			super.deactivate(callEnd);
			
		}
		
		
	}
	
}