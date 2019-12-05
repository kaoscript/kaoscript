var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isString(x)) {
			throw new TypeError("'x' is not of type 'String'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isNumber(y)) {
			throw new TypeError("'y' is not of type 'Number'");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
		else if(!Type.isBoolean(z)) {
			throw new TypeError("'z' is not of type 'Boolean'");
		}
		const xyz = (() => {
			const d = new Dictionary();
			d.x = x;
			d.y = y;
			d.z = z;
			return d;
		})();
		return (() => {
			const d = new Dictionary();
			d.x = xyz.x;
			d.y = xyz.y + 42;
			d.z = !xyz.z;
			return d;
		})();
	}
};