import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:priority_list_app/modals/note.dart';
import 'package:priority_list_app/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note? note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String _selectedPriority = 'Low';

  DatabaseHelper helper = DatabaseHelper();
  late String appBarTitle;
  late Note note;

  NoteDetailState(Note? note, this.appBarTitle) {
    this.note = note ?? Note('', '', 2); // Initialize with default values if note is null
  }

  @override
  void initState() {
    super.initState();
    titleController.text = note.title;
    descriptionController.text = note.description;
    _selectedPriority = getPriorityAsString(note.priority);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleSmall!;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15.0),
          child: ListView(
            children: <Widget>[
              // Priority dropdown
              ListTile(
                title: DropdownButton<String>(
                  items: <String>['High', 'Low'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  style: textStyle,
                  value: _selectedPriority,
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      _selectedPriority = valueSelectedByUser!;
                      updatePriorityAsInt(_selectedPriority);
                    });
                  },
                ),
              ),

              // Title TextField
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // Description TextField
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // Save and Delete Buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                      child: Text('Save', textScaleFactor: 1.5),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                      child: Text('Delete', textScaleFactor: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String priority) {
    switch (priority) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) {
      // Update operation
      result = await helper.updateNote(note);
    } else {
      // Insert operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem saving note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (note.id == null) {
      // Case 1: When the user is trying to delete the new note, which is not yet saved
      _showAlertDialog('Status', 'No note was deleted');
      return;
    }

    // Case 2: When the user is trying to delete the existing note from the database
    int result = await helper.deleteNote(note.id!);
    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Error occurred while deleting note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = 'High';
        break;
      case 2:
        priority = 'Low';
        break;
      default:
        priority = 'Low';
    }
    return priority;
  }
}
