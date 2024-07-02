const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.alias(value => Type.isDexObject(value, 1, Type.isValue, {color: Type.isString}));
	const o = (() => {
		const o = new OBJ();
		o.color = "red";
		return o;
	})();
	o.name = "White";
	console.log(o.name);
};