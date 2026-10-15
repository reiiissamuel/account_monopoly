enum LoanType{
  bankLoan(name: "Emprestimo Bancário", description: "Bonus como garantia"),
  mortgage(name: "Hipoteca", description: "Ativos como garantia");

  final String description;
  final String name;

  const LoanType({required this.name, required this.description});
}