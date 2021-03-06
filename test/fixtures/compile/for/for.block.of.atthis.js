var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	class Matcher {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._likes = (() => {
				const d = new Dictionary();
				d.leto = "spice";
				d.paul = "chani";
				d.duncan = "murbella";
				return d;
			})();
		}
		__ks_init() {
			Matcher.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_print_0() {
			for(let key in this._likes) {
				let value = this._likes[key];
				console.log(Helper.concatString(key, " likes ", value));
			}
		}
		print() {
			if(arguments.length === 0) {
				return Matcher.prototype.__ks_func_print_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};