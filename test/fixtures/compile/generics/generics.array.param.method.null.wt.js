var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_RegExp = {};
	var __ks_String = {};
	__ks_String.__ks_func_foobar_0 = function() {
		return this;
	};
	__ks_String._im_foobar = function(that) {
		var args = Array.prototype.slice.call(arguments, 1, arguments.length);
		if(args.length === 0) {
			return __ks_String.__ks_func_foobar_0.apply(that);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const regex = /foo/;
	let match = regex.exec("foobar");
	if(Type.isValue(match)) {
		Type.isValue(match[0]) ? __ks_String._im_foobar(match[0]) : undefined;
	}
};