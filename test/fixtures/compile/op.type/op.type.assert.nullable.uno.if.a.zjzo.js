const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPoint: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber}),
		isPoint3D: value => __ksType.isPoint(value) && Type.isDexObject(value, 1, 0, {z: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(p) {
		let d3;
		if((Type.isValue(Helper.assert(p, "\"Point3D\"", 1, __ksType.isPoint3D)) ? (d3 = p, true) : false)) {
			console.log(d3.x + 1, d3.y + 2, d3.z + 3);
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