const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const PI = 3.14;
	const foobar = (() => {
		const o = new OBJ();
		o.value = Helper.function((r) => {
			return Operator.multiplication(PI, r);
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return fn.call(null, args[0]);
				}
			}
			throw Helper.badArgs();
		});
		return o;
	})();
};