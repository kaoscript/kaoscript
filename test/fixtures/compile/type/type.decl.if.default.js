const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		let y = null;
		if(x) {
			y = bar.__ks_0();
		}
		if(y !== null) {
			return y.z.toString();
		}
		else {
			return "";
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isBoolean;
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
	bar.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.z = 42;
			return o;
		})();
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};