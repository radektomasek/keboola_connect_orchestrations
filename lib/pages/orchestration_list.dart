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
        if (model.allOrchestrations.length > 0 && !model.isLoading) {
          content = ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading:
                          model.allOrchestrations[index].status == 'success'
                              ? Icon(Icons.check)
                              : Icon(Icons.cancel),
                      title: Text(model.allOrchestrations[index].name),
                      subtitle: Text(
                          model.allOrchestrations[index].lastScheduledTime),
                      onTap: () {
                        Navigator.pushNamed<bool>(
                          context,
                          '/orchestration/${model.allOrchestrations[index].id}',
                        );
                      },
                      onLongPress: () {
                        print('I am going to open modal');
                      },
                    ),
                    Divider(),
                  ],
                );
              },
              itemCount: widget.model.allOrchestrations.length);
        } else if (widget.model.isLoading) {
          content = Center(child: CircularProgressIndicator());
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
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
          )
        ],
      ),
      body: _buildOrchestrationList(),
    );
  }
}
