require("kaoscript/register");
const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_String = require("../_/._string.ks.j5k8r9.ksb")().__ks_String;
	const $formatters = new Dictionary();
	function format() {
		return format.__ks_rt(this, arguments);
	};
	format.__ks_0 = function(format) {
		let __ks_format_1 = $formatters[format];
		if(Type.isValue(__ks_format_1)) {
			return __ks_format_1.formatter(__ks_format_1.space);
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