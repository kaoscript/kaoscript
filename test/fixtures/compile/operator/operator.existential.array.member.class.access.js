var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Point {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons_0(x, y) {
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
			this.x = x;
			this.y = y;
		}
		__ks_cons(args) {
			if(args.length === 2) {
				Point.prototype.__ks_cons_0.apply(this, args);
			}
			else {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	function foobar(points) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(points === void 0 || points === null) {
			throw new TypeError("'points' is not nullable");
		}
		else if(!Type.isArray(points)) {
			throw new TypeError("'points' is not of type 'Array<Point>'");
		}
		return Type.isValue(points[0]) ? points[0].x : null;
	}
};