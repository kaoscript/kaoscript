const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = (() => {
		const o = new OBJ();
		o.foobar = Helper.function(function(name, data) {
			return data;
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return fn.call(null, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		});
		o.quxbaz = Helper.function(function(fn, data) {
		}, (fn, ...args) => {
			const t0 = Type.isValue;
			if(args.length === 2) {
				if(t0(args[0]) && t0(args[1])) {
					return fn.call(null, args[0], args[1]);
				}
			}
			throw Helper.badArgs();
		});
		return o;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(name, data) {
		Foobar.quxbaz.__ks_0(Helper.vcurry(Foobar.foobar, null, name), data);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};