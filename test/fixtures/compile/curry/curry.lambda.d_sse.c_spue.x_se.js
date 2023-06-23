const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const f = Helper.function((prefix, name) => {
		return prefix + name;
	}, (fn, ...args) => {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	const g = Helper.curry((fn, ...args) => {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn[0](args[0]);
			}
		}
		throw Helper.badArgs();
	}, (__ks_0) => f.__ks_0("Hello ", __ks_0));
	console.log(f.__ks_0("Hello ", "White"));
	console.log(g.__ks_0("White"));
};