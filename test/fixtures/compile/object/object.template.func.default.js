const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "y";
	let foo = (() => {
		const d = new OBJ();
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