const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Foobar.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(values) {
			if(values === void 0) {
				values = null;
			}
			this._values = values;
		}
		__ks_cons_rt(that, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return Foobar.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0() {
			return (() => {
				const a = [];
				for(let __ks_1 = 0, __ks_0 = Helper.length(this._values), name; __ks_1 < __ks_0; ++__ks_1) {
					Helper.assertDexObject(this._values[__ks_1], 1, 0, {name: Type.isValue});
					({name} = this._values[__ks_1]);
					a.push((() => {
						const o = new OBJ();
						o.name = name;
						return o;
					})());
				}
				return a;
			})();
		}
		__ks_func_foobar_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_foobar_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};