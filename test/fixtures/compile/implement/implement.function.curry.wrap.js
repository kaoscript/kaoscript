const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function $wrap() {
		return $wrap.__ks_rt(this, arguments);
	};
	$wrap.__ks_0 = function(self, args) {
	};
	$wrap.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length >= 1) {
			if(t0(args[0])) {
				return $wrap.__ks_0.call(that, args[0], Array.from(args).slice(1));
			}
		}
		throw Helper.badArgs();
	};
	const __ks_Function = {};
	__ks_Function.__ks_func_wrap_0 = function() {
		return Helper.curry((that, fn, ...args) => {
			return fn[0].call(that, this, Array.from(args));
		}, function(that, __ks_0) {
			return $wrap.__ks_0.call(this, that, __ks_0);
		}
);
	};
	__ks_Function._im_wrap = function(that, ...args) {
		return __ks_Function.__ks_func_wrap_rt(that, args);
	};
	__ks_Function.__ks_func_wrap_rt = function(that, args) {
		if(args.length === 0) {
			return __ks_Function.__ks_func_wrap_0.call(that);
		}
		if(that.wrap) {
			return that.wrap(...args);
		}
		throw Helper.badArgs();
	};
};