require("kaoscript/register");
module.exports = function() {
	var ClassA = require("./class.abstract.field.let.wt_i.wct_was_xye.ks")().ClassA;
	class ClassB extends ClassA {
		__ks_init() {
			ClassA.prototype.__ks_init.call(this);
		}
		__ks_cons(args) {
			ClassA.prototype.__ks_cons.call(this, args);
		}
	}
	return {
		ClassB: ClassB
	};
};