module.exports = function(expect, Helper, Type) {
	function foo() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		if(arguments.length > 1) {
			var x = arguments[++__ks_i];
		}
		else  {
			var x = null;
		}
		if(arguments.length > 2) {
			var y = arguments[++__ks_i];
		}
		else  {
			var y = null;
		}
		var z = arguments[++__ks_i];
		return [x, y, z];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([null, null, 1]);
	expect(foo(1, 2)).to.eql([1, null, 2]);
	expect(foo(1, 2, 3)).to.eql([1, 2, 3]);
}