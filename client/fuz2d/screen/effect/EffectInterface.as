package fuz2d.screen.effect {
	
	public interface EffectInterface {
		
        //
        //
        function init (parentClass:EffectManager):void;
        
        //
        //
        function activate ():void;
        
        //
        //
        function deactivate (callEnd:Boolean = false):void;
        
        //
        //
        function update ():void;
		
		//
		//
		function addLife (time:Number):void;
		
		//
		//
		function end ():void;
		
	}
	
}