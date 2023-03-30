const {Operator} = require("@kaoscript/runtime");
module.exports = function(Point, x) {
	const p = Point.__ks_new_0();
	p.log("start");
	p.x = x;
	p.scale(10);
	p.log("scaled");
	p.x = Operator.add(p.x, 1);
	p.y = Operator.add(x, p.x, p.y);
};