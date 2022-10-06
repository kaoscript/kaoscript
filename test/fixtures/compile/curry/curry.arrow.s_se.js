const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const f = Helper.vcurry(Helper.function((prefix, name) => {
		return prefix + name;
	}, (fn, ...args) => {
		const t0 = Type.isString;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(this, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}), null, "Hello ");
	console.log(Helper.toString(f("White")));
};