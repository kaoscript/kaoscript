var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		function foobar() {
			return 42;
		}
		return {
			foobar: foobar
		};
	});
	Foobar.quxbaz = function(foobar) {
		if(foobar === void 0 || foobar === null) {
			foobar = Foobar.foobar();
		}
	};
};