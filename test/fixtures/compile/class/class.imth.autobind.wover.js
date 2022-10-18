const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
			return [];
		}
		__ks_func_foobar_1(x) {
			return [x];
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0() {
			return [];
		}
		__ks_func_quxbaz_1(x) {
			return [x];
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 0) {
				return proto.__ks_func_quxbaz_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_quxbaz_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(f, test) {
		const fn = test ? Helper.bindMethod(f, "foobar") : Helper.bindMethod(f, "quxbaz");
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		const t1 = Type.isBoolean;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};