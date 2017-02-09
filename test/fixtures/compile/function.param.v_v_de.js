module.exports = function(expect) {
	function foo() {
		if(arguments.length < 2) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		var x = arguments[++__ks_i];
		var y = arguments[++__ks_i];
		if(arguments.length > 2) {
			var z = arguments[++__ks_i];
		}
		else {
			var z = 24;
		}
		return [x, y, z];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo(1, 2)).to.eql([1, 2, 24]);
	expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3]);
}