const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return (() => {
			const d = new Dictionary();
			d.foobar = Helper.function(function(x) {
			}, (fn, ...args) => {
				const t0 = Type.isString;
				if(args.length === 1) {
					if(t0(args[0])) {
						return fn.call(null, args[0]);
					}
				}
				throw Helper.badArgs();
			});
			return d;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};