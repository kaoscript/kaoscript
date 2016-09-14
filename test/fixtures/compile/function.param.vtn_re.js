module.exports = function(expect, Class, Type) {
	function foo() {
		let __ks_i = -1;
		if(arguments.length > 0) {
			if(Type.isNumber(arguments[__ks_i + 1])) {
				var x = arguments[++__ks_i];
			}
			else  {
				var x = null;
			}
		}
		else  {
			var x = null;
		}
		let items = arguments.length > ++__ks_i ? Array.prototype.slice.call(arguments, __ks_i, __ks_i = arguments.length) : [];
		return [x, items];
	}
	expect(foo()).to.eql([null, []]);
	expect(foo(1)).to.eql([1, []]);
	expect(foo("foo")).to.eql([null, ["foo"]]);
	expect(foo(1, 2)).to.eql([1, [2]]);
	expect(foo("foo", 1)).to.eql([null, ["foo", 1]]);
}