enum LoanType{
  bankLoan(description: "Emprestimo Bancário"),
  mortgage(description: "Hipoteca");

  final String description;

  const LoanType({required this.description});
}