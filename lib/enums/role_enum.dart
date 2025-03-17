enum Role {
  superadministrador(1, 'superadministrador'),
  administrador(2, 'administrador'),
  cliente(3, 'cliente'),
  agente(4, 'agente'),
  espectador(5, 'espectador');

  final int id;
  final String name;

  const Role(this.id, this.name);
}
