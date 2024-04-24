require("kaoscript/register");
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	const $formatters = new OBJ();
	function format() {
		return format.__ks_rt(this, arguments);
	};
	format.__ks_0 = function(name) {
		let formatter, space;
		if(((Type.isDexObject($formatters[name], 1, 0, {formatter: Type.isValue, space: Type.isValue})) ? (({formatter, space} = $formatters[name]), true) : false)) {
			return formatter(space);
		}
		else {
			return false;
		}
	};
	format.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return format.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};