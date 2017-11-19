package fuz2d.screen.shape 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import fuz2d.model.object.TurretSymbol;
	import fuz2d.screen.View;
	import fuz2d.util.Geom2d;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class TurretAssetDisplay extends AssetDisplay
	{
		
		protected var _turret:Sprite;
		
		public function TurretAssetDisplay (view:View, container:ViewSprite) 
		{
			super(view, container);
			
			assign();
		}
		
		//
		//
		protected function assign ():void {
			
			_turret = _clip["turret"];
			
		}
		
		//
		//
	    override protected function draw(g:Graphics, clear:Boolean = true):void {
		
			super.draw(g, clear);
			
			if (_container.objectRef == null) return;
			
			_turret.rotation = TurretSymbol(_container.objectRef).turretAngle * Geom2d.rtd;
			
		}
		
	}

}