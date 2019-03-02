module.exports = function() {
	var bar = [];
	function foo() {
		var args = Array.prototype.slice.call(arguments, 0, arguments.length);
		var foo = args;
	}
};