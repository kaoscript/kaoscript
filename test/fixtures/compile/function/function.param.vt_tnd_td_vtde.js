var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			let __ks_i = 0;
			let y;
			if(arguments.length > __ks_i + 2 && (y = arguments[++__ks_i]) !== void 0) {
				if(y !== null && !Type.isString(y)) {
					if(arguments.length - __ks_i < 3) {
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
			if(arguments.length > __ks_i + 2 && (z = arguments[++__ks_i]) !== void 0 && z !== null) {
				if(!Type.isBoolean(z)) {
					if(arguments.length - __ks_i < 2) {
						z = false;
						--__ks_i;
					}
					else {
						throw new TypeError("'z' is not of type 'Boolean'");
					}
				}
			}
			else {
				z = false;
			}
			let a = arguments[++__ks_i];
			if(a === void 0 || a === null) {
				a = 0;
			}
			else if(!Type.isNumber(a)) {
				throw new TypeError("'a' is not of type 'Number'");
			}
			return [x, y, z, a];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(() => {
		return foo("foo");
	}).to.throw();
	expect(() => {
		return foo(true);
	}).to.throw();
	expect(() => {
		return foo(42);
	}).to.throw();
	expect(foo("foo", 42)).to.eql(["foo", null, false, 42]);
	expect(foo("foo", null)).to.eql(["foo", null, false, 0]);
	expect(() => {
		return foo("foo", "bar");
	}).to.throw();
	expect(() => {
		return foo("foo", true);
	}).to.throw();
	expect(() => {
		return foo("foo", []);
	}).to.throw();
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", false, 42]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false, 0]);
	expect(foo("foo", null, null)).to.eql(["foo", null, false, 0]);
	expect(foo("foo", null, 42)).to.eql(["foo", null, false, 42]);
	expect(foo("foo", true, 42)).to.eql(["foo", null, true, 42]);
	expect(() => {
		return foo("foo", "bar", true);
	}).to.throw();
	expect(() => {
		return foo("foo", "bar", "qux");
	}).to.throw();
	expect(() => {
		return foo("foo", "bar", []);
	}).to.throw();
	expect(() => {
		return foo("foo", 42, "qux");
	}).to.throw();
	expect(() => {
		return foo("foo", true, "qux");
	}).to.throw();
	expect(foo("foo", "bar", true, 42)).to.eql(["foo", "bar", true, 42]);
	expect(foo("foo", "bar", true, null)).to.eql(["foo", "bar", true, 0]);
	expect(foo("foo", null, null, null)).to.eql(["foo", null, false, 0]);
	expect(() => {
		return foo("foo", "bar", true, "qux");
	}).to.throw();
};