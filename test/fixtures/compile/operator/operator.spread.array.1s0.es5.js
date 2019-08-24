module.exports = function() {
	var bar = [];
	function foo() {
		var args = arguments.length > 0 ? Array.prototype.slice.call(arguments, 0, arguments.length) : [];
		var foo = [].concat([42], args);
	}
};