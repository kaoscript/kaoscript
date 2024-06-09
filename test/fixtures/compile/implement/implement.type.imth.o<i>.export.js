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
	return {
		__ks_Data
	};
};