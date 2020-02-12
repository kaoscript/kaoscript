var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return (() => {
			const d = new Dictionary();
			d.x = 1;
			d.y = 2;
			return d;
		})();
	}
	let x, y, __ks_0;
	if(Type.isValue(__ks_0 = foobar()) ? ({x, y} = __ks_0, true) : false) {
		console.log(Helper.toString(x));
	}
};