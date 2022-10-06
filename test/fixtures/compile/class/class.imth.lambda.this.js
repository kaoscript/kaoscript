const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Formatter {
		static __ks_new_0() {
			const o = Object.create(Formatter.prototype);
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
		camelize() {
			return this.__ks_func_camelize_rt.call(null, this, this, arguments);
		}
		__ks_func_camelize_0(value) {
			return Operator.add(this.toLowerCase(value.charAt(0)), value.substr(1).replace(/[-_\s]+(.)/g, Helper.function((__ks_0, l) => {
				return this.__ks_func_toUpperCase_0(l);
			}, (fn, ...args) => {
				const t0 = Type.isValue;
				if(args.length === 2) {
					if(t0(args[0]) && t0(args[1])) {
						return fn.call(this, args[0], args[1]);
					}
				}
				throw Helper.badArgs();
			})));
		}
		__ks_func_camelize_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_camelize_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		toLowerCase() {
			return this.__ks_func_toLowerCase_rt.call(null, this, this, arguments);
		}
		__ks_func_toLowerCase_0(value) {
			return value.toLowerCase();
		}
		__ks_func_toLowerCase_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_toLowerCase_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		toUpperCase() {
			return this.__ks_func_toUpperCase_rt.call(null, this, this, arguments);
		}
		__ks_func_toUpperCase_0(value) {
			return value.toUpperCase();
		}
		__ks_func_toUpperCase_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_toUpperCase_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	const formatter = Formatter.__ks_new_0();
	console.log(formatter.__ks_func_camelize_0("john doe"));
};