import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import '../home_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/user_model.dart';
import 'dart:async';
import '../../utils/cache_interceptor.dart';
import 'package:dio/dio.dart';
import '../../model/question_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../question_disciplina_estatisticas_screen.dart';
import 'package:animated_card/animated_card.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:expandable/expandable.dart';


class TransgressoesScreen extends StatefulWidget {
  final edital_id;
  final category_name;
  final filter;

  TransgressoesScreen(this.edital_id, this.category_name, this.filter);

  @override
  _TransgressoesScreenState createState() => _TransgressoesScreenState();
}

class _TransgressoesScreenState extends State<TransgressoesScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  final TextStyle _questionStyle = TextStyle(fontWeight: FontWeight.w500);



  var _questionIndex = 0;
  var questionsResposta;
  bool _respondida = false;
  String resposta;
  var questionsResolvidaFromBD;
  var totalQstResolvidaByQst;
  var UserUid;

  var dio = Dio();
  QuestionResposta qstRes = QuestionResposta();
  QuestionHelper helper = QuestionHelper();
  List<Map> questions = List();

  ///BEGIN TIMER
  Stopwatch watch = new Stopwatch();
  Timer timer;

  bool _showTimer = true;

  String elapsedTime = '';

  bool _isLoading = false;
  List _questions;
  // Declare this variable
  String selectedRadio;

  var themeDefault;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    resetWatch();

    _getQuestions();
  }

  @override
  void dispose() {
    resetWatch();
    stopWatch();
    super.dispose();
  }

  // Changes the selected value on 'onChanged' click on each radio button
  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }

  var controller = ExpandableController(initialExpanded: false);


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          key: _key,
          body: _isLoading
              ? Center(
              child: AppSettings()
                  .buildProgressIndicator(isLoading: _isLoading))
              : ScopedModelDescendant<UserModel>(
            builder: (context, child, model) {
              UserUid = model.firebaseUser.uid;
              return Container(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Stack(
                    children: <Widget>[
                      ClipPath(
                        clipper: WaveClipperOne(),
                        child: Container(
                          decoration: new BoxDecoration(
                            gradient: LinearGradient(colors: AppSettings.colorsLinearGradient
                              ,
                              begin: Alignment.bottomRight,
                              end: Alignment.topLeft,
                            ),
                          ),
                          height: 100,
                        ),
                      ),
                      AnimatedCard(
                          direction: AnimatedCardDirection.left,
                          curve: Curves.elasticInOut,//Initial animation direction
                          initDelay: Duration(milliseconds: 0), //Delay to initial animation
                          duration: Duration(seconds: 1), //Initial animation duration
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: IconButton(
                                            icon:
                                            Icon(FontAwesomeIcons.reply, color: themeDefault ? Colors.white : Colors.black ,),
                                            onPressed: () {
                                              _onWillPop();
                                            }),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          widget.category_name,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: themeDefault ? Colors.white : Colors.black ,),
                                        ),
                                      ),
                                      Expanded(child: SizedBox()),
                                      Expanded(child: SizedBox()),
                                      IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.slidersH,
                                            //color: Colors.amberAccent,
                                            size: 15,
                                            color: themeDefault ? Colors.white : Colors.black ,
                                          ),
                                          onPressed: () {
                                            showDialog<String>(
                                              context: context,
                                              builder:
                                                  (BuildContext context) =>
                                                  SimpleDialog(
                                                    title:
                                                    Text('Filtrar Questões'),
                                                    children: <Widget>[
                                                      ListTile(
                                                          leading: Icon(
                                                            Icons.all_inclusive,
                                                            color: Colors.amber,
                                                          ),
                                                          trailing: Icon(Icons
                                                              .arrow_forward_ios),
                                                          title: Text('TODAS'),
                                                          onTap: () {
                                                            Navigator.of(context).push(
                                                                new MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        TransgressoesScreen(
                                                                            widget
                                                                                .edital_id,
                                                                            widget
                                                                                .category_name,
                                                                            0)));
                                                          }),
                                                      ListTile(
                                                          leading: Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                          ),
                                                          trailing: Icon(
                                                            Icons
                                                                .arrow_forward_ios,),
                                                          title: Text('ACERTOS'),
                                                          onTap: () {
                                                            Navigator.of(context).push(
                                                                new MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        TransgressoesScreen(
                                                                            widget
                                                                                .edital_id,
                                                                            widget
                                                                                .category_name,
                                                                            1)));
                                                          }),
                                                      ListTile(
                                                          leading: Icon(
                                                            Icons.error,
                                                            color: Colors.red,
                                                          ),
                                                          trailing: Icon(Icons
                                                              .arrow_forward_ios),
                                                          title: Text('ERROS'),
                                                          onTap: () {
                                                            Navigator.of(context).push(
                                                                new MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        TransgressoesScreen(
                                                                            widget
                                                                                .edital_id,
                                                                            widget
                                                                                .category_name,
                                                                            2)));
                                                          }),
                                                    ],
                                                  ),
                                            );
                                          }),
                                      IconButton(
                                          icon: Icon(
                                            Icons.equalizer,
                                            color: themeDefault ? Colors.white : Colors.black ,
                                            //color: Colors.green
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                new PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => QuestionDisciplinaEstatistica(
                                                      widget
                                                          .category_name),
                                                  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                                  new FadeTransition(opacity: animation, child: child),
                                                ));


                                          })
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                /**
                                 **
                                 * HEADER OF QUESTION
                                 *
                                 */
                                AppSettings().buildTile(
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                  'Questão ${_questionIndex + 1}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.w700,
                                                      fontSize: 20.0)),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                children: <Widget>[
                                                  questionsResolvidaFromBD ==
                                                      null
                                                      ? Container()
                                                      : questionsResolvidaFromBD
                                                      .acertou ==
                                                      "0"
                                                      ? Icon(
                                                    FontAwesomeIcons
                                                        .sadTear,
                                                    size: 10,
                                                    color:
                                                    Colors.red,
                                                  )
                                                      : Icon(
                                                      FontAwesomeIcons
                                                          .smile,
                                                      size: 10,
                                                      color: Colors
                                                          .green),
                                                  SizedBox(
                                                    width: 2,
                                                  ),
                                                  questionsResolvidaFromBD ==
                                                      null
                                                      ? Container()
                                                      : questionsResolvidaFromBD
                                                      .acertou ==
                                                      "0"
                                                      ? Text('Resolvi errada',
                                                      style: TextStyle(
                                                          fontSize:
                                                          10,
                                                          color: Colors
                                                              .red))
                                                      : Text('Resolvi Certa',
                                                      style: TextStyle(
                                                          fontSize:
                                                          10,
                                                          color: Colors
                                                              .green)),
                                                ],
                                              )
                                            ],
                                          ),
                                          _showTimer
                                              ? Material(

                                            child: Container(

                                                decoration: new BoxDecoration(
                                                  gradient: LinearGradient(colors: AppSettings.colorsLinearGradient
                                                    ,
                                                    begin: Alignment.bottomRight,
                                                    end: Alignment.topLeft,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      24.0),
                                                ),
                                                child: Center(
                                                    child: Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .end,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: <
                                                              Widget>[
                                                            Icon(
                                                              Icons.timer,
                                                              size: 16,
                                                              color: themeDefault ? Colors.white : Colors.black ,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            new Text(
                                                                elapsedTime,
                                                                style:
                                                                new TextStyle(
                                                                    fontSize:
                                                                    15.0,
                                                                    color: themeDefault ? Colors.white : Colors.black ,
                                                                )),
                                                          ],
                                                        )))
                                            ),)
                                              : Container()
                                        ]),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                /**
                                 **
                                 * ENUNCIADO OF QUESTION
                                 *Text(
                                    _questions[_questionIndex]['title'],
                                    softWrap: true,
                                    ),
                                 */
                                (_questions[_questionIndex]['thumbnail'] == " " ||
                                    _questions[_questionIndex]['thumbnail'] == ""
                                    || _questions[_questionIndex]['thumbnail'] == null
                                    || _questions[_questionIndex]['thumbnail'].length < 10) ?
                                Container()
                                    :
                                AppSettings().buildTile(Container(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ExpandablePanel(
                                      controller: controller,
                                      tapBodyToCollapse: true,

                                      header: Text('Texto da Questão'.toUpperCase(), ),
                                      collapsed: Container(),
                                      expanded: Html(
                                        useRichText: true,
                                        data: _questions[_questionIndex]['thumbnail'],
                                        //Optional parameters:

                                        linkStyle: const TextStyle(
                                          color: Colors.redAccent,
                                          decorationColor: Colors.redAccent,
                                          decoration: TextDecoration.underline,
                                        ),
                                        onLinkTap: (url) {
                                          print("Opening $url...");
                                        },
                                        onImageTap: (src) {
                                          print(src);
                                        },
                                        //Must have useRichText set to false for this to work
                                        customRender: (node, children) {
                                          if (node is dom.Element) {
                                            switch (node.localName) {
                                              case "custom_tag":
                                                return Column(children: children);
                                            }
                                          }
                                          return null;
                                        },
                                        customTextAlign: (dom.Node node) {
                                          if (node is dom.Element) {
                                            switch (node.localName) {
                                              case "p":
                                                return TextAlign.justify;
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                      tapHeaderToExpand: true,
                                      hasIcon: true,
                                    ),
                                  ),
                                ),
                                ),
                                SizedBox(height: 10.0),
                                /**
                                 **
                                 * TITLE OF QUESTION
                                 *Text(
                                    _questions[_questionIndex]['title'],
                                    softWrap: true,
                                    ),
                                 */
                                AppSettings().buildTile(Container(
                                  width: double.infinity,
                                  child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Html(
                                        useRichText: true,
                                        data: _questions[_questionIndex]['title'],
                                        //Optional parameters:

                                        linkStyle: const TextStyle(
                                          color: Colors.redAccent,
                                          decorationColor: Colors.redAccent,
                                          decoration: TextDecoration.underline,
                                        ),
                                        onLinkTap: (url) {
                                          print("Opening $url...");
                                        },
                                        onImageTap: (src) {
                                          print(src);
                                        },
                                        //Must have useRichText set to false for this to work
                                        customRender: (node, children) {
                                          if (node is dom.Element) {
                                            switch (node.localName) {
                                              case "custom_tag":
                                                return Column(children: children);
                                            }
                                          }
                                          return null;
                                        },
                                        customTextAlign: (dom.Node node) {
                                          if (node is dom.Element) {
                                            switch (node.localName) {
                                              case "p":
                                                return TextAlign.justify;
                                            }
                                          }
                                          return null;
                                        },

                                      )


                                  ),
                                )),
                                SizedBox(height: 10.0),
                                /**
                                 **
                                 * ITENS OF QUESTION
                                 *
                                 */
                                AppSettings().buildTile(
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        (_questions[_questionIndex]
                                        ['choice_a'] !=
                                            null &&
                                            _questions[_questionIndex]
                                            ['choice_a'] !=
                                                "")
                                            ? RadioListTile(
                                          dense: true,
                                          title: Text("a) ${
                                              _questions[_questionIndex]
                                              ['choice_a']}",
                                            softWrap: true,
                                            //style: _questionStyle,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          groupValue: selectedRadio,
                                          value:
                                          _questions[_questionIndex]
                                          ['choice_a'],
                                          onChanged: (value) {
                                            setState(() {
                                              questionsResposta = value;
                                              setSelectedRadio(value);
                                              print(questionsResposta);
                                            });
                                          },
                                        )
                                            : Container(),
                                        (_questions[_questionIndex]
                                        ['choice_b'] !=
                                            null &&
                                            _questions[_questionIndex]
                                            ['choice_b'] !=
                                                "")
                                            ? RadioListTile(
                                          title: Text("b) ${
                                              _questions[_questionIndex]
                                              ['choice_b']}",
                                            softWrap: true,
                                            //style: _questionStyle,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 14),),
                                          groupValue: selectedRadio,
                                          value:
                                          _questions[_questionIndex]
                                          ['choice_b'],
                                          onChanged: (value) {
                                            setState(() {
                                              questionsResposta = value;
                                              setSelectedRadio(value);
                                              print(questionsResposta);
                                            });
                                          },
                                        )
                                            : Container(),
                                        (_questions[_questionIndex]
                                        ['choice_c'] !=
                                            null &&
                                            _questions[_questionIndex]
                                            ['choice_c'] !=
                                                "")
                                            ? RadioListTile(
                                          title: Text("c) ${
                                              _questions[_questionIndex]
                                              ['choice_c']}",
                                            softWrap: true,
                                            //style: _questionStyle,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 14),),
                                          groupValue: selectedRadio,
                                          value:
                                          _questions[_questionIndex]
                                          ['choice_c'],
                                          onChanged: (value) {
                                            setState(() {
                                              questionsResposta = value;
                                              setSelectedRadio(value);
                                              print(questionsResposta);
                                            });
                                          },
                                        )
                                            : Container(),
                                        (_questions[_questionIndex]
                                        ['choice_d'] !=
                                            null &&
                                            _questions[_questionIndex]
                                            ['choice_d'] !=
                                                "")
                                            ? RadioListTile(
                                          title: Text("d) ${
                                              _questions[_questionIndex]
                                              ['choice_d']}",
                                            softWrap: true,
                                            //style: _questionStyle,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 14),),
                                          groupValue: selectedRadio,
                                          value:
                                          _questions[_questionIndex]
                                          ['choice_d'],
                                          onChanged: (value) {
                                            setState(() {
                                              questionsResposta = value;
                                              setSelectedRadio(value);
                                              print(questionsResposta);
                                            });
                                          },
                                        )
                                            : Container(),
                                        (_questions[_questionIndex]
                                        ['choice_e'] !=
                                            null &&
                                            _questions[_questionIndex]
                                            ['choice_e'] !=
                                                "")
                                            ? RadioListTile(
                                          title: Text("e) ${
                                              _questions[_questionIndex]
                                              ['choice_e']}",
                                            softWrap: true,
                                            //style: _questionStyle,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 14),),
                                          groupValue: selectedRadio,
                                          value:
                                          _questions[_questionIndex]
                                          ['choice_e'],
                                          onChanged: (value) {
                                            setState(() {
                                              questionsResposta = value;
                                              setSelectedRadio(value);
                                              print(questionsResposta);
                                            });
                                          },
                                        )
                                            : Container(),
                                      ],
                                    ),
                                  ),

                                ),
                                SizedBox(height: 10.0),
                                _respondida
                                    ? AppSettings().buildTile(
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: <Widget>[

                                          FadeInImage(
                                              placeholder: AssetImage("assets/images/placeholder.png"),
                                              image: AssetImage(resposta == "ACERTOU!" ? 'assets/images/moral_acertou_200.png' : 'assets/images/moral_errou_200.png')),
                                          SizedBox(height: 10,),
                                          Text(
                                            "Gabarito: ${_questions[_questionIndex]
                                            ['answer']}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              /*color:
                                                      resposta == "ACERTOU!"
                                                          ? Colors.green
                                                          : Colors.red
                                                          */
                                            ),
                                          ),
                                          //COMENTARIO DA QUESTAO
                                          _respondida &&
                                              (_questions[_questionIndex]
                                              ['explanation'] !=
                                                  null && _questions[_questionIndex]
                                              ['explanation'] !=
                                                  "")
                                              ? Column(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: <Widget>[
                                              Divider(),
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(4.0),
                                                child: Text(
                                                  'COMENTÁRIO DO PROFESSOR',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(8.0),
                                                child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(4.0),
                                                    child: Html(
                                                      useRichText: true,
                                                      data: _questions[_questionIndex]
                                                      [
                                                      'explanation']
                                                      ,
                                                      //Optional parameters:

                                                      linkStyle: const TextStyle(
                                                        color: Colors.redAccent,
                                                        decorationColor: Colors.redAccent,
                                                        decoration: TextDecoration.underline,
                                                      ),
                                                      onLinkTap: (url) {
                                                        print("Opening $url...");
                                                      },
                                                      onImageTap: (src) {
                                                        print(src);
                                                      },
                                                      //Must have useRichText set to false for this to work
                                                      customRender: (node, children) {
                                                        if (node is dom.Element) {
                                                          switch (node.localName) {
                                                            case "custom_tag":
                                                              return Column(children: children);
                                                          }
                                                        }
                                                        return null;
                                                      },
                                                      customTextAlign: (dom.Node node) {
                                                        if (node is dom.Element) {
                                                          switch (node.localName) {
                                                            case "p":
                                                              return TextAlign.justify;
                                                          }
                                                        }
                                                        return null;
                                                      },

                                                    )

                                                  /*
                                                        Text(
                                                          _questions[_questionIndex]
                                                          [
                                                          'explanation']
                                                              .toString(),
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                          textAlign:
                                                          TextAlign
                                                              .justify,
                                                        ), */
                                                ),
                                              )
                                            ],
                                          )
                                              : Container(),
                                        ],
                                      ),
                                    )
                                )
                                    : Container(),
                                SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 60,
                                      alignment: Alignment.bottomCenter,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5.0)),
                                          //color: Colors.grey,
                                          textColor: Colors.white,
                                          child: Icon(FontAwesomeIcons.arrowLeft),
                                          onPressed: () {
                                            _questionIndex > 0
                                                ? _answerQuestionBack()
                                                : Null;
                                          }),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5.0)),

                                          //textColor: Colors.white,
                                          child: Text('RESPONDER',
                                          ),
                                          onPressed: () async {
                                            stopWatch();
                                            if (_respondida) {
                                              _userJaRespondeu();
                                            } else {
                                              if (selectedRadio == null) {
                                                _notSelected();
                                              } else {
                                                setState(() {
                                                  _respondida = true;
                                                });
                                                if (questionsResposta ==
                                                    _questions[_questionIndex]
                                                    ['answer']) {
                                                  setState(() {
                                                    qstRes.userId = model
                                                        .firebaseUser.uid;
                                                    qstRes.questionId =
                                                        _questions[_questionIndex]
                                                        ['id']
                                                            .toString();
                                                    qstRes.nameCategory =
                                                        widget.category_name;
                                                    qstRes.acertou = "1";
                                                    qstRes.time = elapsedTime;
                                                    qstRes.dataResolvida = AppSettings().convertStringFromDate();
                                                    //qstRes.dataResolvida = DateTime.now().toIso8601String();
                                                    print(
                                                        "QUESTOES ACERTOU: ${qstRes.dataResolvida}");
                                                    helper
                                                        .saveResposta(qstRes);
                                                  });

                                                  resposta = "ACERTOU!";
                                                } else {
                                                  setState(() {
                                                    qstRes.userId = model
                                                        .firebaseUser.uid;
                                                    qstRes.questionId =
                                                        _questions[_questionIndex]
                                                        ['id']
                                                            .toString();
                                                    qstRes.nameCategory =
                                                        widget.category_name;
                                                    qstRes.acertou = "0";
                                                    qstRes.time = elapsedTime;
                                                    qstRes.dataResolvida = AppSettings().convertStringFromDate();
                                                    print(
                                                        "QUESTOES ERROU: $qstRes");
                                                    helper
                                                        .saveResposta(qstRes);
                                                  });

                                                  resposta = "ERROU!";
                                                }
                                              }
                                            }
                                          }),
                                    ),
                                    Container(
                                      width: 60,
                                      alignment: Alignment.bottomCenter,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5.0)),

                                          child: Icon(
                                            FontAwesomeIcons.arrowRight,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            _questionIndex ==
                                                _questions.length - 1
                                                ? null
                                                : _answerQuestionNext();
                                          }),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                (widget.filter == 1 || widget.filter == 2) ? Text(
                                  'Total  de ${_questions.length} questões',
                                  style: TextStyle(fontSize: 9),
                                ):Container(),
                              ],
                            ),
                          )
                      )
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Future<bool> _onWillPop() async {

    return showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text("Você tem que certeza que quer sair?"),
            title: Text("Aviso!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Sim"),
                onPressed: () {
                  stopWatch();
                  resetWatch();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => HomeScreen()));
                },
              ),
              FlatButton(
                child: Text("Não"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  /*void _getQuestions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await CallApi()
          .getData('category/${widget.category_id}/questions')
          .then((result) {
        setState(() {
          _questions = result;
          _questions.shuffle();

          _isLoading = false;
        });
      });
    } catch (e) {
      print(e);
    }
  } */

  _getQuestions() async {
    themeDefault = await AppSettings().getThemeDefault();
    setState(() {
      _isLoading = true;
    });

    try {
      dio.options.baseUrl = "${AppSettings.url}api/";
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      await dio
          .get("transgressoes/edital/${widget.edital_id}",
          options: Options(extra: {'refresh': true}))
          .then((result) async {

        if(result.data['success']){
          var ids;
          int filter;

          _questions = result.data['questoes'];
          print("TOTALLLL:${_questions.length}");
          if (widget.filter > 0) {
            if (widget.filter == 1) {
              filter = 1;
            } else if (widget.filter == 2) {
              filter = 0;
            } else {
              filter = 2;
            }
            await _getQstIds(widget.category_name, filter.toString()).then((res) {
              //PEGA OS IDS DA CONSULTA SQL
              // 0 PARA PEGAR AS QUE RESOLVEU ERRADA
              // 1 PEGA AS RESOLVIDAS CERTAS
              ids = res;

              List<Map> _q = List();
              //pega o id do sql
              ids.asMap().forEach((i, valorId) {
                //print('index=$i, ID=$valorId');

                _questions.asMap().forEach((indexFiltro, value) {
                  //print('index=$i, value=${value["id"]}');

                  if (value["id"].toString() == valorId.toString()) {
                    _q.add(value);
                  }
                });
              });

              setState(() {
                _questions = _q;
              });
            });
          }

          _questions.shuffle();
          _isLoading = false;
          startWatch();
        }else{
          AppSettings().showDialogSingleButtonWithRedirect(
              context: context,
              title: 'Aviso',
              message: result.data['message'],
              buttonLabel: 'Fechar');
          setState(() {
            _isLoading = true;
          });
        }

      });
    } catch (e) {
      print(e);
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message: 'Erro ao carregar, tente novamente!',
          buttonLabel: 'Fechar');
      setState(() {
        _isLoading = true;
      });
    }
  }


  void _removeList(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _notSelected() {
    _key.currentState.showSnackBar(SnackBar(
        content: Text('Selecione uma opção!'),
        backgroundColor: Theme.of(context).accentColor,
        duration: Duration(seconds: 2)));
  }

  void _userJaRespondeu() {
    _key.currentState.showSnackBar(SnackBar(
        content: Text('Questão respondida. Vá para a próxima ;-)'),
        duration: Duration(seconds: 3)));
  }

  //VERIFICA SE A QUESTAO FOI RESOLVIDA PELO USUARIO
  void _getQstRespondida(questionId, userId) async {
    await helper.getQuestion(questionId, userId).then((list) {
      setState(() {
        questionsResolvidaFromBD = list;
        print("questionsResolvidaFromBD: $questionsResolvidaFromBD");
      });
    });
  }

  //CONTA O TOTAL DE VEZES QUE O USUARIO RESOLVEU A QUESTAO
  void _getQstTotalResolvida(questionId, userId) async {
    await helper
        .getTotalQstResolvidasByQuestion(questionId, userId)
        .then((list) {
      setState(() {
        totalQstResolvidaByQst = list;
        print(totalQstResolvidaByQst);
      });
    });
  }

  //CONTA O TOTAL DE VEZES QUE O USUARIO RESOLVEU A QUESTAO
  Future _getQstIds(categoryName, tipo) async {
    return await helper.getAcertosQuestionsIds(categoryName, tipo);
  }

  ///BEGIN TIMER
  startWatch() {
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 100), updateTime);
  }

  stopWatch() {
    watch.stop();
    setTime();
  }

  resetWatch() {
    watch.reset();
    setTime();
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  transformMilliSeconds(int milliseconds) {
    //Thanks to Andrew
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  ///END TIMER

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  /// FIM TIMER

  void _answerQuestionNext() async {
    setState(() {
      _questionIndex = _questionIndex + 1;
      selectedRadio = null;
      _respondida = false;
      resposta = null;
      _getQstRespondida(_questions[_questionIndex]['id'], UserUid);
      _getQstTotalResolvida(_questions[_questionIndex]['id'], UserUid);
      resetWatch();
      startWatch();
    });
    print(_questionIndex);
    if (_questionIndex < _questions.length) {
      print('We have more questions!');
    } else {
      print('No more questions!');
    }

    if(controller.expanded == true){
      controller.toggle();
      print(controller.expanded);
    }
  }

  void _answerQuestionBack() {
    setState(() {
      _questionIndex = _questionIndex - 1;
      selectedRadio = null;
      _respondida = false;
      resposta = null;
      _getQstRespondida(_questions[_questionIndex]['id'], UserUid);
      _getQstTotalResolvida(_questions[_questionIndex]['id'], UserUid);
      resetWatch();
      startWatch();
      if(controller.expanded == true){
        controller.toggle();
        print(controller.expanded);
      }



    });
    print(_questionIndex);
    if (_questionIndex < _questions.length) {
      print('We have more questions!');
    } else {
      print('No more questions!');
    }
  }
}
