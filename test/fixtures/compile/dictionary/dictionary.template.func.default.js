const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new Dictionary();
		d[x] = Helper.function(function() {
			return 42;
		}, (fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
		return d;
	})();
};