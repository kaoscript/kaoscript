const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.alias(value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber}));
	const Point3D = Helper.alias(value => Type.isDexObject(value, 1, 0, {a: Type.isNumber, b: Type.isNumber, c: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(p) {
		const d3 = Helper.assert(p, "\"Point\" or \"Point3D\"", 1, value => Point.is(value) || Point3D.is(value));
		if(d3 !== null) {
			if(Point.is(d3)) {
				console.log(d3.x + 1, d3.y + 2);
			}
			else {
				console.log(d3.a + 1, d3.b + 2, d3.c + 3);
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};