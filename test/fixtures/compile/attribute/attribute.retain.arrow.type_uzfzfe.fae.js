const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AsyncFn = Helper.alias(Type.isFunction);
	const SyncFn = Helper.alias(Type.isFunction);
	it("print", Helper.function((done) => {
		done();
	}, (that, fn, ...args) => {
		const t0 = Type.isFunction;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(null, args[0]);
			}
		}
		throw Helper.badArgs();
	}, true));
};