var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar(__ks_class_1, __ks_default_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_class_1 === void 0) {
			__ks_class_1 = null;
		}
		if(__ks_default_1 === void 0 || __ks_default_1 === null) {
			__ks_default_1 = 0;
		}
		else if(!Type.isNumber(__ks_default_1)) {
			throw new TypeError("'default' is not of type 'Number'");
		}
		console.log(__ks_class_1, __ks_default_1);
	}
};