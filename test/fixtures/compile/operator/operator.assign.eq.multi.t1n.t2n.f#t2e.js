const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isPoint2D: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber}),
		isPoint3D: value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber, z: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		let d2 = null;
		let d3 = null;
		d2 = d3 = quxbaz.__ks_0();
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.x = 0;
			o.y = 0;
			o.z = 0;
			return o;
		})();
	};
	quxbaz.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return quxbaz.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};