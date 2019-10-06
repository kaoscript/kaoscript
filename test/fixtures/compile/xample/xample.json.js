var {Dictionary, Type} = require("@kaoscript/runtime");
function __ks_require(__ks_0, __ks___ks_0) {
	var req = [];
	if(Type.isValue(__ks_0)) {
		req.push(__ks_0, __ks___ks_0);
	}
	else {
		req.push(JSON, typeof __ks_JSON === "undefined" ? {} : __ks_JSON);
	}
	return req;
}
module.exports = function(__ks_0, __ks___ks_0) {
	var [JSON, __ks_JSON] = __ks_require(__ks_0, __ks___ks_0);
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