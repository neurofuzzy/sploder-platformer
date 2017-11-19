package fuz2d.action.modifier {
	
	import flash.events.*;
	
	public interface ModifierInterface {
		
        //
        //
        function activate ():void;
        
        //
        //
        function deactivate (callEnd:Boolean = false):void;
        
        //
        //
        function update (e:Event):void;
		
		//
		//
		function addLife (time:Number):void;
		
	}
	
}