const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new Dictionary();
		d.foo = (() => {
			const __ks_rt = (...args) => {
				if(args.length === 0) {
					return __ks_rt.__ks_0.call(null);
				}
				throw Helper.badArgs();
			};
			__ks_rt.__ks_0 = function() {
				let i = 0;
			};
			return __ks_rt;
		})();
		return d;
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