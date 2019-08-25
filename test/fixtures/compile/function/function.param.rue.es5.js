module.exports = function(expect) {
	var foo = (function() {
		return function() {
			if(arguments.length < 1) {
				throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
			}
			var items = Array.prototype.slice.call(arguments, 0, arguments.length);
			return [items];
		};
	})();
	expect(function() {
		return foo();
	}).to.throw();
	expect(foo(1)).to.eql([[1]]);
	expect(foo(1, 2)).to.eql([[1, 2]]);
	expect(foo(1, 2, 3)).to.eql([[1, 2, 3]]);
	expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3, 4]]);
};