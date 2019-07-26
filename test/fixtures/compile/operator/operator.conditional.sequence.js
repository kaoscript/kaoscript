module.exports = function() {
	function foo(lang) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(lang === void 0 || lang === null) {
			throw new TypeError("'lang' is not nullable");
		}
		let end = "";
		let begin = (lang === "en") ? (end = "goodbye", "hello") : "bonjour";
	}
};