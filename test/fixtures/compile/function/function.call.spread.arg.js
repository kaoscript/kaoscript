module.exports = function() {
	function log(...args) {
		this.log(...args);
	}
	const messages = ["hello", "world"];
	log.call(console, ...messages);
};