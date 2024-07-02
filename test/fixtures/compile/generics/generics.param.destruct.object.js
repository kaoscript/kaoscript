const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const Event = Helper.alias((value, mapper) => Type.isDexObject(value, 1, 0, {value: () => true, line: Type.isNumber, column: Type.isNumber}));
	const Data = Helper.alias(value => Type.isDexObject(value, 1, 0, {value: Type.isNumber}));
	function getPosition() {
		return getPosition.__ks_rt(this, arguments);
	};
	getPosition.__ks_0 = function({line, column}) {
		console.log(line + column);
		return (() => {
			const o = new OBJ();
			o.line = line;
			o.column = column;
			return o;
		})();
	};
	getPosition.__ks_rt = function(that, args) {
		const t0 = value => Event.is(value, [Data.is]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return getPosition.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};