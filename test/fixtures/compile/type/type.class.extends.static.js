const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Quxbaz {
		static __ks_new_0() {
			const o = Object.create(Quxbaz.prototype);
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
		static __ks_sttc_get_0() {
			return Quxbaz.__ks_new_0();
		}
		static get() {
			if(arguments.length === 0) {
				return Quxbaz.__ks_sttc_get_0();
			}
			throw Helper.badArgs();
		}
	}
	class Foobar extends Quxbaz {
		static __ks_new_0() {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		static __ks_sttc_get_0() {
			return Foobar.__ks_new_0();
		}
		static get() {
			if(arguments.length === 0) {
				return Foobar.__ks_sttc_get_0();
			}
			if(Quxbaz.get) {
				return Quxbaz.get.apply(null, arguments);
			}
			throw Helper.badArgs();
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	const x = Foobar.__ks_sttc_get_0();
	foobar.__ks_0(x);
	return {
		Foobar,
		Quxbaz
	};
};