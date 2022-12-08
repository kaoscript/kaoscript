const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const o = new OBJ();
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(key) {
		const x = o[key];
		if(Type.isFunction(x)) {
		}
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};