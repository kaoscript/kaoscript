const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_SyntaxError = {};
	const foobar = (() => {
		const o = new OBJ();
		o.corge = Helper.function(() => {
			throw new SyntaxError();
		}, (fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
		return o;
	})();
};