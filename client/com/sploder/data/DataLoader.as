package com.sploder.data 
{
	
	import flash.utils.getTimer;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.*;
	import flash.events.IOErrorEvent;
	import flash.xml.*;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class DataLoader extends EventDispatcher {
		
		public static const CACHE_OK:String = "cacheok";
		
		protected var _root:DisplayObject;
		public function get loaderInfo ():LoaderInfo { return _root.loaderInfo; }
		
	    protected var _baseURL:String = "";
		public function get baseURL():String { return _baseURL; }
		public function set baseURL(value:String):void { 
			_baseURL = value; 
			if (_baseURL.charAt(_baseURL.length - 1) == "/") _baseURL = _baseURL.substr(0, _baseURL.length - 1);
		}
	
		protected var _embedParameters:Object;
		public function get embedParameters():Object { return (_embedParameters == null) ? parseEmbedParameters() : _embedParameters; }
		
		protected var _metadataLoader:URLLoader;
		protected var _metadataRequest:URLRequest;
		protected var _metadataVars:URLVariables;
		public function get metadata():URLVariables { return _metadataVars; }
		
		protected var _dataXMLLoader:URLLoader;
		public function get dataXMLLoader():URLLoader { return _dataXMLLoader; }
		protected var _dataXMLRequest:URLRequest;
		
		protected var _src:String;
		public function get src():String { return _src; }
		
		protected var _xml:XML;
		public function get xml():XML { return _xml; }
		
		
		
		
		//
		//
		public function DataLoader (root:DisplayObject, baseURL:String = "") {
			
			init(root, baseURL);
			
		}
		
		//
		//
		public function init (root:DisplayObject, baseURL:String = ""):void {
			
			_root = root;
			_baseURL = baseURL;

			_metadataVars = new URLVariables();
			
		}
		
		//
		//
		protected function parseEmbedParameters ():Object {

			if (_root.loaderInfo != null && LoaderInfo(_root.loaderInfo).parameters != null) {
				
				_embedParameters = LoaderInfo(_root.loaderInfo).parameters;

				return _embedParameters;
				
			}
				
			return null;
			
		}
		
		//
		//
		public function loadMetadata (metadataURL:String, useBaseURL:Boolean = true, callback:Function = null):void {

			_metadataLoader = new URLLoader();
			
			
			
			if (callback != null) {
				_metadataLoader.addEventListener(Event.COMPLETE, callback);
			} else {
				_metadataLoader.addEventListener(Event.COMPLETE, onMetadataLoaded);
			}
			
			_metadataRequest = new URLRequest((useBaseURL ? baseURL : "") + metadataURL);
			
			_metadataLoader.addEventListener(IOErrorEvent.IO_ERROR, onMetadataError);
			_metadataLoader.load(_metadataRequest);
			
		}
		
		public function send (url:String, paramString:String, okToCache:Boolean = false):void {
			
			var loader:URLLoader = new URLLoader();
			loader.load(new URLRequest(url + getCacheString(paramString, okToCache ? CACHE_OK : "")));
			
		}
		
		//
		//
		public function onMetadataLoaded (e:Event):void {
			
			var loader:URLLoader = URLLoader(e.target);
			var urlVars:String = loader.data;
			
			if (urlVars.charAt(0) == "&") urlVars = urlVars.replace("&", "");
			
			_metadataVars = new URLVariables();
			try {
				_metadataVars.decode(urlVars);
			} catch (e:Error) {
				trace("Error loading game metadata: " + e);
			}
			
			dispatchEvent(new DataLoaderEvent(DataLoaderEvent.METADATA_LOADED, false, false, _metadataVars));
			
		}
		
		//
		//
		public function onMetadataError (e:IOErrorEvent):void {
			
			dispatchEvent(new DataLoaderEvent(DataLoaderEvent.METADATA_ERROR, false, false));
			
		}
		
		//
		//
		public function loadXMLData (dataURL:String, useBaseURL:Boolean = true, callback:Function = null, errorCallback:Function = null):void {
			
			_dataXMLRequest = new URLRequest((useBaseURL ? baseURL : "") + dataURL);
			trace(_dataXMLRequest.url);
			_dataXMLLoader = new URLLoader(_dataXMLRequest);
			if (callback != null) {
				_dataXMLLoader.addEventListener(Event.COMPLETE, callback);
			} else {
				_dataXMLLoader.addEventListener(Event.COMPLETE, onXMLDataLoaded);
			}
			if (errorCallback != null) {
				_dataXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, errorCallback);
			} else {
				_dataXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLDataError);
			}
				
			_dataXMLLoader.load(_dataXMLRequest);
				
		}
		
		//
		//
		public function onXMLDataLoaded (e:Event):void {
		
			_src = e.target.data;
			
			_xml = new XML(_src);
			
			dispatchEvent(new DataLoaderEvent(DataLoaderEvent.DATA_LOADED, false, false, _src));
			
		}
		
		//
		//
		public function onXMLDataError (e:Event):void {

			dispatchEvent(new DataLoaderEvent(DataLoaderEvent.DATA_ERROR, false, false));
			
		}
		
        //
        //
        //
        public function getCacheString (urlstring:String = "", cache:String = ""):String {
            
            var nocache:String;
            var sessionstring:String;
            
            if (cache != "cacheok") {
                nocache = "&nocache=" + getTimer();
            } else {
                nocache = "";
            }
            
            if (embedParameters.PHPSESSID != null && embedParameters.PHPSESSID.length > 1) {
                sessionstring = "?PHPSESSID=" + embedParameters.PHPSESSID;
            } else {
                sessionstring = "?nosession=1";
            }
            
            if (urlstring.length > 0) {
                return sessionstring + "&" + urlstring + nocache;
            } else {
                return sessionstring + nocache;
            }
            
        }
		
	}
	
}