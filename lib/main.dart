import 'package:flutter/material.dart';
import 'dbmanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbTodoManager dbmanager = new DbTodoManager();

  final _titleController = TextEditingController();
  final _todoController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  Todo todo;
  List<Todo> todolist;
  int updateIndex;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'Title'),
                    controller: _titleController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Title Should Not Be empty',
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'Todos'),
                    controller: _todoController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Todo Should Not Be empty',
                  ),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.blueAccent,
                    child: Container(
                        width: width * 0.9,
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                        )),
                    onPressed: () {
                      _submitTodo(context);
                    },
                  ),
                  FutureBuilder(
                    future: dbmanager.getTodoList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        todolist = snapshot.data;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: todolist == null ? 0 : todolist.length,
                          itemBuilder: (BuildContext context, int index) {
                            Todo tdd = todolist[index];
                            return Card(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: width * 0.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Title: ${tdd.title}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          'Todo: ${tdd.todoData}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _titleController.text = tdd.title;
                                      _todoController.text = tdd.todoData;
                                      todo = tdd;
                                      updateIndex = index;
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      dbmanager.deletetodo(tdd.id);
                                      setState(() {
                                        todolist.removeAt(index);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return new CircularProgressIndicator();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTodo(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (todo == null) {
        Todo st = new Todo(
            title: _titleController.text, todoData: _todoController.text);
        dbmanager.insertTodo(st).then((id) => {
              _titleController.clear(),
              _todoController.clear(),
              print('Todo Added to Db $id')
            });
      } else {
        todo.title = _titleController.text;
        todo.todoData = _todoController.text;

        dbmanager.updateTodo(todo).then((id) => {
              setState(() {
                todolist[updateIndex].title = _titleController.text;
                todolist[updateIndex].todoData = _todoController.text;
              }),
              _titleController.clear(),
              _todoController.clear(),
              todo = null
            });
      }
    }
  }
}
