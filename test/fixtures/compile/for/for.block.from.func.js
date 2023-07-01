const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.foo = Helper.function(() => {
			let i = 0;
		}, (that, fn, ...args) => {
			if(args.length === 0) {
				return fn.call(null);
			}
			throw Helper.badArgs();
		});
		return o;
	})();
	function bar() {
		return bar.__ks_rt(this, arguments);
	};
	bar.__ks_0 = function() {
		for(let i = 0; i < 10; ++i) {
			console.log(i);
		}
	};
	bar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return bar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};