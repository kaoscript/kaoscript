const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.alias(value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber}));
	const Point3D = Helper.alias(value => Point.is(value) && Type.isDexObject(value, 1, 0, {z: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(p) {
		let d3;
		if((Type.isValue(p) ? (d3 = p, true) : false)) {
			console.log(d3.x + 1, d3.y + 2);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Point3D.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};