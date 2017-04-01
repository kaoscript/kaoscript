var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_String = {};
	__ks_String.__ks_func_replaceAll_0 = function(find, replacement) {
		if(arguments.length < 2) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(find === void 0 || find === null) {
			throw new TypeError("'find' is not nullable");
		}
		else if(!Type.isString(find)) {
			throw new TypeError("'find' is not of type 'String'");
		}
		if(replacement === void 0 || replacement === null) {
			throw new TypeError("'replacement' is not nullable");
		}
		if(find.length === 0) {
			return this.valueOf();
		}
		if(find.length <= 3) {
			return this.split(find).join(replacement);
		}
		else {
			return this.replace(new RegExp(find.escapeRegex(), "g"), replacement);
		}
	};
	__ks_String._im_replaceAll = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 2) {
			return __ks_String.__ks_func_replaceAll_0.apply(that, args);
		}
		throw new SyntaxError("wrong number of arguments");
	};
}