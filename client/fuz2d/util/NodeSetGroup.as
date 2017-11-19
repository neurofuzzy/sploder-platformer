/**
* Fuz2d: 2d Gaming Engine
* ----------------------------------------------------------------
* ----------------------------------------------------------------
* Copyright (C) 2008 Geoffrey P. Gaudreault
* 
*/

package fuz2d.util {

	import flash.utils.Dictionary;
	import fuz2d.util.*;
	
	public class NodeSetGroup {
		
		protected var _nodeSets:Array;

		//
		public function get nodeSets ():Array {
			return _nodeSets;
		}
	
		//
		public function get length ():uint {
			return _nodeSets.length;
		}
		
		//
		public function get firstNodeSet ():NodeSet {
			return (_nodeSets.length > 0) ? _nodeSets[0] : null;
		}
		
		//
		public function get lastNodeSet ():NodeSet {
			return (_nodeSets.length > 0) ? _nodeSets[_nodeSets.length - 1] : null;
		}
		
		//
		//
		public function NodeSetGroup(nodesArray:Array = null) {
		
			init(nodesArray);

		}
		
		//
		//
		protected function init (nodeSetArray:Array = null):void {
			
			_nodeSets = [];
			
			if (nodeSetArray != null) {
				
				for (var i:uint = 0; i < nodeSetArray.length; i++) {
					
					_nodeSets.push(new NodeSet(nodeSetArray[i]));

				}
				
			}	
			
		}
		
		//
		//
		public function addNodeSet (nodeSet:NodeSet):NodeSet {
			
			_nodeSets.push(nodeSet);

			return lastNodeSet;
			
		}
		
		//
		//
		public function addNodeSets (nodeSets:NodeSetGroup):void {

			_nodeSets.concat(nodeSets);
			
		}
		
		//
		//
		public function removeNode (nodeSet:NodeSet):Boolean {
			
			var nodeSetIndex:uint = _nodeSets.indexOf(nodeSet);

			if (nodeSetIndex != -1) {
				
				_nodeSets.splice(nodeSetIndex, 1);

				return true;
				
			} else {
				
				return false;
				
			}
			
		}
		
		//
		//
		public function concat (nodeSets:NodeSetGroup):NodeSetGroup {
			
			var newNodes:NodeSetGroup = copy();

			return newNodes.concat(nodeSets);
			
		}
		
		//
		//
		public function copy ():NodeSetGroup {
			
			var newNodeSets:NodeSetGroup = new NodeSetGroup();

			for (var i:uint = 0; i < _nodeSets.length; i++) {
				newNodeSets.addNodeSet(nodeSetAt(i));
			}

			return newNodeSets;
			
		}
			
		//
		//
		public function nodeSetAt (idx:uint):NodeSet {
			
			return NodeSet(_nodeSets[idx]);
			
		}
	
		//
		//
		public function reverse ():NodeSetGroup {
			
			_nodeSets.reverse();
			
			return this;
			
		}
		
	}
	
}
