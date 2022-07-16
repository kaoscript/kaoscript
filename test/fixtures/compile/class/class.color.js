const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Space = Helper.enum(String, {
		RGB: "rgb"
	});
	class Color {
		static __ks_new_0() {
			const o = Object.create(Color.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._blue = 0;
			this._green = 0;
			this._red = 0;
			this._space = Space.RGB;
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		space() {
			return this.__ks_func_space_rt.call(null, this, this, arguments);
		}
		__ks_func_space_0() {
			return this._space;
		}
		__ks_func_space_1(space) {
			this._space = space;
			return this;
		}
		__ks_func_space_rt(that, proto, args) {
			const t0 = value => Type.isEnumInstance(value, Space);
			if(args.length === 0) {
				return proto.__ks_func_space_0.call(that);
			}
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_space_1.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	return {
		Color,
		Space
	};
};