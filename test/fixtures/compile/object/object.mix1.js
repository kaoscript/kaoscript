const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.bar = (() => {
			const o = new OBJ();
			o.qux = Helper.function(function() {
				let i = 1;
			}, (fn, ...args) => {
				if(args.length === 0) {
					return fn.call(null);
				}
				throw Helper.badArgs();
			});
			return o;
		})();
		return o;
	})();
};