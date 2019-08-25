module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			__ks_i = arguments.length - 1;
			let x = arguments[__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return [x];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([1]);
	expect(foo(1, 2)).to.eql([2]);
	expect(foo(1, 2, 3, 4)).to.eql([4]);
};