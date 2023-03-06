const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Pet {
		static __ks_new_0() {
			const o = Object.create(Pet.prototype);
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
		static __ks_sttc_kinds_0() {
			return ["cat", "dog"];
		}
		static kinds() {
			if(arguments.length === 0) {
				return Pet.__ks_sttc_kinds_0();
			}
			throw Helper.badArgs();
		}
	}
	console.log(Pet.__ks_sttc_kinds_0());
};