var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foo(__ks_class_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_class_1 === void 0 || __ks_class_1 === null) {
			throw new TypeError("'class' is not nullable");
		}
		else if(!Type.isClass(__ks_class_1)) {
			throw new TypeError("'class' is not of type 'Class'");
		}
		console.log(__ks_class_1);
	}
};