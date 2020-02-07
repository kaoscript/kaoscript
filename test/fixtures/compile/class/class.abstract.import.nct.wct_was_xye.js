require("kaoscript/register");
module.exports = function() {
	var ClassA = require("./class.abstract.field.let.wt_i.nct.ks")().ClassA;
	class ClassB extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons_0() {
			ClassA.prototype.__ks_cons.call(this, []);
			this._x = 0;
			this._y = 0;
		}
		__ks_cons(args) {
			if(args.length === 0) {
				ClassB.prototype.__ks_cons_0.apply(this);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	return {
		ClassB: ClassB
	};
};