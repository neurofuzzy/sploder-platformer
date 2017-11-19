//
//
//
function linkAll () {
	
	var lib = fl.getDocumentDOM().library;
	
	lib.selectNone();
	
	var n = lib.items.length;
	var i;
	
	var names = [];
	var consts = [];
	
	for (i = 0; i < n; i++) {
		
		if (lib.items[i].itemType == "movie clip" || lib.items[i].itemType == "button" || lib.items[i].itemType == "sound") {
			lib.items[i].linkageExportForAS = false;
		}
		
	}	
	
	for (i = 0; i < n; i++) {

		if (lib.items[i].itemType == "movie clip" || lib.items[i].itemType == "button" || lib.items[i].itemType == "sound") {
			lib.items[i].linkageExportForAS = true;
			lib.items[i].linkageExportInFirstFrame = true;
			lib.items[i].linkageIdentifier = lib.items[i].name.split(" ").join("_").split("/").join("_");
			lib.items[i].linkageIdentifier = lib.items[i].linkageIdentifier.split(".")[0];
			fl.trace("item '" + lib.items[i].name + "' linkage ID is: " + lib.items[i].linkageIdentifier);
			names.push('"' + lib.items[i].linkageIdentifier + '"');
			consts.push('public static const ' + lib.items[i].linkageIdentifier.toUpperCase() +  ':String = "' + lib.items[i].linkageIdentifier + '";');
		}
		
	}		
	
	fl.trace("done!");
	fl.trace("--");
	names.sort();
	fl.trace(names.join(", "));
	fl.trace("\n");
	fl.trace(consts.join("\n"));

}

linkAll();