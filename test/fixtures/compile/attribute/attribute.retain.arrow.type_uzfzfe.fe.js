const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AsyncFn = Helper.alias(Type.isFunction);
	const SyncFn = Helper.alias(Type.isFunction);
	it("print", Helper.function(() => {
	}, (that, fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}));
};