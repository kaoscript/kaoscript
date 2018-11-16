var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	if(Type.isValue(__ks_0)) {
		return [__ks_0, __ks___ks_0];
	}
	else {
		return [String, typeof __ks_String === "undefined" ? {} : __ks_String];
	}
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [String, __ks_String] = __ks_require(__ks_0, __ks___ks_0);
	__ks_String.__ks_func_clean_0 = function() {
		return this.replace(/\s+/g, " ").trim();
	};
	__ks_String._im_clean = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_clean_0.apply(that);
		}
		throw new SyntaxError("wrong number of arguments");
	};
	return {
		String: String,
		__ks_String: __ks_String
	};
};