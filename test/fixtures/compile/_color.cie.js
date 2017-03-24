module.exports = function(Color, Space) {
	let ColorCIE = Color + "+cie";
	let SpaceCIE = Space + "+cie";
	return {
		Color: ColorCIE,
		Space: SpaceCIE
	};
}