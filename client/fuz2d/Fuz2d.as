/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/


package fuz2d {
	
	import flash.display.CapsStyle;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import fuz2d.action.control.PowerUpController;
	import fuz2d.action.control.SwitchController;
	import fuz2d.action.control.TeleportController;
	import fuz2d.library.*;
	import fuz2d.model.object.Object2d;
	import fuz2d.screen.BitView;
	import fuz2d.util.Key;
	import fuz2d.util.TileDefinition;
	
	import fuz2d.action.animation.TweenManager;
	import fuz2d.action.play.PlayObject;
	import fuz2d.action.physics.Simulation;
	import fuz2d.action.play.Playfield;
	import fuz2d.model.*;
	import fuz2d.model.environment.*;
	import fuz2d.screen.View;
	import fuz2d.sound.SoundManager;
	import fuz2d.util.FpsCounter;
	
	//
	//
	public class Fuz2d extends Sprite {
		
		public static const INITIALIZED:String = "fuz2d_initialized";
		
		public static var mainInstance:Fuz2d;
		public static var library:EmbeddedLibrary;
		public var model:Model;
		public var view:View;
		public var camera:Camera2d;
		public var simulation:Simulation;
		public var playfield:Playfield;
		
		public var viewClass:Class = View;

		public static var environment:Environment;
		
		public static var sounds:SoundManager;
		
		public static var tweenManager:TweenManager;
		
		public var onInitialized:Function;

		//
		//
		public function Fuz2d (mainStage:Stage = null, librarySWF:Class = null, soundLibrarySWF:Class = null):void {
			
			super();

			init(mainStage, librarySWF, soundLibrarySWF);
			
		}
		
		//
		//
		public function init (mainStage:Stage = null, librarySWF:Class = null, soundLibrarySWF:Class = null):void {
			
			trace("FUZ2D INIT");
			
			mainInstance = this;
			
			if (stage != null) {

				View.mainStage = stage;
				View.frameRate = stage.frameRate;
				
			} else if (mainStage != null) {
				
				View.mainStage = mainStage;
				View.frameRate = mainStage.frameRate;	
				
			}
			
			TimeStep.reset();
			
			tweenManager = new TweenManager();
			
			model = new Model();
			environment = model.environment;
			
			simulation = new Simulation(this, model, 110);
			playfield = new Playfield(this, model, simulation);

			if (librarySWF != null) initializeLibrary(librarySWF);
			else build();

			tweenManager.start();
			
		}
		
		//
		//
		public function end ():void {
			
			trace("FUZ2D END");
			
			if (view) try { view.end(); } catch (e:Error) { trace("VIEW END ERROR:", e.getStackTrace()) }
			if (model) try { model.end(); } catch (e:Error) { trace("MODEL END ERROR:", e.getStackTrace()) }
			if (playfield) try { playfield.end(); } catch (e:Error) { trace("PLAYFIELD END ERROR:", e.getStackTrace()) }
			if (simulation) try { simulation.end(); } catch (e:Error) { trace("SIMULATION END ERROR:", e.getStackTrace()) }
			
			view = null;
			model = null;
			playfield = null;
			simulation = null;
			environment = null;
			
			PowerUpController.counts = null;
			PowerUpController.totals = null;
			PlayObject.counts = null;
			PlayObject.totals = null;
			TeleportController.teleporters = null;
			SwitchController.switches = null;
			
			SoundManager.stopAll();
			library = null;
			
			if (tweenManager) {
				tweenManager.stop();
				tweenManager.end();
				tweenManager = null;
			}
			
			mainInstance = null;
			
			Key.reset();

		}
		
		
		//
		//
		public function initializeLibrary (LibrarySWF:Class):void {
			
			library = new EmbeddedLibrary(LibrarySWF, false);	
			library.addEventListener(Event.INIT, onLibraryInitialized);		
			
		}
		
		
		//
		//
		protected function onLibraryInitialized (e:Event):void {
			
			library.removeEventListener(EmbeddedLibrary.INITIALIZED, onLibraryInitialized);
			
			EmbeddedLibrary.grid_width = TileDefinition.grid_width = Model.GRID_WIDTH;
			EmbeddedLibrary.grid_height = TileDefinition.grid_height = Model.GRID_HEIGHT;

			dispatchEvent(new Event(INITIALIZED));
			
			build();
			
		}
		
		//
		//
		public function initView (model:Model = null, camera:Camera2d = null, viewRange:Number = 10000, container:Sprite = null, width:Number = 0, height:Number = 0, x:Number = 0, y:Number = 0, roughSort:Boolean = true, pixelSnap:Boolean = true, fastDraw:Boolean = false, showCounter:Boolean = false):void {
			
			if (model == null) model = this.model;
			if (model == null) model = this.model = new Model();
			
			if (camera == null) camera = this.camera;
			if (camera == null) camera = this.camera = new Camera2d(0, 0);
			
			if (model.environment.lights.length == 0) model.environment.addLight(model.environment.defaultLight);
			
			view = new viewClass(this, model, camera, viewRange, width, height, x, y, roughSort, container, pixelSnap, fastDraw, true);
			
			
		}
		
		//
		//
		public static function createSoundManager (swf:Class):void {
			
			if (sounds == null) sounds = new SoundManager(swf);
			
		}
		
		//
		//
		protected function build ():void {

			buildModel(model);
			buildEnvironment(model.environment);
			
		}
		
		protected function buildEnvironment (env:Environment):void { }
		protected function buildModel (model:Model):void { }
		
		//
		//
		public function createNew (objType:String, creator:Object):ObjectTemplate {
			
			var newObject:ObjectTemplate
			
			switch (objType) {
				
				default:
				
			}
			
			return newObject;
			
		}
		
		
		
	}
	
}
