package fuz2d.screen.effect  {
	
	import com.sploder.*;
	
	import flash.display.DisplayObject;

	
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class InvincibleEffect extends Effect {
		
		protected var _r:Number = 0;
		protected var _visuals:DisplayObject;
		
		//
		//
		public function InvincibleEffect (parentClass:EffectManager = null) {
			
			super(parentClass);
			
		}
		

        //
        //
        override public function init (parentClass:EffectManager = null):void {
			
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
		override public function deactivate(callEnd:Boolean = false):void {
			
			super.deactivate(callEnd);
			if (_parentClass.obj.getChildIndex(_visuals) != -1) _parentClass.obj.removeChild(_visuals);
			_parentClass.obj.invincible = false;
			
		}
		
		
	}
	
}