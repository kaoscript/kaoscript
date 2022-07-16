const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x, y) {
		let z = y.y;
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = value => Type.isString(value) || Type.isDictionary(value);
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foo.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};