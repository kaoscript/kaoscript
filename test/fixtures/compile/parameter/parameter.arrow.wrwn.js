const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = Helper.function((x, y) => {
		if(x === void 0) {
			x = null;
		}
		return [x, y];
	}, (fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[1])) {
				return fn.call(null, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
};