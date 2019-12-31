var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_JSON) {
	if(!Type.isValue(__ks_JSON)) {
		__ks_JSON = {};
	}
	__ks_JSON.foobar = function(...args) {
	};
	let coord = (() => {
		const d = new Dictionary();
		d.x = 1;
		d.y = 1;
		return d;
	})();
	console.log(JSON.stringify(coord));
};