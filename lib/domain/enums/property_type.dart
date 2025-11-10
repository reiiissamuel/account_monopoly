enum PropertyType {
    reit(description: 'Fundo Imobiliário'),
    treasuries(description: 'Renda Física'),
    stocks(description: 'Ação');

    final String description;
    const PropertyType({required this.description});
    
}