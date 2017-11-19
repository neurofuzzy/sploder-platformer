package fuz2d.util 
{
	import com.adobe.serialization.json.JSONEncoder;

	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Grid {
		
		protected var _width:uint;
		public function get width():uint { return _width; }
		
		protected var _height:uint;
		public function get height():uint { return _height; }
		
		protected var _data:Array;
		
		public function get length():uint { return _width * _height; }
		
		//
		//
		public function Grid (width:uint, height:uint) {
			
			init(width, height);
			
		}
		
		//
		//
		protected function init (width:uint, height:uint):void {
			
			_data = [];
			_width = width;
			_height = height;
			
			fill();

		}
		
		//
		//
		protected function idx (x:uint, y:uint):uint {
			
			return _width * y + x;
			
		}
		
		//
		//
		public function getVal (x:int, y:int):* {
			
			if (x < 1 || x > _width) return null;
			if (y < 1 || y > _height) return null;
	
			return _data[idx(x-1, y-1)];
			
		}
		
		//
		//
		public function setVal (x:uint, y:uint, value:*):void {
			
			if (x < 1 || x > _width) return;
			if (y < 1 || y > _height) return;
			
			_data[idx(x-1, y-1)] = value;
			
		}
		
		//
		//
		//
		public function clear ():void {
			
			_data = [];
			
		}
		
		//
		//
		protected function fill ():void {
			for (var i:int = 0; i < _width * _height; i++) _data.push(0);
		}
		
		//
		//
		public function trim (width:uint, height:uint):void {
			
			if (width > _width || _height > height) return;
			
			var _dataCopy:Array = [];
			
			for (var j:int = 0; j < height; j++) {
				
				for (var i:int = 0; i < width; i++) {
					
					_dataCopy.push(getVal(i, j));
					
				}				
				
			}
			
			_data = _dataCopy;
			
		}
		
		//
		//
		public function toString ():String {
			
			var enc:JSONEncoder = new JSONEncoder( { width: _width, height: _height, data: _data } );
			
			return enc.getString();
			
		}

		
	}
	
}