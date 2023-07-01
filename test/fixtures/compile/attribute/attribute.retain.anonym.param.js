const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	it("print", Helper.function(function(done) {
		done();
	}, (that, fn, ...args) => {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn.call(null, args[0]);
			}
		}
		throw Helper.badArgs();
	}, true));
};