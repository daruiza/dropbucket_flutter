enum Role {
  superadministrador("6845b197a766ccdceee6f3aa", 'superadministrador'),
  administrador("68672d63fe06d6226603c626", 'administrador'),
  cliente("68672e95fe06d6226603c627", 'cliente'),
  agente("68672f9efe06d6226603c628", 'agente'),
  espectador("68673105fe06d6226603c629", 'espectador');

  final String id;
  final String name;

  const Role(this.id, this.name);
}
