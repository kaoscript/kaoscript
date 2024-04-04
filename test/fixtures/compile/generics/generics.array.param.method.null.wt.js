const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_String = {};
	__ks_String.__ks_func_foobar_0 = function() {
		return this;
	};
	__ks_String._im_foobar = function(that, ...args) {
		return __ks_String.__ks_func_foobar_rt(that, args);
	};
	__ks_String.__ks_func_foobar_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_String.__ks_func_foobar_0.call(that);
		}
		throw Helper.badArgs();
	};
	const regex = /foo/;
	let match = regex.exec("foobar");
	if(Type.isValue(match)) {
		Type.isValue(match[0]) ? __ks_String.__ks_func_foobar_0.call(match[0]) : null;
	}
};