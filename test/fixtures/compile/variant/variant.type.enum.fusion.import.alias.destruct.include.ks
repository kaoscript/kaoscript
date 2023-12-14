include './variant.type.enum.fusion.export.alias.ks'

func Director(
	{ start, end }: Range
): SchoolPerson(Director) {
	return {
		kind: .Director
		start
		end
	}
}