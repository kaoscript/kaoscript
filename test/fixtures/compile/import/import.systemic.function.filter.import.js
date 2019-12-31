require("kaoscript/register");
module.exports = function() {
	var template = require("./import.systemic.function.filter.default.ks")().template;
	return {
		template: template
	};
};