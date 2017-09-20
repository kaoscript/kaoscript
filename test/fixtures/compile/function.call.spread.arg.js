module.exports = function() {
	function log(...args) {
		this.log.apply(this, args);
	}
	const messages = ["hello", "world"];
	log.apply(console, messages);
};