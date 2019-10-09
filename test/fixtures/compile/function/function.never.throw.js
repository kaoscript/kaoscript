module.exports = function() {
	class FoobarError extends Error {
		constructor() {
			super(...arguments);
			this.constructor.prototype.__ks_init();
		}
		__ks_init() {
		}
	}
	function foobar() {
		throw new FoobarError();
	}
	return {
		FoobarError: FoobarError,
		foobar: foobar
	};
};