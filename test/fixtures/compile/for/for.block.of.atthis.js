const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	class Matcher {
		static __ks_new_0() {
			const o = Object.create(Matcher.prototype);
			o.__ks_init();
			return o;
		}
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
			this._likes = (() => {
				const d = new OBJ();
				d.leto = "spice";
				d.paul = "chani";
				d.duncan = "murbella";
				return d;
			})();
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
		print() {
			return this.__ks_func_print_rt.call(null, this, this, arguments);
		}
		__ks_func_print_0() {
			for(let key in this._likes) {
				let value = this._likes[key];
				console.log(Helper.concatString(key, " likes ", value));
			}
		}
		__ks_func_print_rt(that, proto, args) {
			if(args.length === 0) {
				return proto.__ks_func_print_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
};