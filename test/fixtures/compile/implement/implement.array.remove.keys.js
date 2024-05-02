const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Array = {};
	__ks_Array.__ks_func_remove_0 = function(items) {
		return this;
	};
	__ks_Array._im_remove = function(that, ...args) {
		return __ks_Array.__ks_func_remove_rt(that, args);
	};
	__ks_Array.__ks_func_remove_rt = function(that, args) {
		return __ks_Array.__ks_func_remove_0.call(that, Array.from(args));
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		const keys = Object.keys(data);
		__ks_Array.__ks_func_remove_0.call(keys, ["hello"]);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};