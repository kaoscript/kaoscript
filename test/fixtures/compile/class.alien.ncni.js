var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var __ks_ClassA = {};
	class ClassB extends ClassA {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
	class ClassC extends ClassB {
		constructor(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			super();
			this._x = x;
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
		}
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return ClassC.prototype.__ks_func_x_0.apply(this);
			}
			else if(ClassB.prototype.x) {
				return ClassB.prototype.x.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
}