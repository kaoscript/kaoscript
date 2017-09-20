module.exports = function() {
	function log(...args) {
		this.log.apply(this, args);
	}
	log.call(console, "hello");
};