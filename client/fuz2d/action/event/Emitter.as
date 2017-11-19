/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d.action.event {
	
	import flash.utils.Timer;
	
	import fuz2d.model.object.Particle;
	import fuz2d.model.object.ParticleSystem;

	public class Emitter {
		
		private var _parentClass:ParticleSystem;

		private var _spawnRate:uint;
		private var _spreadAngle:Number;
		
		private var _particle:Particle;
		
		private var _timer:Timer;

		
		//
		//
		//
		public function Emitter (parentClass:ParticleSystem, spawnRate:uint = 10, spreadAngle:Number = 180, particle:Particle) {
			
			init(parentClass, spawnRate, spreadAngle);
			
		}
		
		//
		//
		//
		public function init (parentClass:ParticleSystem, spawnRate:uint = 10, spreadAngle:Number = 180, particleSize:Number = 1, particleColor:uint = 0xffffff, particleSpeed:Number = 1):void {
			
			_parentClass = parentClass;
			_spawnRate = spawnRate;
			_spreadAngle = spreadAngle;
			
		}
		
		
	}
	
}
