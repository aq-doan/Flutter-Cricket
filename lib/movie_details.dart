import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'movie.dart';

class MovieDetails extends StatefulWidget {
  final String? id;

  const MovieDetails({Key? key, this.id}) : super(key: key);

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final yearController = TextEditingController();
  final durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //var movies = Provider.of<MovieModel>(context, listen: false).items;
    //Movie? movie = widget.id != -1 ? movies[widget.id] : null;
    var movie = Provider.of<MovieModel>(context, listen: false).get(widget.id);
    var adding = movie == null;
    if (!adding) {
      titleController.text = movie.title;
      yearController.text = movie.year.toString();
      durationController.text = movie.duration.toString();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(adding ? "Add Movie" : "Edit Movie"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  if (adding == false)
                    Text(
                        "Movie Index ${widget.id}"), //check out this dart syntax, lets us do an if as part of an argument list
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Title"),
                            controller: titleController,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Year"),
                            controller: yearController,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Duration"),
                            controller: durationController,
                          ),
                          ElevatedButton.icon(
                              onPressed: () async {
                                //this function is asynchronous now
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  if (adding) {
                                    movie =
                                        Movie(title: "", duration: 0, year: 0);
                                  }

                                  //update the movie object
                                  movie!.title = titleController.text;
                                  movie!.year = int.parse(yearController
                                      .text); //good code would validate these
                                  movie!.duration = double.parse(
                                      durationController
                                          .text); //good code would validate these

                                  //TODO: update the model
                                  if (adding) {
                                    await Provider.of<MovieModel>(context,
                                            listen: false)
                                        .add(movie!);
                                  } else {
                                    await Provider.of<MovieModel>(context,
                                            listen: false)
                                        .updateItem(widget.id!, movie!);
                                  }

                                  //return to previous screen
                                  if (context.mounted) Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text("Save Values"))
                        ],
                      ),
                    ),
                  )
                ])));
  }
}