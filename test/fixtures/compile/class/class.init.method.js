module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._foo = this.qux();
		}
		__ks_init() {
			Foobar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_qux_0() {
			return 42;
		}
		qux() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_qux_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
};