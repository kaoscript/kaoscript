var $assignmentOperators = {
	[OperatorKind.Addition]				: AssignmentOperatorAddition
	[OperatorKind.BitwiseAnd]			: AssignmentOperatorBitwiseAnd
	[OperatorKind.BitwiseLeftShift]		: AssignmentOperatorBitwiseLeftShift
	[OperatorKind.BitwiseOr]			: AssignmentOperatorBitwiseOr
	[OperatorKind.BitwiseRightShift]	: AssignmentOperatorBitwiseRightShift
	[OperatorKind.BitwiseXor]			: AssignmentOperatorBitwiseXor
	[OperatorKind.Division]				: AssignmentOperatorDivision
	[OperatorKind.Empty]				: AssignmentOperatorEmpty
	[OperatorKind.EmptyCoalescing]		: AssignmentOperatorEmptyCoalescing
	[OperatorKind.Equals]				: AssignmentOperatorEquals
	[OperatorKind.Existential]			: AssignmentOperatorExistential
	[OperatorKind.Finite]				: AssignmentOperatorFinite
	[OperatorKind.IntegerDivision]		: AssignmentOperatorDivisionInteger
	[OperatorKind.LogicalAnd]			: AssignmentOperatorLogicalAnd
	[OperatorKind.LogicalOr]			: AssignmentOperatorLogicalOr
	[OperatorKind.LogicalXor]			: AssignmentOperatorLogicalXor
	[OperatorKind.Modulus]				: AssignmentOperatorModulus
	[OperatorKind.Multiplication]		: AssignmentOperatorMultiplication
	[OperatorKind.NonEmpty]				: AssignmentOperatorNonEmpty
	[OperatorKind.NonExistential]		: AssignmentOperatorNonExistential
	[OperatorKind.NonFinite]			: AssignmentOperatorNonFinite
	[OperatorKind.NonFiniteCoalescing]	: AssignmentOperatorNonFiniteCoalescing
	[OperatorKind.NullCoalescing]		: AssignmentOperatorNullCoalescing
	[OperatorKind.Power]				: AssignmentOperatorPower
	[OperatorKind.Remainder]			: AssignmentOperatorRemainder
	[OperatorKind.Return]				: AssignmentOperatorReturn
	[OperatorKind.Subtraction]			: AssignmentOperatorSubtraction
	[OperatorKind.VariantNo]			: AssignmentOperatorVariantNo
	[OperatorKind.VariantNoCoalescing]	: AssignmentOperatorVariantCoalescing
	[OperatorKind.VariantYes]			: AssignmentOperatorVariantYes
}

var $binaryOperators = {
	[OperatorKind.Addition]				: BinaryOperatorAddition
	[OperatorKind.BackwardPipeline]		: BinaryOperatorBackwardPipeline
	[OperatorKind.BitwiseAnd]			: PolyadicOperatorBitwiseAnd
	[OperatorKind.BitwiseLeftShift]		: PolyadicOperatorBitwiseLeftShift
	[OperatorKind.BitwiseOr]			: PolyadicOperatorBitwiseOr
	[OperatorKind.BitwiseRightShift]	: PolyadicOperatorBitwiseRightShift
	[OperatorKind.BitwiseXor]			: PolyadicOperatorBitwiseXor
	[OperatorKind.Division]				: BinaryOperatorDivision
	[OperatorKind.EmptyCoalescing]		: BinaryOperatorEmptyCoalescing
	[OperatorKind.EuclideanDivision]	: BinaryOperatorDivisionEuclidean
	[OperatorKind.ForwardPipeline]		: BinaryOperatorForwardPipeline
	[OperatorKind.IntegerDivision]		: BinaryOperatorDivisionInteger
	[OperatorKind.LogicalAnd]			: PolyadicOperatorLogicalAnd
	[OperatorKind.LogicalImply]			: PolyadicOperatorLogicalImply
	[OperatorKind.LogicalOr]			: PolyadicOperatorLogicalOr
	[OperatorKind.LogicalXor]			: PolyadicOperatorLogicalXor
	[OperatorKind.Match]				: BinaryOperatorMatch
	[OperatorKind.Mismatch]				: BinaryOperatorMismatch
	[OperatorKind.Modulus]				: BinaryOperatorModulus
	[OperatorKind.Multiplication]		: BinaryOperatorMultiplication
	[OperatorKind.NonFiniteCoalescing]	: BinaryOperatorNonFiniteCoalescing
	[OperatorKind.NullCoalescing]		: BinaryOperatorNullCoalescing
	[OperatorKind.Power]				: BinaryOperatorPower
	[OperatorKind.Remainder]			: BinaryOperatorRemainder
	[OperatorKind.Subtraction]			: BinaryOperatorSubtraction
	[OperatorKind.TypeAssertion]		: BinaryOperatorTypeAssertion
	[OperatorKind.TypeCasting]			: BinaryOperatorTypeCasting
	[OperatorKind.TypeEquality]			: BinaryOperatorTypeEquality
	[OperatorKind.TypeInequality]		: BinaryOperatorTypeInequality
	[OperatorKind.TypeSignalment]		: BinaryOperatorTypeSignalment
	[OperatorKind.VariantNoCoalescing]	: BinaryOperatorVariantCoalescing
}

