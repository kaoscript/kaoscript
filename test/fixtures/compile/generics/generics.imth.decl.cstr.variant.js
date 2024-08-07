const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, mapper, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
		if(!Type.isBoolean(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant) {
			return Event.isTrue(value, mapper);
		}
		else {
			return Event.isFalse(value);
		}
	}}));
	Event.isFalse = value => Type.isDexObject(value, 0, 0, {errors: value => Type.isArray(value, Type.isString) || Type.isNull(value)});
	Event.isTrue = (value, mapper) => Type.isDexObject(value, 0, 0, {value: mapper[0]});
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
		foobar(gens, ...args) {
			return this.__ks_func_foobar_rt.call(null, this, this, gens || {}, args);
		}
		__ks_func_foobar_0(value) {
		}
		__ks_func_foobar_rt(that, proto, gens, args) {
			const t0 = gens.T || (value => Event.is(value, [Type.any]));
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};