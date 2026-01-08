enum PropertyType {
    reit(description: 'Fundo Imobiliário'),
    stocks(description: 'Ação');

    final String description;
    const PropertyType({required this.description});
    
}