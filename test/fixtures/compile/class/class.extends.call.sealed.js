const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ks_Object = {};
	__ks_Object.__ks_sttc_merge_0 = function(args) {
		return new OBJ();
	};
	__ks_Object._sm_merge = function() {
		return __ks_Object.__ks_sttc_merge_0(Array.from(arguments));
	};
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
		__ks_cons_0(options) {
			this._x = Helper.assertNumber(options.x, 0);
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
	}
	class Quxbaz extends Foobar {
		static __ks_new_0(...args) {
			const o = Object.create(Quxbaz.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(options = null) {
			Foobar.prototype.__ks_cons_0.call(this, __ks_Object.__ks_sttc_merge_0([(() => {
				const o = new OBJ();
				o.x = 0;
				o.y = 0;
				return o;
			})(), options]));
		}
		__ks_cons_rt(that, args) {
			if(args.length <= 1) {
				return Quxbaz.prototype.__ks_cons_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		}
	}
};