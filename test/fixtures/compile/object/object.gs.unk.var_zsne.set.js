const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isColor: value => Type.isDexObject(value, 1, 0, {color: value => Type.isString(value) || Type.isNull(value)})
	};
	const o = new OBJ();
	o.color = "red";
	console.log(Helper.toString(o.color));
};