const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function getSupervisorName() {
		return getSupervisorName.__ks_rt(this, arguments);
	};
	getSupervisorName.__ks_0 = function(person) {
		let __ks_0, __ks_1;
		const newScore = Type.isValue(__ks_0 = (__ks_1 = getScoreOrNull(person), Type.isValue(__ks_1) ? boundScore(0, 100, add(7, __ks_double_1(__ks_1))) : null)) ? __ks_0 : 0;
		return newScore;
	};
	getSupervisorName.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return getSupervisorName.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};