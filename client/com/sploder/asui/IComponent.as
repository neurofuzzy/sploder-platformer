package com.sploder.asui {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
    
    public interface IComponent {

        
        function create ():void;

		
        function enable (e:Event = null):void;

        
        function disable (e:Event = null):void;

    
        function show (e:Event = null):void;

        
        function hide (e:Event = null):void;

    
        function destroy ():Boolean;
    
    }
}
