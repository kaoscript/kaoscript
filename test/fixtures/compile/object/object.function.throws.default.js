const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const foobar = (() => {
		const o = new OBJ();
		o.corge = Helper.function(function() {
			throw new SyntaxError();
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
		return o;
	})();
};