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
			super();
			this.constructor.prototype.__ks_init();
			this._x = x;
			this._y = y;
		}
		__ks_init_1() {
			this._x = 0;
			this._y = 0;
		}
		__ks_init() {
			ClassB.prototype.__ks_init_1.call(this);
		}
		__ks_func_x_0() {
			return this._x;
		}
		x() {
			if(arguments.length === 0) {
				return ClassB.prototype.__ks_func_x_0.apply(this);
			}
			else if(ClassA.prototype.x) {
				return ClassA.prototype.x.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
		__ks_func_y_0() {
			return this._y;
		}
		y() {
			if(arguments.length === 0) {
				return ClassB.prototype.__ks_func_y_0.apply(this);
			}
			else if(ClassA.prototype.y) {
				return ClassA.prototype.y.apply(this, arguments);
			}
			throw new SyntaxError("Wrong number of arguments");
		}
	}
	class ClassC extends ClassB {
		constructor() {
			super(...arguments);
		}
		__ks_init() {
			ClassB.prototype.__ks_init.call(this);
		}
	}
};