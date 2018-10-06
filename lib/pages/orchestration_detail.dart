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
  String _expandedElementId = '';

  @override
  initState() {
    super.initState();
    widget.model.fetchOrchestrationById(widget.orchestrationId);
  }

  bool isSuccess(status) => status.toString() == 'success';

  Widget _buildOrchestrationDetail() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        if (model.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (model.selectedOrchestration.length == 0) {
          return Container(
            margin: EdgeInsets.only(top: 20.0),
            child: Center(
                child: Text(
              'No detail found',
              style: TextStyle(fontSize: 25.0),
            )),
          );
        }

        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Center(
                        child: Text(
                      'Last execution result',
                      style: TextStyle(fontSize: 25.0),
                    )),
                  ),
                  Card(
                    margin: EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: isSuccess(
                                          model.selectedOrchestration[0].status)
                                      ? Color(0xFF5CB85C)
                                      : Color(0xFFD9534F),
                                  width: 25.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                '${model.selectedOrchestration[0].description.toString()} (${model.selectedOrchestration[0].id.toString()})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                '${isSuccess(model.selectedOrchestration[0].status) ? 'succeeded' : 'failed'} at ${model.selectedOrchestration[0].endTime}',
                                style: TextStyle(
                                    // color: Colors.black,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        !isSuccess(model.selectedOrchestration[0].status)
                            ? Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Text(model
                                    .selectedOrchestration[0].errorMessage),
                              )
                            : Container(
                                child: null,
                              ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Center(
                        child: Text(
                      'Older executions (up to 10)',
                      style: TextStyle(fontSize: 25.0),
                    )),
                  ),
                  Container(
                    margin: EdgeInsets.all(12.0),
                    child: ExpansionPanelList(
                      expansionCallback: (int panelIndex, bool isExpanded) {
                        String id = model.selectedOrchestration
                            .skip(1)
                            .take(10)
                            .toList()[panelIndex]
                            .id
                            .toString();

                        setState(() {
                          if (_expandedElementId != id) {
                            _expandedElementId = id;
                          } else {
                            _expandedElementId = '';
                          }
                        });
                      },
                      children:
                          model.selectedOrchestration.skip(1).take(10).map(
                        (orchestration) {
                          return ExpansionPanel(
                            headerBuilder: (BuildContext context,
                                    bool isExpanded) =>
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: isSuccess(orchestration.status)
                                            ? Color(0xFF5CB85C)
                                            : Color(0xFFD9534F),
                                        width: 25.0,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    child: ListTile(
                                      title: Text(
                                        '${orchestration.description.toString()} (${orchestration.id.toString()})',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${isSuccess(orchestration.status) ? 'succeeded' : 'failed'} at ${orchestration.endTime}',
                                      ),
                                    ),
                                  ),
                                ),
                            body: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(15.0, 1.0, 1.0, 15.0),
                              child: Text(orchestration.errorMessage),
                            ),
                            isExpanded: _expandedElementId ==
                                orchestration.id.toString(),
                          );
                        },
                      ).toList(),
                    ),
                  )
                ],
              );
      },
    );
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
