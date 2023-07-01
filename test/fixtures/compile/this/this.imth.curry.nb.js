const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const PetKind = Helper.enum(Number, {
		Cat: 0,
		Dog: 1
	});
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
		kind() {
			return this.__ks_func_kind_rt.call(null, this, this, arguments);
		}
		__ks_func_kind_0() {
			return PetKind.Cat;
		}
		__ks_func_kind_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_kind_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	const cat = Pet.__ks_new_0();
	console.log(Helper.curry((that, fn, ...args) => {
		if(args.length === 0) {
			return fn[0]();
		}
		throw Helper.badArgs();
	}, () => cat.__ks_func_kind_0())());
};