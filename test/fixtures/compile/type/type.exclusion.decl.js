const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Instance = Helper.alias(value => !Type.isPrimitive(value) && !Type.isArray(value));
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
	}
	let x = Foobar.__ks_new_0();
};