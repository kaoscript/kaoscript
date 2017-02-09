var Type = require("@kaoscript/runtime").Type;
module.exports = function(expect) {
	function foo() {
		let __ks_i = -1;
		let items = [];
		while(Type.isString(arguments[++__ks_i])) {
			items.push(arguments[__ks_i]);
		}
		let __ks_m = __ks_i;
		if(arguments.length > __ks_m) {
			var x = arguments[__ks_i];
		}
		else {
			var x = 42;
		}
		return [items, x];
	}
	expect(foo()).to.eql([[], 42]);
	expect(foo(1)).to.eql([[], 1]);
	expect(foo("foo")).to.eql([["foo"], 42]);
	expect(foo("foo", 2)).to.eql([["foo"], 2]);
	expect(foo("foo", "bar", "qux")).to.eql([["foo", "bar", "qux"], 42]);
	expect(foo("foo", "bar", "qux", 4)).to.eql([["foo", "bar", "qux"], 4]);
}