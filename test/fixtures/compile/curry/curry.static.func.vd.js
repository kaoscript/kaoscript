const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Function = {};
	let fn = Helper.function((prefix, name) => {
		return prefix + name;
	}, (fn, ...args) => {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(this, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	fn = Function.curry(fn, "Hello ");
	console.log(Helper.toString(fn("White")));
};