class Note {
  int? id;
  String title;
  String description;
  String date;
  int priority;

  Note(this.title, this.date, this.priority, {this.description = ""});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
      'date': date,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'],
        priority = map['priority'],
        date = map['date'];

  @override
  String toString() {
    return 'Note{id: $id, title: $title, description: $description, date: $date, priority: $priority}';
  }
}
