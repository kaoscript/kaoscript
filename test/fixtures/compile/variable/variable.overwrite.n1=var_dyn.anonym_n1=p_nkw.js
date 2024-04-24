const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 42;
	const fn = Helper.function(function(x) {
		return x;
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(null, args[0]);
			}
		}
		throw Helper.badArgs();
	});
};