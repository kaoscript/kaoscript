const {Helper, OBJ} = require("@kaoscript/runtime");
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
		data() {
			return this.__ks_func_data_rt.call(null, this, this, arguments);
		}
		__ks_func_data_0() {
			this._z = 1;
			return (() => {
				const o = new OBJ();
				o.x = this._x;
				o.y = this._y;
				o.power = (() => {
					const o = new OBJ();
					o.z = this._z;
					return o;
				})();
				return o;
			})();
		}
		__ks_func_data_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_data_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};