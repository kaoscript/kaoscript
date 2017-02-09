var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(__ks_class_1) {
		if(__ks_class_1 === undefined || __ks_class_1 === null) {
			throw new Error("Missing parameter 'class'");
		}
		else if(!Type.isClass(__ks_class_1)) {
			throw new Error("Invalid type for parameter 'class'");
		}
		console.log(__ks_class_1);
	}
}