var $expressions = {
	[AstKind.ArrayBinding]					: ArrayBinding
	[AstKind.ArrayComprehension]			: ArrayComprehension
	[AstKind.ArrayExpression]				: ArrayExpression
	[AstKind.ArrayRange]					: ArrayRange
	[AstKind.AwaitExpression]				: AwaitExpression
	[AstKind.CallExpression]				: Syntime.callExpression
	[AstKind.ComparisonExpression]			: ComparisonExpression
	[AstKind.CurryExpression]				: CurryExpression
	[AstKind.DisruptiveExpression]			: DisruptiveExpression
	[AstKind.FunctionExpression]			: AnonymousFunctionExpression
	[AstKind.Identifier]					: IdentifierLiteral
	[AstKind.IfExpression]					: IfExpression
	[AstKind.LambdaExpression]				: ArrowFunctionExpression
	[AstKind.Literal]						: StringLiteral
	[AstKind.MatchExpression]				: MatchExpression
	[AstKind.MemberExpression]				: MemberExpression
	[AstKind.NamedArgument]					: NamedArgument
	[AstKind.NumericExpression]				: NumberLiteral
	[AstKind.ObjectBinding]					: ObjectBinding
	[AstKind.ObjectComprehension]			: ObjectComprehension
	[AstKind.ObjectExpression]				: ObjectExpression
	[AstKind.OmittedExpression]				: OmittedExpression
	[AstKind.PlaceholderArgument]			: PlaceholderArgument
	[AstKind.PositionalArgument]			: PositionalArgument
	[AstKind.Reference]						: func(data, parent, scope) { # {{{
		if var expression ?= parent.getASTReference(data.name) {
			return ReferenceExpression.new(expression, data, parent, scope)
		}

		throw NotSupportedException.new(`Unexpected reference \(data.name)`, parent)
	} # }}}
	[AstKind.RegularExpression]				: RegularExpression
	[AstKind.RestrictiveExpression]			: RestrictiveExpression
	[AstKind.RollingExpression]				: RollingExpression
	[AstKind.SequenceExpression]			: SequenceExpression
	[AstKind.SyntimeCallExpression]			: Syntime.callSyntimeExpression
	[AstKind.TemplateExpression]			: TemplateExpression
	[AstKind.TopicReference]				: func(data, parent, scope) { # {{{
		return parent.getTopicReference(data)
	} # }}}
	[AstKind.ThisExpression]				: ThisExpression
	[AstKind.TryExpression]					: TryExpression
	[AstKind.TypedExpression]				: TypedExpression
}

