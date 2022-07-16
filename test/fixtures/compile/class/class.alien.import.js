require("kaoscript/register");
module.exports = function() {
	var {ClassA, __ks_ClassA, ClassB, ClassC} = require("../class/.class.alien.default.ks.j5k8r9.ksb")();
	class ClassD extends ClassB {
		constructor(x, y) {
			super(x, y);
			this._w = this._z * this._z;
		}
		__ks_init_0() {
			this._w = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
			ClassD.prototype.__ks_init_0.call(this);
		}
	}
};