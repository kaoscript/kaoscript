const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
	};
	foo.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isObject(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(x) {
		foo.__ks_0(x);
	};
	bar.__ks_rt = function(that, args) {
		const t0 = value => Type.isString(value) || Type.isObject(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return bar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};