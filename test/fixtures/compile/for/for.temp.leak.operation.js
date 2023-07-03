const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function getIndex() {
		return getIndex.__ks_rt(this, arguments);
	};
	getIndex.__ks_0 = function() {
		return 0;
	};
	getIndex.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return getIndex.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function translate() {
		return translate.__ks_rt(this, arguments);
	};
	translate.__ks_0 = function(statements, extending) {
		let index = 1;
		if(((index = getIndex.__ks_0()) === -1) && (extending === true)) {
		}
		let statement;
		for(let __ks_1 = 0, __ks_0 = statements.length; __ks_1 < __ks_0; ++__ks_1) {
			statement = statements[__ks_1];
			statement.analyse();
		}
	};
	translate.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return translate.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};