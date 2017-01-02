module.exports = function(expect, Helper, Type) {
	function foo() {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		if(arguments.length > 2) {
			var u = arguments[++__ks_i];
		}
		else {
			var u = null;
		}
		var v = arguments[++__ks_i];
		var x = arguments[++__ks_i];
		if(arguments.length > 3) {
			var y = arguments[++__ks_i];
		}
		else {
			var y = null;
		}
		if(arguments.length > 4) {
			var z = arguments[++__ks_i];
		}
		else {
			var z = null;
		}
		return [u, v, x, y, z];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([null, 1, 2, null, null]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null]);
	expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5]);
}