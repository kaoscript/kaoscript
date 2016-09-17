module.exports = function(Color, Space) {
	Color += "+cie";
	Space += "+cie";
	return {
		Color: Color,
		Space: Space
	};
}