var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (function() {
		return function() {
			if(arguments.length < 2) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
			}
			let __ks_i = -1;
			let items = [];
			let __ks__ = arguments.length - 1;
			while(__ks__ > ++__ks_i) {
				if(Type.isNumber(arguments[__ks_i])) {
					items.push(arguments[__ks_i]);
				}
				else {
					--__ks_i;
					break;
				}
			}
			if(items.length < 1) {
				throw new SyntaxError("The rest parameter must have at least 1 argument (" + items.length + ")");
			}
			let x = arguments[__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return [items, x];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([[1], 2]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4]);
};