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
			return this;
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
		quxbaz() {
			return this.__ks_func_quxbaz_rt.call(null, this, this, arguments);
		}
		__ks_func_quxbaz_0() {
			return true;
		}
		__ks_func_quxbaz_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_quxbaz_0.call(that);
			}
			throw Helper.badArgs();
		}
		static __ks_sttc_create_0() {
			return Foobar.__ks_new_0();
		}
		static create() {
			if(arguments.length === 0) {
				return Foobar.__ks_sttc_create_0();
			}
			throw Helper.badArgs();
		}
	}
	let x, __ks_0;
	if((Type.isValue(__ks_0 = Foobar.__ks_sttc_create_0().__ks_func_foobar_0()) ? (x = __ks_0, true) : false) && x.__ks_func_quxbaz_0()) {
	}
};