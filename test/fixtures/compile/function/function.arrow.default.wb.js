const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const foo = Helper.function((a, b) => {
		return a - b;
	}, (that, fn, ...args) => {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
};