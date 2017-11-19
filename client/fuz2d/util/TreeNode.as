/**
* ...
* @author Default
* @version 0.1
*/

package fuz2d.util {

	public class TreeNode {
		
		protected var _name:String;
		public function get name ():String { return _name; }
		public function set name (val:String):void { _name = (val != null) ? val : _name; }
		protected var _parentNode:TreeNode;
		public function get parentNode ():TreeNode { return _parentNode; }
		public function set parentNode (node:TreeNode):void { _parentNode = (node != null) ? node : _parentNode; }
		
		protected var _childNodes:Array;
		
		public function get depth ():uint { return (isRoot) ? 0 : _parentNode.depth + 1; }
		
		public var xmlRef:XML;
		
		//
		//
		public function TreeNode (name:String, parentNode:TreeNode = null, childNodes:Array = null) {
			
			_name = name;
			_parentNode = parentNode;
			_childNodes = [];
			
			if (childNodes != null) {
				
				for (var i:uint = 0; i < childNodes.length; i++) {
				
					if (childNodes[i] is TreeNode) {
						addChild(childNodes[i]);
					}
					
				}
				
			}
			
		}
		
		//
		//
		public function createChild (name:String):TreeNode {
			
			var node:TreeNode = new TreeNode(name, this);
			addChild(node);
			return node;
			
		}
		
		//
		//
		public function addChild (childNode:TreeNode):void {
			
			_childNodes.push(childNode);
			childNode.parentNode = this;
			
		}
		
		//
		//
		public function removeChild (childNode:TreeNode):TreeNode {
			
			if (_childNodes.indexOf(childNode) != -1) {
				childNode.parentNode = null;
				_childNodes.splice(_childNodes.indexOf(childNode), 1);
			}	
			
			return childNode;
			
		}
		
		//
		//
		public function isChildOf (node:TreeNode):Boolean {
			return (node == _parentNode);
		}
		
		//
		//
		public function isDescendantOf (node:TreeNode):Boolean {
			
			var ancestor:TreeNode = _parentNode;
			
			while (ancestor != null) {
				
				if (ancestor == node) return true;
				ancestor = ancestor.parentNode;
				
			}
			
			return false;
			
		}
		
		//
		//
		public function get isRoot ():Boolean {
			
			return (_parentNode == null);
			
		}
		
		//
		//
		public function getNode(name:String):TreeNode {
			
			if (_name == name) return this;
			
			var node:TreeNode;
			
			for (var i:uint = 0; i < _childNodes.length; i++) {
				
				node = TreeNode(_childNodes[i]).getNode(name);
				if (node != null) return node;
				
			}
			
			return null;
			
		}
		
		//
		//
		public function getAllNodes ():Array {
			
			var all:Array = [this];
			
			for (var i:uint = 0; i < _childNodes.length; i++) {
				
				all = all.concat(TreeNode(_childNodes[i]).getAllNodes());
				
			}	
			
			return all;
			
		}
		
		//
		//
		public function renderTrace ():void {
			
			var t:String = "";
			var i:uint;
			
			for (i = 0; i < depth; i++) {
				t += "\t";
			}
			
			trace(t + "-" + name);
			
			for (i = 0; i < _childNodes.length; i++) {
				
				TreeNode(_childNodes[i]).renderTrace();
				
			}
			
		}
		
	}
	
}
