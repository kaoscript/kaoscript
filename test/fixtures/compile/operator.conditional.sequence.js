module.exports = function() {
	function foo(lang) {
		if(lang === undefined || lang === null) {
			throw new Error("Missing parameter 'lang'");
		}
		let end = "";
		let begin = (lang === "en") ? (end = "goodbye", "hello") : "bonjour";
	}
}