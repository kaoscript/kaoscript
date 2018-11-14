module.exports = function() {
	function log(...args) {
		console.log(...args);
	}
	const messages = ["hello", "world"];
	log.call(null, ...messages);
};