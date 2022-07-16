module.exports = function() {
	var __ks_ClassA = {};
	class ClassB extends ClassA {
		constructor(x, y) {
			super(x, y);
			this.constructor.prototype.__ks_init();
			this._z = x * y;
		}
		__ks_init_0() {
			this._z = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init_0.call(this);
		}
	}
	class ClassC extends ClassB {
		constructor(x, y) {
			super(x, y);
			this._w = this._z * this._z;
		}
		__ks_init_0() {
			this._w = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
			ClassC.prototype.__ks_init_0.call(this);
		}
	}
	return {
		ClassA,
		__ks_ClassA,
		ClassB,
		ClassC
	};
};