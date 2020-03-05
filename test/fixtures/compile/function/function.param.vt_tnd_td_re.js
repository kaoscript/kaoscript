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
					y = null;
					--__ks_i;
				}
			}
			else {
				y = null;
			}
			let z;
			if(arguments.length > ++__ks_i && (z = arguments[__ks_i]) !== void 0 && z !== null) {
				if(!Type.isBoolean(z)) {
					z = false;
					--__ks_i;
				}
			}
			else {
				z = false;
			}
			let args = Array.prototype.slice.call(arguments, ++__ks_i, arguments.length);
			return [x, y, z, args];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo("foo")).to.eql(["foo", null, false, []]);
	expect(() => {
		return foo(true);
	}).to.throw();
	expect(() => {
		return foo(42);
	}).to.throw();
	expect(foo("foo", "bar")).to.eql(["foo", "bar", false, []]);
	expect(foo("foo", true)).to.eql(["foo", null, true, []]);
	expect(foo("foo", 42)).to.eql(["foo", null, false, [42]]);
	expect(foo("foo", null)).to.eql(["foo", null, false, []]);
	expect(foo("foo", 42, 24, 18)).to.eql(["foo", null, false, [42, 24, 18]]);
	expect(foo("foo", [])).to.eql(["foo", null, false, [[]]]);
	expect(foo("foo", "bar", true)).to.eql(["foo", "bar", true, []]);
	expect(foo("foo", "bar", 42)).to.eql(["foo", "bar", false, [42]]);
	expect(foo("foo", "bar", null)).to.eql(["foo", "bar", false, []]);
	expect(foo("foo", "bar", 42, 24, 18)).to.eql(["foo", "bar", false, [42, 24, 18]]);
	expect(foo("foo", null, null)).to.eql(["foo", null, false, []]);
	expect(foo("foo", "bar", "qux")).to.eql(["foo", "bar", false, ["qux"]]);
	expect(foo("foo", 42, "qux")).to.eql(["foo", null, false, [42, "qux"]]);
	expect(foo("foo", true, "qux")).to.eql(["foo", null, true, ["qux"]]);
	expect(foo("foo", "bar", true, 42)).to.eql(["foo", "bar", true, [42]]);
	expect(foo("foo", "bar", true, 42, 24, 18)).to.eql(["foo", "bar", true, [42, 24, 18]]);
	expect(foo("foo", null, null, 42, 24, 18)).to.eql(["foo", null, false, [42, 24, 18]]);
};