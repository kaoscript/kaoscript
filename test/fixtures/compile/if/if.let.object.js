var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return {
			x: 1,
			y: 2
		};
	}
	let x, y;
	if(Type.isValue({x, y} = foobar())) {
		console.log("" + x);
	}
};