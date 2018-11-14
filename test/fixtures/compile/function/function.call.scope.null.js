module.exports = function() {
	function log(...args) {
		console.log(...args);
	}
	log.call(null, "hello");
};