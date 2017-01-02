module.exports = function(expect, Helper, Type) {
	function foo() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		if(arguments.length > 1) {
			var x = arguments[++__ks_i];
		}
		else {
			var x = null;
		}
		++__ks_i;
		if(arguments.length > 2) {
			var z = arguments[++__ks_i];
		}
		else {
			var z = null;
		}
		return [x, z];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([null, null]);
	expect(foo(1, 2)).to.eql([1, null]);
	expect(foo(1, 2, 3)).to.eql([1, 3]);
}