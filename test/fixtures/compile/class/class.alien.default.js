var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_ClassA = {};
	class ClassB extends ClassA {
		constructor(x, y) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			else if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
			super(x, y);
			this.constructor.prototype.__ks_init();
			this._z = x * y;
		}
		__ks_init_1() {
			this._z = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init_1.call(this);
		}
	}
	class ClassC extends ClassB {
		constructor(x, y) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			if(y === void 0 || y === null) {
				throw new TypeError("'y' is not nullable");
			}
			else if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
			super(x, y);
			this._w = this._z * this._z;
		}
		__ks_init_1() {
			this._w = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
			ClassC.prototype.__ks_init_1.call(this);
		}
	}
	return {
		ClassA: ClassA,
		__ks_ClassA: __ks_ClassA,
		ClassB: ClassB,
		ClassC: ClassC
	};
};