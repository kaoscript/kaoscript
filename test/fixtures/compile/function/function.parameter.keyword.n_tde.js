var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		let __ks_i = -1;
		let __ks_class_1 = arguments[++__ks_i];
		if(__ks_class_1 === void 0) {
			__ks_class_1 = null;
		}
		let __ks_default_1;
		if(arguments.length > 1 && (__ks_default_1 = arguments[++__ks_i]) !== void 0 && __ks_default_1 !== null) {
			if(!Type.isNumber(__ks_default_1)) {
				throw new TypeError("'default' is not of type 'Number'");
			}
		}
		else {
			__ks_default_1 = 0;
		}
		console.log(__ks_class_1, __ks_default_1);
	}
};