var $statements = {
	[AstKind.BitmaskDeclaration]			: BitmaskDeclaration
	[AstKind.BlockStatement]				: BlockStatement
	[AstKind.BreakStatement]				: BreakStatement
	[AstKind.ClassDeclaration]				: ClassDeclaration
	[AstKind.ContinueStatement]				: ContinueStatement
	[AstKind.DiscloseDeclaration]			: DiscloseDeclaration
	[AstKind.DoUntilStatement]				: DoUntilStatement
	[AstKind.DoWhileStatement]				: DoWhileStatement
	[AstKind.EnumDeclaration]				: EnumDeclaration
	[AstKind.ExportDeclaration]				: ExportDeclaration
	[AstKind.ExternDeclaration]				: ExternDeclaration
	[AstKind.ExternOrImportDeclaration]		: ExternOrImportDeclaration
	[AstKind.ExternOrRequireDeclaration]	: ExternOrRequireDeclaration
	[AstKind.FallthroughStatement]			: FallthroughStatement
	[AstKind.ForStatement]					: ForStatement
	[AstKind.FunctionDeclaration]			: FunctionDeclaration
	[AstKind.IfStatement]					: IfStatement
	[AstKind.ImplementDeclaration]			: ImplementDeclaration
	[AstKind.ImportDeclaration]				: ImportDeclaration
	[AstKind.IncludeDeclaration]			: IncludeDeclaration
	[AstKind.IncludeAgainDeclaration]		: IncludeAgainDeclaration
	[AstKind.MatchStatement]				: MatchStatement
	[AstKind.NamespaceDeclaration]			: NamespaceDeclaration
	[AstKind.PassStatement]					: PassStatement
	[AstKind.RepeatStatement]				: RepeatStatement
	[AstKind.RequireDeclaration]			: RequireDeclaration
	[AstKind.RequireOrExternDeclaration]	: RequireOrExternDeclaration
	[AstKind.RequireOrImportDeclaration]	: RequireOrImportDeclaration
	[AstKind.ReturnStatement]				: ReturnStatement
	[AstKind.SetStatement]					: SetStatement
	[AstKind.StructDeclaration]				: StructDeclaration
	[AstKind.SyntimeFunctionDeclaration]	: Syntime.SyntimeFunctionDeclaration
	[AstKind.ThrowStatement]				: ThrowStatement
	[AstKind.TryStatement]					: TryStatement
	[AstKind.TupleDeclaration]				: TupleDeclaration
	[AstKind.TypeAliasDeclaration]			: TypeAliasDeclaration
	[AstKind.UnlessStatement]				: UnlessStatement
	[AstKind.UntilStatement]				: UntilStatement
	[AstKind.VariableStatement]				: VariableStatement
	[AstKind.WhileStatement]				: WhileStatement
	[AstKind.WithStatement]					: WithStatement
}

var $polyadicOperators = {
	[OperatorKind.Addition]				: PolyadicOperatorAddition
	[OperatorKind.BitwiseAnd]			: PolyadicOperatorBitwiseAnd
	[OperatorKind.BitwiseLeftShift]		: PolyadicOperatorBitwiseLeftShift
	[OperatorKind.BitwiseOr]			: PolyadicOperatorBitwiseOr
	[OperatorKind.BitwiseRightShift]	: PolyadicOperatorBitwiseRightShift
	[OperatorKind.BitwiseXor]			: PolyadicOperatorBitwiseXor
	[OperatorKind.Division]				: PolyadicOperatorDivision
	[OperatorKind.EmptyCoalescing]		: PolyadicOperatorEmptyCoalescing
	[OperatorKind.IntegerDivision]		: PolyadicOperatorDivisionInteger
	[OperatorKind.LogicalAnd]			: PolyadicOperatorLogicalAnd
	[OperatorKind.LogicalImply]			: PolyadicOperatorLogicalImply
	[OperatorKind.LogicalOr]			: PolyadicOperatorLogicalOr
	[OperatorKind.LogicalXor]			: PolyadicOperatorLogicalXor
	[OperatorKind.Modulus]				: PolyadicOperatorModulus
	[OperatorKind.Multiplication]		: PolyadicOperatorMultiplication
	[OperatorKind.NonFiniteCoalescing]	: PolyadicOperatorNonFiniteCoalescing
	[OperatorKind.NullCoalescing]		: PolyadicOperatorNullCoalescing
	[OperatorKind.Power]				: PolyadicOperatorPower
	[OperatorKind.Remainder]			: PolyadicOperatorRemainder
	[OperatorKind.Subtraction]			: PolyadicOperatorSubtraction
	[OperatorKind.VariantNoCoalescing]	: PolyadicOperatorVariantCoalescing
}

var $unaryOperators = {
	[OperatorKind.BitwiseNegation]		: UnaryOperatorBitwiseNegation
	[OperatorKind.Existential]			: UnaryOperatorExistential
	[OperatorKind.Finite]				: UnaryOperatorFinite
	[OperatorKind.Implicit]				: UnaryOperatorImplicit
	[OperatorKind.Length]				: UnaryOperatorLength
	[OperatorKind.LogicalNegation]		: UnaryOperatorLogicalNegation
	[OperatorKind.Negative]				: UnaryOperatorNegative
	[OperatorKind.NonEmpty]				: UnaryOperatorNonEmpty
	[OperatorKind.Spread]				: UnaryOperatorSpread
	[OperatorKind.TypeFitting]			: UnaryOperatorTypeFitting
	[OperatorKind.TypeNotNull]			: UnaryOperatorTypeNotNull
	[OperatorKind.VariantYes]			: UnaryOperatorVariant
}
