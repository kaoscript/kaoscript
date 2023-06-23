const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	it("print", Helper.function(() => {
	}, (fn, ...args) => {
		if(args.length === 0) {
			return fn.call(null);
		}
		throw Helper.badArgs();
	}));
};