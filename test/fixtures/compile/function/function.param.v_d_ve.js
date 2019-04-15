module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 2) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks__;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 42;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			return [x, y, z];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, 42, 2]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3]);
};