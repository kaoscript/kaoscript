module.exports = function() {
	function foo() {
		try {
			console.log("hello");
		}
		catch(__ks_0) {
			return null;
		}
		return 42;
	}
};