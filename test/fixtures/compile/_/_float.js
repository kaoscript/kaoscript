const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		function parse() {
			return parse.__ks_rt(this, arguments);
		};
		parse.__ks_0 = function(value = null) {
			return parseFloat(value);
		};
		parse.__ks_rt = function(that, args) {
			if(args.length <= 1) {
				return parse.__ks_0.call(that, args[0]);
			}
			throw Helper.badArgs();
		};
		return {
			parse
		};
	});
	return {
		Float
	};
};