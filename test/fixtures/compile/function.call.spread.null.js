module.exports = function() {
	function log(...args) {
		console.log.apply(console, args);
	}
	const messages = ["hello", "world"];
	log.apply(null, messages);
}