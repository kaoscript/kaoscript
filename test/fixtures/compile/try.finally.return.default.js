module.exports = function() {
	function foo() {
		try {
			console.log("try");
			return 42;
		}
		finally {
			console.log("finally");
		}
	}
}