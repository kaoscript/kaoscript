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
			this._items = [];
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		list() {
			return this.__ks_func_list_rt.call(null, this, this, arguments);
		}
		__ks_func_list_0(fn) {
			return (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = this._items.length, item; __ks_1 < __ks_0; ++__ks_1) {
					item = this._items[__ks_1];
					a.push(fn(this._name, item));
				}
				return a;
			})();
		}
		__ks_func_list_rt(that, proto, args) {
			const t0 = Type.isFunction;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_list_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
};