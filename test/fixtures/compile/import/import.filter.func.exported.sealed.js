require("kaoscript/register");
module.exports = function() {
	class Foobar {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
		__ks_func_toString_0() {
			return "foobar";
		}
		toString() {
			if(arguments.length === 0) {
				return Foobar.prototype.__ks_func_toString_0.apply(this);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	var {foobar, qux} = require("../export/export.filter.func.exported.sealed.ks")();
	console.log(qux("foobar"));
	const x = foobar();
	console.log(x.toString());
	console.log(qux(x).toString());
};