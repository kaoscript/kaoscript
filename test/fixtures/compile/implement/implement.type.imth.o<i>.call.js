const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Data = {
		is: value => Type.isDexObject(value, 1, 0, {line: Type.isNumber})
	};
	__ks_Data.__ks_func_debug_0 = function(that) {
		console.log(that.line);
	};
	__ks_Data.__ks_func_debug = function(that, ...args) {
		if(args.length === 0) {
			return __ks_Data.__ks_func_debug_0(that);
		}
		throw Helper.badArgs();
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		__ks_Data.__ks_func_debug_0(data);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ks_Data.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};