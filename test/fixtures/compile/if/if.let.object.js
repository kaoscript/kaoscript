var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return (() => {
			const d = new Dictionary();
			d.x = 1;
			d.y = 2;
			return d;
		})();
	}
	let {x, y} = foobar();
	if(Type.isValue(x) && Type.isValue(y)) {
		console.log("" + x);
	}
};