abstract class AbstractEntity {
  int? id;
  
  AbstractEntity(this.id);

  Map<String, dynamic> toMap();
}