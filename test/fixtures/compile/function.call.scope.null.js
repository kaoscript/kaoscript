module.exports = function() {
	function log(...args) {
		console.log.apply(console, args);
	}
	log.call(null, "hello");
};