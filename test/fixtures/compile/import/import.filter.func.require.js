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
	var foobar = require("../export/export.filter.func.require.ks")(Foobar).foobar;
	console.log(foobar("foobar"));
	const x = new Foobar();
	console.log(foobar(x).toString());
};