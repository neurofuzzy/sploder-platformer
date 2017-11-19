package fuz2d.action.control 
{
	import fuz2d.action.control.Controller;
	import fuz2d.action.play.PlayObjectControllable;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class BurstController extends PlayObjectController
	{
		
		public function BurstController(object:PlayObjectControllable) 
		{
			super(object);
			
		}
		
		override public function signal(signaler:Controller, message:String = ""):void 
		{
			super.signal(signaler, message);
			
			_object.kill();
			
		}
		
	}

}