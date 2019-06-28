module.exports = function() {
	function foobar([x, y]) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		console.log("" + x + "." + y);
	}
};