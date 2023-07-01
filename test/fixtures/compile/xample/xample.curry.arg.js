const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let o = (() => {
		const o = new OBJ();
		o.name = "White";
		return o;
	})();
	function fff() {
		return fff.__ks_rt(this, arguments);
	};
	fff.__ks_0 = function(prefix) {
		return Operator.add(prefix, this.name);
	};
	fff.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fff.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let f = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn[0](args[0]);
			}
		}
		throw Helper.badArgs();
	}, (__ks_0) => fff.__ks_0.call(o, __ks_0));
	let s = f.__ks_0("Hello ");
};