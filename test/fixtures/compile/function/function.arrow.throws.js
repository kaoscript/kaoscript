const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const foobar = Helper.function((x) => {
		throw new Error();
	}, (fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(this, args[0]);
			}
		}
		throw Helper.badArgs();
	});
	return {
		foobar
	};
};