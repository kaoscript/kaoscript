module.exports = function() {
	var __ks_SyntaxError = {};
	class MyError extends SyntaxError {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
	function foo() {
	}
	return {
		foo: foo
	};
};