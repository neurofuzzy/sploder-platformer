/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.play {
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import fuz2d.library.ObjectDefinition;
	import fuz2d.library.ObjectFactory;
	import fuz2d.library.ObjectTemplate;
	
	import fuz2d.Fuz2d;
	import fuz2d.action.behavior.*;
	import fuz2d.action.control.*;
	import fuz2d.action.physics.*;
	import fuz2d.model.*;
	import fuz2d.model.object.*;
	import fuz2d.util.Geom2d;
	

	public class PlayObjectDummy extends PlayObject {
		
		override public function get map():Boolean { return true; }

		//
		//
		public function PlayObjectDummy (main:Fuz2d, simObject:SimulationObject) {
			
			_model = main.model;
			_simulation = main.simulation;
			_playfield = main.playfield;
			
			_simObjectRef = simObject;
			_modelObjectRef = simObject.objectRef;
			
			super("dummy", null, main, null);
			
		}
		
		//
		//
		override protected function init ():void { 

		}
		
		//
		//
		override protected function create():void {
			
			_map = true;

			_playfield.addObject(this);
			
		}
		
	}
	
}
