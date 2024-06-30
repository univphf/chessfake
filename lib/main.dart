import 'dart:io';

import "engine.dart";

var commands = <String, List>{"uci": ["id name Fake Chess", "id author Hervé TONDEUR", "uciok"], "isready": ["readyok"],};
bool ucinewgame=true;
bool showboard=true;
String version="1.0";

void run() {
  BotHeader();

  //intitié le moteur
  Engine bot = new Engine();
  
  while (true) {
    var cmdBot;
    //prompt
    stdout.write("dartfish\$> ");
    cmdBot = stdin.readLineSync();

    //verifier si contient uci ou isready
    if (commands.containsKey(cmdBot)) {
      showboard = false;
      for (String out in commands[cmdBot]!) {
        print(out);
      }
    }

    //si cmd est go => calculer le mouvement pour la couleur en cours
    if (cmdBot.startsWith("go")) {
      showboard = true;
      print("bestmove " + bot.play());
    }

    //commencer un nouveau jeu.
    if (cmdBot.startsWith("ucinewgame")) {
      showboard = false;
      ucinewgame = true;
    }

    //si cmd est position
    //  position [fen <fenstring> | startpos ]  moves <move1> .... <movei>
    // set up the position described in fenstring on the internal board and play the moves on the internal chess board.
    // if the game was played  from the start position the string "startpos" will be sent
    // Note: no "new" command is needed. However, if this position is from a different game than
    // the last position sent to the engine, the GUI should have sent a "ucinewgame" inbetween.

    if (cmdBot.startsWith("position")) {
      //si prosition moves .
      if (cmdBot.contains('moves')) {
        showboard = true;
        const mvt = "moves";
        int startIndex = cmdBot.indexOf(mvt) + mvt.length + 1;
        List moves = cmdBot.substring(startIndex).split(" ");
        for (String move in moves) {
          bot.moveLAN(move);
        }
      }

      //si position fen .
      if (cmdBot.contains('fen ')) {
        showboard = true;
        String fenstr = cmdBot.substring(
            "position".length + 1 + "fen".length + 1);
        bot = Engine.fromFEN(fenstr);
      }

      //si startpos => nouveau jeu
      if (cmdBot.contains('startpos') & ucinewgame == true) {
        List info = cmdBot.split(" ");
        if (info[1] == 'startpos') {
          showboard = true;
          bot = Engine(); //nouveau moteur avec position de départ.
          ucinewgame = false;
        }
      }
    }

    //recuperer ligne fen
    if(cmdBot.contains('get fen')){
      showboard=false;
      print(bot.generate_fen());
    }


    //mode autoplaying
    if (cmdBot.contains('autoplay')) {
      showboard = false;
      while (!bot.game_over) {
        print('position: ' + bot.fen);
        print(bot.ascii);
        var moves = bot.moves();
        moves.shuffle();
        var move = moves[0];
        bot.move(move);
        print('move: ' + move);
      }
    }

    //afficher l'aide uci
    if (cmdBot.contains('help')) {
      showboard = false;
      print("commandes uci");
      print("=================");
      print("""uci : Demander au moteur d'utiliser l'uci (interface universelle d'échecs,
                ceci sera envoyé une fois comme première commande après le démarrage du programme
                pour dire au moteur de passer en mode uci.""");
      print("""isready : Ceci est utilisé pour synchroniser le moteur avec l'interface graphique. Lorsque l'interface graphique a envoyé une commande ou
                  plusieurs commandes qui peuvent prendre un certain temps,
                  cette commande peut être utilisée pour attendre que le moteur soit à nouveau prêt ou
                  pour cingler le moteur pour savoir s'il est toujours en vie.""");
      print("""ucinewgame : Ceci est envoyé au moteur lorsque la prochaine recherche (démarrée par "position" et "go") aura lieu à partir d'
                  un jeu différent. Cela peut être un nouveau jeu auquel le moteur devrait jouer ou un nouveau jeu qu'il devrait analyser mais
                  également la position suivante d'une suite de tests avec des positions uniquement.""");
      print("""position [fen <fenstring> | startpos ] moves <move1> .... <movei> :
                mettre en place la position décrite dans fenstring sur la l'échiquier interne et
                jouer les coups sur l'échiquier interne.
                si le jeu a été joué depuis la position de départ, la chaîne "startpos" sera envoyée
                
                exemples :
                position startpos
                position moves g2g3
                position moves g2g3 c7c6
                position fen rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2""");
      print("quit : Quitter le moteur dartfish...");
      print(""); //ligne vide
      print("commandes non uci");
      print("=================");
      print("""get fen : Récuperer une chaine au format den de la postion de l'échiquer.""");
      print(
          "autoplay : demander au moteur de résoudre le jeux automatiquement jusqu'a la fin du jeu.");
      print("help : cette aide.");
      print("help fen : aide sur le format fen et la compréhension de sa syntaxe.");
    }

    //afficher l'aide sur le format FEN
    if (cmdBot.contains('help fen')) {
      showboard = false;
    print("""<FEN> ::=  <Piece Placement>
       ' ' <Side to move>
       ' ' <Castling ability>
       ' ' <En passant target square>
       ' ' <Halfmove clock>
       ' ' <Fullmove counter>

<Piece Placement> ::= <rank8>'/'<rank7>'/'<rank6>'/'<rank5>'/'<rank4>'/'<rank3>'/'<rank2>'/'<rank1>
<ranki>       ::= [<digit17>]<piece> {[<digit17>]<piece>} [<digit17>] | '8'
<piece>       ::= <white Piece> | <black Piece>
<digit17>     ::= '1' | '2' | '3' | '4' | '5' | '6' | '7'
<white Piece> ::= 'P' | 'N' | 'B' | 'R' | 'Q' | 'K'
<black Piece> ::= 'p' | 'n' | 'b' | 'r' | 'q' | 'k'

<Side to move> ::= {'w' | 'b'}

<Castling ability> ::= '-' | ['K'] ['Q'] ['k'] ['q'] (1..4)

<En passant target square> ::= '-' | <epsquare>
<epsquare>   ::= <fileLetter> <eprank>
<fileLetter> ::= 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'
<eprank>     ::= '3' | '6'

<Halfmove Clock> ::= <digit> {<digit>}
<digit> ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'

<Fullmove counter> ::= <digit19> {<digit>}
<digit19> ::= '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
<digit>   ::= '0' | <digit19>

examples :
rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1
rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2
rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2""");
  }

    //quitter l'application
    if (cmdBot.contains('quit'))
      {
        //bye bye
        print ("bye bye!");
        exit(0);
      }

    //afficher l'échiquier si autorisé.
    if (showboard) {print(bot.ascii);}
  } //fin while
} //fin run

/*****************
 * dessin de l'entête
 *****************/
void BotHeader(){
  print ("Chess Fake Engine version $version");
  print ("TODEUR Hervé");
}

void main() {
  run();
}
