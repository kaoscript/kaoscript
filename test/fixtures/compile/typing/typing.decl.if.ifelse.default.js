const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(x) {
		let y;
		if(x) {
			y = "42 * x";
		}
		else {
			y = "24 * x";
		}
		return y;
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
};