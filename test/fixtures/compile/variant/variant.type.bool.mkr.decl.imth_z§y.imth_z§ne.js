const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.alias((value, filter) => Type.isDexObject(value, 1, 0, {ok: variant => {
		if(!Type.isBoolean(variant)) {
			return false;
		}
		if(filter && !filter(variant)) {
			return false;
		}
		if(variant) {
			return Type.isDexObject(value, 0, 0, {value: Type.isString});
		}
		else {
			return Type.isDexObject(value, 0, 0, {expecting: value => Type.isString(value) || Type.isNull(value)});
		}
	}}));
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
		getNoValue() {
			return this.__ks_func_getNoValue_rt.call(null, this, this, arguments);
		}
		__ks_func_getNoValue_0(event) {
			return event.expecting;
		}
		__ks_func_getNoValue_rt(that, proto, args) {
			const t0 = value => Event.is(value, value => !value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_getNoValue_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		getYesValue() {
			return this.__ks_func_getYesValue_rt.call(null, this, this, arguments);
		}
		__ks_func_getYesValue_0(event) {
			return event.value;
		}
		__ks_func_getYesValue_rt(that, proto, args) {
			const t0 = value => Event.is(value, value => value);
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_getYesValue_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};