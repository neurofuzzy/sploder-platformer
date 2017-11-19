//
//
//
function getShapeData(element) {
	
	var shapedata = "";
	element.beginEdit();
	
	var shapeArray = new Array();
	
	for (var i=0; i<element.contours.length; i++) {
		
		if (element.contours[i].interior) {
			
			var halfedge = element.contours[i].getHalfEdge();
			var backward = getDirection(halfedge);
			var startid = halfedge.id;
			var id = 0;
			
			if (shapedata.length > 0) shapedata = "|" + shapedata;
	
			
			while (startid != id) {
				
				var edge = halfedge.getEdge();
				
				var shapeObj = new Object();
				
				if (edge.isLine) {
					
					var point2 = edge.getControl(2);
					
					var x2 = Math.round(point2.x * 20) / 20;
					var y2 = Math.round(point2.y * 20) / 20;
					
					var point2b;
					
					if (backward) {
						point2b = halfedge.getPrev().getEdge().getControl(2);
					} else {
						point2b = halfedge.getNext().getEdge().getControl(2);
					}
					if (x2 == point2b.x && y2 == point2b.y) {
						
						fl.trace("WARNING: node x:" + x2 + ", y:" + y2 + " is repeated, attempting to correct.");

						if (!backward) {
							point2b = halfedge.getPrev().getEdge().getControl(0);
						} else {
							point2b = halfedge.getNext().getEdge().getControl(0);
						}
					
						var x2b = Math.round(point2b.x * 20) / 20;
						var y2b = Math.round(point2b.y * 20) / 20;						
					
						shapedata = "|[true, " + x2b + ", " + y2b + "]" + shapedata;
						
					} else {
						
						shapedata = "|[true, " + x2 + ", " + y2 + "]" + shapedata;
						
					}
					
					shapeObj.x = x2;
					shapeObj.y = y2;
					
					if (id == 0) {
						var startx = x2;
						var starty = y2;
					}
					
				} else {
					
					var point1 = edge.getControl(1);
					var point2 = edge.getControl(2);
					
					var x1 = Math.round(point1.x * 20) / 20;
					var y1 = Math.round(point1.y * 20) / 20;
					var x2 = Math.round(point2.x * 20) / 20;
					var y2 = Math.round(point2.y * 20) / 20;
					
					shapedata = "|[true, "+x1+", "+y1+", "+x2+", "+y2+"]" + shapedata;
					
					shapeObj.x = x1;
					shapeObj.y = y1;
					
					if (id == 0) {
						var startx = x2;
						var starty = y2;
					}
					
				}
				
				if (backward) {
					halfedge = halfedge.getPrev();
				} else {
					halfedge = halfedge.getNext();
				}
				
				id = halfedge.id;
				
				shapeArray.push(shapeObj);
				
			}
			
			shapedata = "\n\t\t[false, " + startx + ", " + starty + "]" + shapedata;
			
			shapeObj = new Object();
			shapeObj.x = startx;
			shapeObj.y = starty;
			shapeArray.push(shapeObj);
			
		}
		
	}
	
	element.endEdit();
	
	var shapeDataArray = shapedata.split("|");
	var convex = isConvex(shapeArray);
	
	if (convex != true) {
		fl.trace("NOTE: Shape orientation is reversed, will correct at runtime.\n\n");
	}
	
	shapedata = "[" + shapeDataArray.join(", ") + "]";
	
	return shapedata;
	
}

//
//
//
function getDirection(halfedge) {
	
	var edge = halfedge.getEdge();
	var nexthalfedge = halfedge.getNext();
	var nextedge = nexthalfedge.getEdge();
	var control = edge.getControl(2);
	var nextcontrol = nextedge.getControl(0);
	
	return (control.x == nextcontrol.x && control.y == nextcontrol.y);
	
}

//
//
function isConvex (p) {

	return (getArea(p) > 0) ? true : false;
	
}

//
//
function getArea (p) {
	
	if (p.length > 2) {
		
		var area = 0;
	
		var n = p.length;
		
		for (var i = 1; i <= n - 2; i++) {
			
			area += p[i].x * (p[i+1].y - p[i-1].y);
			
		}
		
		area += p[p.length - 1].x * (p[0].y - p[p.length - 2].y);
		area += p[0].x * (p[1].y - p[p.length - 1].y);
		
		return area;
		
	}
	
	return 0;
	
}

function createMaterial (element) {
	
	var code = "";
	
	var fill = fl.getDocumentDOM().getCustomFill("selection"); 
	var fillColor = fill.color.split("'").join("").split("#").join("");
	var fillAlpha = 1;

	if (fillColor.length > 6) {
		fillAlpha = Math.round((parseInt(fillColor.substr(6,2),16) / 255) * 10) / 10;
		fillColor = fillColor.substr(0,6);
	}
	
	code = 'var objMat' + elementID + ':Material = new Material(0x' + fillColor + ', 0, ' + fillAlpha + ');'
	
	return code;

}

fl.outputPanel.clear();	

var elementID = 0;
var code = "// SHAPE DATA Imported from Flash IDE -----------------------------\n\n";

var selArray = fl.getDocumentDOM().selection;
var elt = selArray[0];

if (elt != undefined) {
	
	var contourArray = elt.contours;
	var nodedata = getShapeData(elt);

	

	code += 'var objNodes' + elementID + ':NodeSet = new NodeSet(' + nodedata + ');';
	code += '\n\n';
	code += createMaterial(elt);

	fl.trace(code);
	fl.trace("\n// END SHAPE DATA -------------------------------------------------");

} else {
	
	fl.trace("Nothing selected!");
	
}

