module.exports = function() {
	class Master {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this.a = "";
		}
		__ks_init() {
			Master.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_foobar_0(a) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(a === void 0 || a === null) {
				throw new TypeError("'a' is not nullable");
			}
		}
		foobar() {
			if(arguments.length === 1) {
				return Master.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class Foobar extends Master {
		__ks_init_1() {
			this.b = "";
		}
		__ks_init() {
			Master.prototype.__ks_init.call(this);
			Foobar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			Master.prototype.__ks_cons.call(this, args);
		}
		__ks_func_foobar_0(a, b) {
			if(a === void 0 || a === null) {
				a = this.a;
			}
			if(b === void 0 || b === null) {
				b = this.b;
			}
			return b;
		}
		foobar() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
			}
			else if(arguments.length === 1) {
				if(true) {
					return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
				else if(true) {
					return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
			}
			else if(arguments.length === 2) {
				if(true && true) {
					return Foobar.prototype.__ks_func_foobar_0.apply(this, arguments);
				}
			}
			return Master.prototype.foobar.apply(this, arguments);
		}
	}
	const f = new Foobar();
	f.foobar("", "");
};