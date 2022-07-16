require("kaoscript/register");
const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var ClassA = require("./.class.abstract.field.let.wt_i.nct.ks.j5k8r9.ksb")().ClassA;
	class ClassB extends ClassA {
		static __ks_new_0() {
			const o = Object.create(ClassB.prototype);
			o.__ks_init();
			o.__ks_cons_0();
			return o;
		}
		__ks_cons_0() {
			this._x = 0;
			this._y = 0;
		}
		__ks_cons_rt(that, args) {
			if(args.length === 0) {
				return ClassB.prototype.__ks_cons_0.call(that);
			}
			throw Helper.badArgs();
		}
	}
	return {
		ClassB
	};
};