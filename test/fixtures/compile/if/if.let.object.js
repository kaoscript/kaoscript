var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		return {
			x: 1,
			y: 2
		};
	}
	let {x, y} = foobar();
	if(Type.isValue(x) && Type.isValue(y)) {
		console.log("" + x);
	}
};