const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_SyntaxError = {};
	const foobar = (() => {
		const d = new Dictionary();
		d.corge = Helper.function(function() {
			throw new SyntaxError();
		}, (fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
		return d;
	})();
};