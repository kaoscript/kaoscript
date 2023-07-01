const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const f = Helper.curry((that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn[0](args[0]);
			}
		}
		throw Helper.badArgs();
	}, (name) => {
		let prefix = "Hello ";
		return Operator.add(prefix, name);
	});
	console.log(Helper.toString(f.__ks_0("White")));
};