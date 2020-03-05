var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			let __ks_i = -1;
			let __ks__;
			let items = [];
			let __ks_l = Math.min(arguments.length, __ks_i + 4);
			while(++__ks_i < __ks_l) {
				__ks__ = arguments[__ks_i];
				if(__ks__ === void 0 || __ks__ === null || !Type.isNumber(__ks__)) {
					if(items.length >= 1) {
						break;
					}
					else {
						throw new TypeError("'items' is not of type 'Number'");
					}
				}
				else {
					items.push(__ks__);
				}
			}
			let values = Array.prototype.slice.call(arguments, __ks_i, arguments.length);
			return [items, values];
		};
	})();
	expect(() => {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[1], []]);
	expect(() => {
		return foo("foo");
	}).to.throw();
	expect(foo(1, 2)).to.eql([[1, 2], []]);
	expect(foo(1, "foo")).to.eql([[1], ["foo"]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3], []]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], [4]]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3], [4, 5]]);
	expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], [4, 5, 6]]);
	expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3], [4, 5, 6, 7]]);
};