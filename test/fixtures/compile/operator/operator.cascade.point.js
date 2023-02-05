const {Operator} = require("@kaoscript/runtime");
module.exports = function(Point, x) {
	const p = Point.__ks_new_0();
	let __ks_0;
	__ks_0.log("start");
	__ks_0.x = x;
	__ks_0.scale(10);
	__ks_0.log("scaled");
	__ks_0.x = Operator.add(__ks_0.x, 1);
	__ks_0.y = Operator.add(x, p.x, p.y);
};