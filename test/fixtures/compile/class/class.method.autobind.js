var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init_1() {
			this._x = 0;
		}
		__ks_init() {
			Foobar.prototype.__ks_init_1.call(this);
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_x_0.apply(this);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
	const f = new Foobar();
	if(Type.isValue(f.x)) {
		console.log(f.x.bind(f));
	}
	let x = f.x.bind(f);
	console.log(x());
	console.log(f.x());
};