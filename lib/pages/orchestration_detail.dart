import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

class OrchestrationDetail extends StatefulWidget {
  final MainModel model;
  final int orchestrationId;

  OrchestrationDetail(this.model, this.orchestrationId);

  @override
  State<StatefulWidget> createState() {
    return _OrchestrationDetailState();
  }
}

class _OrchestrationDetailState extends State<OrchestrationDetail> {
  @override
  initState() {
    super.initState();
    widget.model.fetchOrchestrationById(widget.orchestrationId);
  }

  Widget _buildOrchestrationDetail() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: Text('ID: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(model.selectedOrchestration.id.toString()),
                ),
                Divider(),
                ListTile(
                  leading: Text('NAME: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(
                    model.selectedOrchestration.name.toString(),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Text('STATUS: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(
                    model.selectedOrchestration.status.toString(),
                  ),
                ),
                Divider(),
              ],
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Orchestration detail'),
        ),
        body: _buildOrchestrationDetail());
  }
}
