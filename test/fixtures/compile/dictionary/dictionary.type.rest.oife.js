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
			this.args = new OBJ();
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	function clone() {
		return clone.__ks_rt(this, arguments);
	};
	clone.__ks_0 = function(source) {
		const clone = Foobar.__ks_new_0();
		clone.args = Helper.newObject(-1, source.args);
		return clone;
	};
	clone.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Foobar);
		if(args.length === 1) {
			if(t0(args[0])) {
				return clone.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};