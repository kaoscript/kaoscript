module.exports = function() {
	function log(...args) {
		this.log(...args);
	}
	log.call(console, "hello");
};