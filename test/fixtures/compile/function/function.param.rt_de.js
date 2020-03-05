var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	let foo = (() => {
		return function() {
			let __ks_i = -1;
			let items = [];
			while(arguments.length > ++__ks_i) {
				if(Type.isString(arguments[__ks_i])) {
					items.push(arguments[__ks_i]);
				}
				else {
					--__ks_i;
					break;
				}
			}
			let __ks__;
			let x = arguments.length > ++__ks_i && (__ks__ = arguments[__ks_i]) !== void 0 && __ks__ !== null ? __ks__ : 42;
			return [items, x];
		};
	})();
	expect(foo()).to.eql([[], 42]);
	expect(foo(1)).to.eql([[], 1]);
	expect(foo(true)).to.eql([[], true]);
	expect(foo(null)).to.eql([[], 42]);
	expect(foo("foo")).to.eql([["foo"], 42]);
	expect(foo("foo", 2)).to.eql([["foo"], 2]);
	expect(foo("foo", true)).to.eql([["foo"], true]);
	expect(foo("foo", null)).to.eql([["foo"], 42]);
	expect(foo("foo", "bar", "qux")).to.eql([["foo", "bar", "qux"], 42]);
	expect(foo("foo", "bar", "qux", 4)).to.eql([["foo", "bar", "qux"], 4]);
};