module.exports = function(expect, Class, Type) {
	function foo() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		if(arguments.length > 1) {
			if(Type.isNumber(arguments[__ks_i + 1])) {
				var x = arguments[++__ks_i];
			}
			else  {
				throw new Error("Invalid type for parameter 'x'");
			}
		}
		else  {
			var x = null;
		}
		if(Type.isString(arguments[++__ks_i])) {
			var y = arguments[__ks_i];
		}
		else throw new Error("Invalid type for parameter 'y'")
		return [x, y];
	}
	expect(function() {
		return foo();
	}).to.throw();
	expect(function() {
		return foo(1);
	}).to.throw();
	expect(foo("foo")).to.eql([null, "foo"]);
	expect(foo(1, "foo")).to.eql([1, "foo"]);
	expect(function() {
		return foo("foo", "bar");
	}).to.throw();
}