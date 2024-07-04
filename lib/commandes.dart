import "engine.dart";

bool uciNewGame = true;
String version = "1.0";
late Engine chessBot;

String uci() {
  BotHeader();
  //intitié le moteur
  chessBot = Engine();
  return """id name Fake Chess, id author Hervé TONDEUR, uciok""";
}

String isready() {
  return "readyok";
}

String go() {
  //si cmd est go => calculer le mouvement pour la couleur en cours
  return chessBot.play();
}

//commencer un nouveau jeu.
void ucinewgame() {
  uciNewGame = true;
}

//si cmd est position
//  position [fen <fenstring> | startpos ]  moves <move1> .... <movei>
// set up the position described in fenstring on the internal board and play the moves on the internal chess board.
// if the game was played  from the start position the string "startpos" will be sent
// Note: no "new" command is needed. However, if this position is from a different game than
// the last position sent to the engine, the GUI should have sent a "ucinewgame" inbetween.

void position_moves(String move) {
  chessBot.moveLAN(move);
}

void position_fen(String fenstr) {
  chessBot = Engine.fromFEN(fenstr);
}

bool position_startpos() {
  if (uciNewGame == true) {
    chessBot = Engine(); //nouveau moteur avec position de départ.
    uciNewGame = false;
    return true;
  }
  return false;
}

String get_fen() {
  return chessBot.generate_fen();
}

//mode autoplaying
void autoplay() {
  while (!chessBot.game_over) {
    print('position: ' + chessBot.fen);
    print(chessBot.ascii);
    var moves = chessBot.moves();
    moves.shuffle();
    var move = moves[0];
    chessBot.move(move);
    print('move: ' + move);
  }
}

void BotHeader() {
  print("Chess Fake Engine version $version");
  print("TONDEUR Hervé");
}
