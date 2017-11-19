/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {

	import flash.geom.Point;
	import flash.utils.Dictionary;
	import fuz2d.util.*;
	
	public class NodeSet {
		
		protected var _nodes:Array;
		protected var _connections:Array;
		
		protected var _realNodes:Number = 0;
		protected var _controlNodes:Number = 0;
		
		//
		public function get nodes ():Array {
			return _nodes;
		}
		
		//
		//
		public function get nodesAsPoints ():Array {
			
			var pts:Array = [];
			
			for (var i:int = 0; i < _nodes.length; i++) {
				
				pts.push(new Point(Node(_nodes[i]).x, Node(_nodes[i]).y));
				
			}
			
			return pts;
			
		}

		//
		public function get connections ():Array {
			return _connections;
		}
		
		//
		public function get length ():uint {
			return _realNodes;
		}
		
		//
		public function get interpolatedLength ():uint {
			return _realNodes + _controlNodes;	
		}
		
		protected var _curveSegments:Number = 3;
		//
		public function get curveSegments ():uint {
			return _curveSegments;
		}
		public function set curveSegments (val:uint):void {
			_curveSegments = (isNaN(val)) ? _curveSegments : val;
		}
		
		//
		public function get firstNode ():Node {
			return (_nodes.length > 0) ? _nodes[0] : null;
		}
		
		//
		public function get lastNode ():Node {
			return (_nodes.length > 0) ? _nodes[_nodes.length - 1] : null;
		}
		
		//
		//
		public function NodeSet(nodeArray:Array = null) {
		
			init(nodeArray);
			
		}
		
		//
		//
		protected function init (nodes:Array = null):void {
			
			_nodes = [];
			_connections = [];

			if (nodes != null) {
				
				for (var i:int = 0; i < nodes.length; i++) {
					
					if (nodes[i].length > 3) { // if curve
						
						addNode(new Node(nodes[i][1], nodes[i][2], true), true);
						addNode(new Node(nodes[i][3], nodes[i][4]), true);
						_realNodes++;
						_controlNodes++;
						
					} else { // if line
						
						addNode(new Node(nodes[i][1], nodes[i][2]), nodes[i][0]);
						_realNodes++;
						
					}

				}
				
			}
			
			if (Geom2d.isConvex(_nodes)) {
				reverse();
			}
			
		}
		
		//
		//
		public function repair ():void {
			
			var nodes2:Array = _nodes.concat();
			var connections2:Array = _connections.concat();
			
			var i:uint;
			var j:uint;
			var k:uint;
			
			var totalShapes:uint = 0;
			var shapes:Object;
					
			var prevMinX:Number;
			var prevMinY:Number;
			var prevMaxX:Number;
			var prevMaxY:Number;
			
			var minX:Number;
			var minY:Number;
			var maxX:Number;
			var maxY:Number;
			
			var px:Number;
			var py:Number;
			
			var start:uint = 0;
			var end:uint = 0;
			
			var isConvex:Boolean;
			
			var subNodes:Array;

			var shapeDepth:uint = 1;
			var subShapeBounds:Array = [];
			var subShapeDepths:Array = [];
			var subShapeConvexity:Array = [];
			
			var topLevelIsConvex:Boolean;
			
			// find bounds for all subshapes
			
			minX = 100000;
			minY = 100000;
			maxX = -100000;
			maxY = -100000;
						
			for (i = 0; i < _connections.length; i++) {
				
				px = nodeAt(i).x;
				py = nodeAt(i).y;
				
				if (_connections[i] != false) {
				
					minX = Math.min(minX, px);
					minY = Math.min(minY, py);
					maxX = Math.max(maxX, px);
					maxY = Math.max(maxY, py);
					
				}
				
				if ((_connections[i] === false && i > 0) || (i == _connections.length - 1)) {
					
					totalShapes++;
					subShapeBounds.push( { minX: minX, minY: minY, maxX: maxX, maxY: maxY } );
				
					minX = 100000;
					minY = 100000;
					maxX = -100000;
					maxY = -100000;
					
				}
				
			}
			
			// find depths for all subshapes by comparing bounds
			
			for (j = 0; j < subShapeBounds.length; j++) {
				
				shapeDepth = 1;
				
				for (i = 0; i < subShapeBounds.length; i++) {
					if (i != j) {
						if (isWithin(subShapeBounds[j], subShapeBounds[i])) {
							shapeDepth++;
						}
					}
				}
				
				subShapeDepths.push(shapeDepth);

			}
			
			// find convexity for all subshapes
			
			start = 0;
			
			for (i = 0; i < _connections.length; i++) {

				if ((_connections[i] === false && i > 0) || (i == _connections.length - 1)) {
					
					end = i;
					subShapeConvexity.push(Geom2d.isConvex(_nodes.slice(start, end)));
					start = end;
					
					if (subShapeDepths[subShapeConvexity.length-1] == 1) {
						topLevelIsConvex = subShapeConvexity[subShapeConvexity.length - 1];
					}
					
				}
			
			}
			
			// reverse subshapes if necessary
			
			j = 0;
			
			for (i = 0; i < _connections.length; i++) {

				if ((_connections[i] === false && i > 0) || (i == _connections.length - 1)) {
					
					if (topLevelIsConvex == subShapeConvexity[j] && (subShapeDepths[j] % 2 == 0)) {
						
						subNodes = nodes2.splice(start , i - start);
						
						subNodes.reverse();
						
						if (subNodes.length > 0) {
							
							for (k = 0; k < subNodes.length; k++) {
								nodes2.splice(start + k, 0, subNodes[k]);
							}
							
						}

					}
						
					j++;
					
					start = i;
					
				}
				
			}
			
			_nodes = nodes2;
			
		}
		
		//
		//
		public function isWithin (obj:Object, bounds:Object):Boolean {
			
			var objWidth:Number = Math.abs(obj.maxX - obj.minX);
			var objHeight:Number = Math.abs(obj.maxY - obj.minY);
			var boundsWidth:Number = Math.abs(bounds.maxX - bounds.minX);
			var boundsHeight:Number = Math.abs(bounds.maxY - bounds.minY);	
			
			if ( (obj.maxX <= bounds.minX || obj.minX >= bounds.maxX) || (obj.maxY <= bounds.minY || obj.minY >= bounds.maxY) ) {
				return false;
			}
			
			if ( objWidth > boundsWidth || objHeight > boundsHeight) {
				return false;
			}
			
			return true;
			
		}
		
		//
		//
		public function addNode (node:Node, connect:Boolean = true):Node {
			
			_nodes.push(node);
			_connections.push(connect);
			
			if (lastNode.isControlNode) {
				_controlNodes++;
			} else {
				_realNodes++;
			}
			
			return lastNode;
			
		}
		
		//
		//
		public function addNodes (nodes:NodeSet):void {

			for (var i:int = 0; i < nodes.length; i++) {
				addNode(nodes.nodeAt(i), nodes.connectionAt(i));
			}
			
		}
		
		//
		//
		public function removeNode (node:Node):Boolean {
			
			var nodeIndex:int = _nodes.indexOf(node);
			var spliceNum:int = 1;
			var spliceOffset:int = 0;
			
			if (nodeIndex != -1) {
				
				if (nodeIndex > 0) {
					if (nodeAt(nodeIndex - 1).isControlNode) {
						spliceOffset = -1;
						spliceNum++;
						_controlNodes--;
					}
				}
				
				if (nodeIndex < _nodes.length - 1) {
					if (nodeAt(nodeIndex + 1).isControlNode) {
						spliceNum++;
						_controlNodes--;
					}
				}
				
				_nodes.splice(nodeIndex + spliceOffset, spliceNum);
				_connections.splice(nodeIndex + spliceOffset, spliceNum);
				_realNodes--;
				
				return true;
				
			} else {
				
				return false;
				
			}
			
		}
		
		//
		//
		public function concat (nodes:NodeSet):NodeSet {
			
			var newNodes:NodeSet = copy();

			for (var i:int = 0; i < nodes.length; i++) {
				newNodes.addNode(nodes.nodeAt(i), nodes.connectionAt(i));
			}
			
			return newNodes;
			
		}
		
		//
		//
		public function copy ():NodeSet {
			
			var newNodes:NodeSet = new NodeSet();

			for (var i:int = 0; i < _nodes.length; i++) {
				newNodes.addNode(nodeAt(i).copy(), connectionAt(i));
			}

			return newNodes;
			
		}
		
		//
		//
		public function copyInterpolated ():NodeSet {

			var newNodes:NodeSet = new NodeSet();
			var prevNode:Node;
			
			for (var i:int = 0; i < _nodes.length; i++) {

				if (!nodeAt(i).isControlNode) {
					
					if (i > 0) {
						
						if (nodeAt(i - 1).isControlNode && i >= 2) {
							
							newNodes.addNodes(nodeAt(i - 1).getInterpolatedNodes(nodeAt(i - 2), nodeAt(i), _curveSegments));

						} else {
							
							newNodes.addNode(nodeAt(i).copy(), connectionAt(i));
							
						}
						
					} else {
						
						newNodes.addNode(nodeAt(i).copy(), connectionAt(i));
						
					}
					
				}
				
			}
			
			newNodes.repair();
			
			if (Geom2d.isConvex(newNodes.nodes)) {
				
				newNodes.reverse();
				
			}
			
			return newNodes;
			
		}
		
		//
		//
		public function nodeAt (idx:int):Node {
			
			return Node(_nodes[idx]);
			
		}
		
		//
		//
		public function connectionAt (idx:int):Boolean {
			
			return _connections[idx];
			
		}
		
		
		
		//
		//
		public function reverse ():NodeSet {
			
			_nodes.reverse();
			
			_connections.reverse();
			_connections.pop();
			_connections.unshift(false);
			
			return this;
			
		}
		
	}
	
}
