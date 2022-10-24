const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	it("print", Helper.function((done) => {
		done();
	}, (fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(this, args[0]);
			}
		}
		throw Helper.badArgs();
	}, true));
};