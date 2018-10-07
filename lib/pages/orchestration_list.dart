import 'package:flutter/material.dart';
import './ui_fragments/logout_list_tile.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

class OrchestrationList extends StatefulWidget {
  final MainModel model;

  OrchestrationList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _OrchestrationListState();
  }
}

class _OrchestrationListState extends State<OrchestrationList> {
  @override
  initState() {
    super.initState();
    widget.model.fetchOrchestrations();
  }

  bool isSuccess(status) => status.toString() == 'success';

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Menu'),
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Profile'),
            onTap: () {
              print('Profile tap');
            },
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }

  Widget _buildOrchestrationList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(child: Text('No orchestration found!'));
        if (model.highlightedOrchestrations.length > 0 && !model.isLoading) {
          content = ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(5.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: model.highlightedOrchestrations[index]
                                              .status ==
                                          'success'
                                      ? Color(0xFF5CB85C)
                                      : Color(0xFFD9534F),
                                  width: 25.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              trailing: model.highlightedOrchestrations[index]
                                          .status ==
                                      'success'
                                  ? Icon(Icons.check)
                                  : Icon(Icons.cancel),
                              title: Text(
                                  model.highlightedOrchestrations[index].name),
                              subtitle: isSuccess(model
                                      .highlightedOrchestrations[index].status)
                                  ? Text(
                                      'succeeded at ${model.highlightedOrchestrations[index].lastScheduledTime}')
                                  : Text(
                                      'failed at ${model.highlightedOrchestrations[index].lastScheduledTime}'),
                              onTap: () {
                                Navigator.pushNamed<bool>(
                                  context,
                                  '/orchestration/${model.highlightedOrchestrations[index].id}',
                                );
                              },
                              onLongPress: () {
                                return showModalBottomSheet<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        child: Padding(
                                          padding: EdgeInsets.all(32.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                leading:
                                                    Icon(Icons.description),
                                                title: Text('Go to detail'),
                                                onTap: () {
                                                  Navigator.pushNamed<bool>(
                                                    context,
                                                    '/orchestration/${model.highlightedOrchestrations[index].id}',
                                                  ).then((bool) {
                                                    Navigator.pop(context);
                                                  });
                                                },
                                              ),
                                              ListTile(
                                                leading: !model
                                                        .highlightedOrchestrations[
                                                            index]
                                                        .isFavorite
                                                    ? Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                      ),
                                                title: !model
                                                        .highlightedOrchestrations[
                                                            index]
                                                        .isFavorite
                                                    ? Text('Add to favorites')
                                                    : Text(
                                                        'Remove from favorites'),
                                                onTap: () {
                                                  model.toggleOrchestrationFavoriteStatus(
                                                      model
                                                          .highlightedOrchestrations[
                                                              index]
                                                          .id);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                leading:
                                                    Icon(Icons.expand_more),
                                                title: Text('Dismiss'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                );
              },
              itemCount: widget.model.highlightedOrchestrations.length);
        } else if (widget.model.isLoading) {
          content = Container(
            margin: EdgeInsets.all(12.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: widget.model.fetchOrchestrations,
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('Orchestration List'),
        centerTitle: true,
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      body: _buildOrchestrationList(),
    );
  }
}
