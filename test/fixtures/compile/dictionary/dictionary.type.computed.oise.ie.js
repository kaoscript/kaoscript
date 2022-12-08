const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
			this.values = new OBJ();
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	function set() {
		return set.__ks_rt(this, arguments);
	};
	set.__ks_0 = function(name, value) {
		const clone = Foobar.__ks_new_0();
		clone.values = (() => {
			const d = new OBJ();
			d[name] = value;
			return d;
		})();
		return clone;
	};
	set.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return set.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};