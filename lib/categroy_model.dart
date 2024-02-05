class ItemGroup {
  final String itmsGrpCod;
  final String itmsGrpNam;


  ItemGroup({
    required this.itmsGrpCod,
    required this.itmsGrpNam,

  });

  factory ItemGroup.fromJson(Map<String, dynamic> json) {
    return ItemGroup(
      itmsGrpCod: json['itmsGrpCod'],
      itmsGrpNam: json['itmsGrpNam'],

    );
  }
}