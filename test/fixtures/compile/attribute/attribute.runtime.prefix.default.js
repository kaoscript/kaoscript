const {Helper: KSHelper, Operator: KSOperator, Type: KSType} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, y) {
		return KSOperator.add(x, y);
	};
	foo.__ks_rt = function(that, args) {
		const t0 = KSType.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foo.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw KSHelper.badArgs();
	};
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function(x, y) {
		if(KSType.isString(x)) {
			return x.toInt();
		}
		else {
			return y;
		}
	};
	bar.__ks_rt = function(that, args) {
		const t0 = KSType.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return bar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw KSHelper.badArgs();
	};
};