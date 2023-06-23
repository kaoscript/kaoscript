const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value.isTest() === true) {
			const box = value.box();
			return (() => {
				const o = new OBJ();
				o.value = Helper.function(function() {
					return box.value();
				}, (fn, ...args) => {
					if(args.length === 0) {
						return fn.call(null);
					}
					throw Helper.badArgs();
				});
				return o;
			})();
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};