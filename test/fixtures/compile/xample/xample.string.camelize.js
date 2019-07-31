var Type = require("@kaoscript/runtime").Type;
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(String, typeof __ks_String === "undefined" ? {} : __ks_String);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [String, __ks_String] = __ks_require(__ks_0, __ks___ks_0);
	__ks_String.__ks_func_camelize_0 = function() {
		return this.replace(/[-_\s]+(.)/g, function(m, l) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(m === void 0 || m === null) {
				throw new TypeError("'m' is not nullable");
			}
			if(l === void 0 || l === null) {
				throw new TypeError("'l' is not nullable");
			}
			return l.toUpperCase();
		});
	};
	__ks_String._im_camelize = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_camelize_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
};