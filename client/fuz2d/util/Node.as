/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {
	
	import fuz2d.util.*;
	
	public class Node {

		protected var _x:Number;
		protected var _y:Number;
		protected var _isControlNode:Boolean = false;
		
		//
		public function get x ():Number {
			return _x;	
		}
		public function set x (val:Number):void {
			_x = (isNaN(val)) ? _x : val;	
		}
		
		//
		public function get y ():Number {
			return _y;	
		}
		public function set y (val:Number):void {
			_y = (isNaN(val)) ? _y : val;
		}
		
		//
		public function get isControlNode ():Boolean {
			return _isControlNode;
		}
		
		//
		//
		public function Node (x:Number, y:Number, isControlNode:Boolean = false) {
		
			init(x, y, isControlNode);
			
		}
		
		//
		//
		private function init (x:Number, y:Number, isControlNode:Boolean = false):void {
		
			_x = x;
			_y = y;
			
			_isControlNode = isControlNode;
						
		}

		//
		//
		public function copy (prevNode:Node = null):Node {
			
			return new Node(_x, _y, _isControlNode);
			
		}
		
		//
		//
		public function getInterpolatedNodes (prevNode:Node, nextNode:Node, curveSegments:uint = 5):NodeSet {
			
			var newNodes:NodeSet = new NodeSet();
		
			if (isControlNode) {
				
				var iNode:Node;
				
				var t:Number;
				
				var xQ0:Number;
				var yQ0:Number;
				var xQ1:Number;
				var yQ1:Number;
				
				var ix:Number;
				var iy:Number;
				
				for (var i:int = 1; i <= curveSegments; i++) { 
				
					t = i / curveSegments;
					
					xQ0 = (prevNode.x + (_x - prevNode.x) * t);
					yQ0 = (prevNode.y + (_y - prevNode.y) * t);
					
					xQ1 = (_x + (nextNode.x - _x) * t);
					yQ1 = (_y + (nextNode.y - _y) * t);
					
					ix = xQ0 + (xQ1 - xQ0) * t;
					iy = yQ0 + (yQ1 - yQ0) * t;

					iNode = newNodes.addNode(new Node(ix, iy, false), true);

				}
				
			}
			
			return newNodes;
			
		}
		
	}
	
}
