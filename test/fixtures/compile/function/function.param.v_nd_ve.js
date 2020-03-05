module.exports = function(expect) {
	let foo = (() => {
		return function(x) {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			let __ks_i = 0;
			let __ks__;
			let y = arguments.length > 2 && (__ks__ = arguments[++__ks_i]) !== void 0 ? __ks__ : null;
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			return [x, y, z];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(() => {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, null, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3]);
};