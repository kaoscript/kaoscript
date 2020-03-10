module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_0() {
			this._x = 0;
		}
		__ks_init() {
			Foobar.prototype.__ks_init_0.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_x_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	const f = new Foobar();
	let x = f.x.bind(f);
	console.log(x());
	console.log(f.x());
};