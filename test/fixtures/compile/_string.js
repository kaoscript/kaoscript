module.exports = function(Array, __ks_Array, Class, Function, __ks_Function, Object, __ks_Object, Type) {
	var __ks_String = {};
	Class.newInstanceMethod({
		class: String,
		name: "lines",
		final: __ks_String,
		function: function(emptyLines) {
			if(emptyLines === undefined || emptyLines === null) {
				emptyLines = false;
			}
			if(this.length === 0) {
				return [];
			}
			else if(emptyLines) {
				return this.replace(/\r\n/g, "\n").replace(/\r/g, "\n").split("\n");
			}
			else {
				return this.match(/[^\r\n]+/g) || [];
			}
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	Class.newInstanceMethod({
		class: String,
		name: "lower",
		final: __ks_String,
		method: "toLowerCase",
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: [
			]
		}
	});
	Class.newInstanceMethod({
		class: String,
		name: "toFloat",
		final: __ks_String,
		function: function() {
			return parseFloat(this);
		},
		signature: {
			access: 3,
			min: 0,
			max: 0,
			parameters: [
			]
		}
	});
	Class.newInstanceMethod({
		class: String,
		name: "toInt",
		final: __ks_String,
		function: function(base) {
			if(base === undefined || base === null) {
				base = 10;
			}
			return parseInt(this, base);
		},
		signature: {
			access: 3,
			min: 0,
			max: 1,
			parameters: [
				{
					type: "Any",
					min: 0,
					max: 1
				}
			]
		}
	});
	return {
		String: String,
		__ks_String: __ks_String
	};
}