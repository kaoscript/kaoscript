var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function(x) {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			let __ks_i = 0;
			let y;
			if(arguments.length > ++__ks_i && (y = arguments[__ks_i]) !== void 0) {
				if(y !== null && !Type.isString(y)) {
					if(arguments.length - __ks_i < 2) {
						y = null;
						--__ks_i;
					}
					else {
						throw new TypeError("'y' is not of type 'String?'");
					}
				}
			}
			else {
				y = null;
			}
			let z;
			if(arguments.length > ++__ks_i && (z = arguments[__ks_i]) !== void 0 && z !== null) {
				if(!Type.isBoolean(z)) {
					throw new TypeError("'z' is not of type 'Boolean'");
				}
			}
			else {
				z = false;
			}
			return [x, y, z];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo("foo")).to.eql(["foo", null, false]);
	expect(() => {
		return foo(true);
	}).to.throw();
	expect(() => {
		return foo(42);
	}).to.throw();
	expect(foo("foo", "bar")).to.eql(["foo", "bar", false]);
	expect(foo("foo", true)).to.eql(["foo", null, true]);
	expect(() => {
		return foo("foo", 42);
	}).to.throw();
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true]);
	expect(() => {
		return foo("foo", "bar", "qux");
	}).to.throw();
	expect(() => {
		return foo("foo", "bar", 42);
	}).to.throw();
	expect(() => {
		return foo("foo", 42, "qux");
	}).to.throw();
	expect(() => {
		return foo("foo", true, "qux");
	}).to.throw();
};