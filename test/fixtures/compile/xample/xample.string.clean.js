var Type = require("@kaoscript/runtime").Type;
module.exports = function(__ks_String) {
	if(!Type.isValue(__ks_String)) {
		__ks_String = {};
	}
	__ks_String.__ks_func_clean_0 = function() {
		return this.replace(/\s+/g, " ").trim();
	};
	__ks_String._im_clean = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_clean_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	return {
		__ks_String: __ks_String
	};
};