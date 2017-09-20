module.exports = function() {
	function foo() {
		try {
			bar();
		}
		catch(__ks_0) {
			console.log("catch");
			throw new Error();
		}
		finally {
			console.log("finally");
		}
	}
	function bar() {
		throw new Error();
	}
};