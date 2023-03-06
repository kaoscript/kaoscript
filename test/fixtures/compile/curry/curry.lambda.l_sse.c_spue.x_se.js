const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const f = Helper.curry((fn, ...args) => {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn[0](args[0]);
			}
		}
		throw Helper.badArgs();
	}, (name) => {
		let prefix = "Hello ";
		return prefix + name;
	});
	console.log(f.__ks_0("White"));
};