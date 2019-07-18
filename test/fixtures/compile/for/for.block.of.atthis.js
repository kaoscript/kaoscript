module.exports = function() {
	class Matcher {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._likes = {
				leto: "spice",
				paul: "chani",
				duncan: "murbella"
			};
		}
		__ks_init() {
			Matcher.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_print_0() {
			for(let key in this._likes) {
				let value = this._likes[key];
				console.log(key + " likes " + value);
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