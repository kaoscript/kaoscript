const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
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
			this._colors = [];
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		color() {
			return this.__ks_func_color_rt.call(null, this, this, arguments);
		}
		__ks_func_color_0(index) {
			return this._colors[index];
		}
		__ks_func_color_rt(that, proto, args) {
			const t0 = Type.isValue;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_color_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
	}
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(f, x) {
		if(Helper.valueOf(f.color(x)) === Color.Red.value) {
		}
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return quxbaz.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};