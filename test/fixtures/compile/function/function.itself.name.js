module.exports = function() {
	function foo() {
		const cache = foo.cache;
	}
	foo.cache = {};
};