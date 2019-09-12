module.exports = function() {
	function getIndex() {
		return 0;
	}
	function translate(statements, extending) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(statements === void 0 || statements === null) {
			throw new TypeError("'statements' is not nullable");
		}
		if(extending === void 0 || extending === null) {
			throw new TypeError("'extending' is not nullable");
		}
		let index = 1;
		if(((index = getIndex()) === -1) && (extending === true)) {
		}
		for(let __ks_0 = 0, __ks_1 = statements.length, statement; __ks_0 < __ks_1; ++__ks_0) {
			statement = statements[__ks_0];
			statement.analyse();
		}
	}
};