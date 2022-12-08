const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new OBJ();
		d.bar = (() => {
			const d = new OBJ();
			d.qux = Helper.function(function() {
				let i = 1;
			}, (fn, ...args) => {
				if(args.length === 0) {
					return fn.call(null);
				}
				throw Helper.badArgs();
			});
			return d;
		})();
		return d;
	})();
};