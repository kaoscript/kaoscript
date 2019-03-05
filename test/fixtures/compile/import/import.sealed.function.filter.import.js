require("kaoscript/register");
module.exports = function() {
	var template = require("./import.sealed.function.filter.default.ks")().template;
	return {
		template: template
	};
};