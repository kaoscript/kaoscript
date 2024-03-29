const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	it("print", Helper.function((done) => {
		if(done === void 0) {
			done = null;
		}
		done();
	}, (that, fn, ...args) => {
		const t0 = value => Type.isFunction(value) || Type.isNull(value);
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(null, args[0]);
			}
		}
		throw Helper.badArgs();
	}, true));
};