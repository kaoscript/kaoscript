module.exports = function() {
	class MyError extends Error {
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
		foo: foo,
		MyError: MyError
	};
};