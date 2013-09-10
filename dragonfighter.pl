/**
 * Dragon Fighter v1.0
 * Zhishen Wen
 * Sept 09, 2013
 */
:- dynamic at/2, i_am_at/1, commodity_is_at/2, alive/1, money/1.
:- retractall(at(_, _)), retractall(i_am_at(_)),
   retractall(commodity_is_at(_, _)), retractall(alive(_)),
   retractall(money(_)).

/*************************************
                Facts
**************************************/

/* My initial information. */
i_am_at(home).
money(100).

/* The facts describes the map. */
path(dragon, s, mountain).
path(mountain, w, river) :- at(ark, in_hand).
path(mountain, w, river) :-
        write('Oh, there''s no way to get through this fierce river without'), nl,
        write('any tools. Could you find something like a boat, ship, or even'), nl,
        write('an Ark?'), nl, fail.
path(mountain, s, deadsea).
path(mountain, e, firewoods).
path(mountain, n, dragon).
path(firewoods, w, mountain).
path(river, w, forest).
path(river, s, whirlpool).
path(river, e, mountain).
path(whirlpool, n, river).
path(forest, s, home).
path(forest, w, badlands).
path(forest, e, river) :- at(ark, in_hand).
path(forest, e, river) :-
        write('Oh, there''s no way to get through this fierce river without'), nl,
        write('any tools. Could you find something like a boat, ship, or even'), nl,
        write('an Ark?'), nl, fail.
path(badlands, n, cabinet) :- at(key, in_hand).
path(badlands, n, cabinet) :-
        write('Oops, the cabinet appears to be locked!'), nl, fail.
path(badlands, e, forest).
path(cabinet, s, badlands).
path(home, s, market).
path(home, w, boneyard_entrance).
path(home, n, forest).
path(boneyard_entrance, e, home).
path(boneyard_entrance, s, boneyard).
path(boneyard, n, boneyard_entrance).
path(market, n, home).
path(market, e, desert).
path(desert, w, market).

/* The facts describes where all the items are located. */
commodity_is_at(potion, market).
commodity_is_at(ark, market).
at(wand, badlands).
at(gem, cabinet).
at(key, desert).
at(excalibur, whirlpool).

/* The fact indicates the Devil Dark Dragon is alive. */
alive(dragon).

/*************************************
                Rules
**************************************/

/* The rules describe how to buy an item. */
buy(X) :-
        i_am_at(market),
        commodity_is_at(X, market),
        money(M), M >= 5000,
        retract(commodity_is_at(X, market)),
        assert(at(X, in_hand)),
        retract(money(M)),
        N is M - 5000,
        assert(money(N)),
        write('OK. Money remained: '), 
        write(N), nl, !.
buy(X) :-
        i_am_at(market),
        commodity_is_at(X, market),
        write('The price of '), write(X), 
        write(' is 5000 Belis, '),
        money(M), write('But you only got '), 
        write(M), write(' Belis!'), nl, !.
buy(_) :-
        i_am_at(market),
        write('This item is not available in the market!'), nl, !.
buy(_) :-
        write('You''re not at the market!'),
        nl.

/* The rules describe how to sell an item. */
sell(X) :-
        i_am_at(market),
        at(X, in_hand),
        (at(gem, in_hand) ; at(ruby, in_hand)),
        retract(at(X, in_hand)),
        retract(money(M)),
        N is M + 5000,
        assert(money(N)),
        write('OK. Money remained: '), 
        write(N), nl, !.
sell(X) :-
        i_am_at(market),
        at(X, in_hand),
        write('The market doesn''t accept this kind of item!'), nl, !.
sell(_) :-
        i_am_at(market),
        write('You don''t have it!'), nl, !.
sell(_) :-
        write('You''re not at the market!'),
        nl.

/* The rules describe how to pick up an item. */
take(X) :-
        at(X, in_hand),
        write('You''re already holding it!'),
        nl, !.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(at(X, in_hand)),
        write('OK.'),
        nl, !.

take(_) :-
        write('I don''t find it here!'),
        nl.

/* The rules describe how to drop an object. */
drop(X) :-
        at(X, in_hand),
        i_am_at(Place),
        retract(at(X, in_hand)),
        assert(at(X, Place)),
        write('OK.'),
        nl, !.

drop(_) :-
        write('You aren''t holding it!'),
        nl.

/* The rules describe how to move */
go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        look, !.

go(_) :-
        write('You can''t go that way!').

/* The rule describes how to look about you. */
look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.

/* The rules set up a loop to mention all the objects
   in your vicinity. */
notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).

/* The rules describe how to handle killing */
fight :-
        i_am_at(boneyard),
        write('Ah, your weak power can never protect you. You have been'), nl,
        write('eaten by the giant Enkidu.'), nl,
        !, die.
fight :-
        i_am_at(firewoods),
        write('So bad! The deadly Decarabia with the enormous magic power'), nl,
        write('makes your body disappear in this fire hell forever.'), nl,
        !, die.

fight :-
        i_am_at(dragon),
        at(excalibur, in_hand),
        retract(alive(dragon)),
        write('********************************************************'), nl,
        write('*****                CONGRATULATIONS!             ******'), nl,
        write('********************************************************'), nl, nl,
        write('The Devil Dark Dragon''s giant fangs are never as sharp as'), nl,
        write('your blade! It is killed - and you protect your honored'), nl,
        write('country and people. You guard the glorious pride of knights!'), nl,
        finish, !.

fight :-
        i_am_at(dragon),
        write('Run away! The Devil Dark Dragon''s giant fangs are too sharp!'), nl,
        write('You cannot win this battle without a truly powerful weapon.'), nl,
        write('You really need a sacred sword to give you this power.'), nl.

fight :-
        write('I see nothing inimical here.'), nl.

/* The rules display all the items you're now holding. */
inventory :-
        at(X, in_hand),
        write(X), nl, fail.
inventory :-
        write('---END OF LIST---').

/* The rule defines how to die. */
die :- !, finish.

/* The rule defines how to exit Prolog elegantly. */
finish :-
        nl,
        write('The game is over. Please enter the ''halt.'' command.'),
        nl, !.

/* The rule writes out game introduction. */
introduction :-
        write('********************************************************'), nl,
        write('*****                DRAGON FIGHTER                *****'), nl,
        write('********************************************************'), nl, nl,
        write('You are a brave knight living in the kingdom of Holy Modo.'), nl,
        write('Your country has long been threatened by the Devil Dark'), nl,
        write('Dragon lurking in the land of unknown, where nobody has ever'), nl,
        write('explored or even known its existence. To guard the fame'), nl,
        write('and rightness of the sacred knight, you need to find out this'), nl,
        write('place - and kill the dragon! Good luck!'), nl, nl.

/* The rule writes out game instructions. */
help :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.                   :to start the game.'), nl,
        write('n.  s.  e.  w.           :to go in that direction.'), nl,
        write('buy(item).               :to buy an item at the market.'), nl,
        write('sell(item).              :to sell an item at the market.'), nl,
        write('take(item).              :to pick up an item.'), nl,
        write('drop(item).              :to put down an item.'), nl,
        write('fight.                   :to attack an enemy.'), nl,
        write('look.                    :to look around you again.'), nl,
        write('help.                    :to see this message again.'), nl,
        write('halt.                    :to end the game and quit.'), nl,
        nl.

/* The rule prints out instructions and tells where you are. 
   This is also the entry point of the program. */
start :-
        introduction,
        help,
        look.

/* The rules defines shortcuts. */
e :- go(e).
s :- go(s).
w :- go(w).
n :- go(n).
i :- write('You''re currently holding:'), nl, inventory.

/*******************************
           Descriptions
********************************/

/* The rules describe different locations (under various circumstances) in
   the game. */
describe(home) :-
        write('You are now at your home. To the north is a forest; to the south'), nl,
        write('is a busy market; to the west, however, is a path towards the'), nl,
        write('entrance of Bone Yard - be extremely careful about it!'), nl.

describe(market) :-
        write('Welcome to the market! Here you can buy or sell things you''d'), nl,
        write('like. This market sells Magical Potions and even a big Ark! Make'), nl,
        write('sure you have enough money. The currency we use in this world is'), nl,
        write('Beli. Oh, by the way, there is a desert to the east of this market.'), nl, nl,
        write('Now you are having '), money(X), write(X), write(' Belis.'), nl.

describe(desert) :-
        write('You are now in a scorching desert, nothing but endless sea of sands.'), nl,
        at(key, desert),
        write('You are thinking about getting out of this place as soon as'), nl,
        write('possible... but wait, it seems like something is lying on the'), nl,
        write('ground. What is that?'), nl.
describe(desert) :-
        write('You are now again in a scorching desert, nothing but endless sea'), nl,
        write('of sands. What else do you want to do here?'), nl.

describe(boneyard_entrance) :-
        at(ruby, in_hand),
        write('The entrance of Bone Yard. Now you already get used to the'), nl,
        write('smell of deadth and unwillingness. To the south is the core area of'), nl,
        write('it, a titan Enkidu is said to be living there. Of course, to the'), nl,
        write('east is the only way back to your sweet home.'), nl, !.

describe(boneyard_entrance) :-
        at(potion, in_hand),
        at(wand, in_hand),
        write('You notice something unusual is concealed in the mystrey of dark.'), nl,
        write('Suddenly you realize you have your Magic Wand and can make this'), nl,
        write('discovery but you just lack sort of magic power to drive it.'), nl,
        write('So you drink the Potion. You''are now feeling unbelievably magical.'), nl,
        write('You spell and the Wand now reveals the sacred Sant Pete Ruby!'), nl,
        write('Now you got it.'), nl, nl,
        assert(at(ruby, in_hand)), !.

describe(boneyard_entrance) :-
        write('This is the entrance of Bone Yard. Everywhere is filled with the'), nl,
        write('smell of deadth and unwillingness. To the south is the core area of'), nl,
        write('it, a titan Enkidu is said to be living there. Of course, to the'), nl,
        write('east is the only way back to your sweet home.'), nl.

describe(boneyard) :-
        write('You are very brave and go deep inside the heart of Bone Yard.'), nl,
        write('Suddenly, you can hardly believe your eyes as now you see a giant'), nl,
        write('Enkidu sitting right in front of you, about to attak on you!'), nl,
        write('The only way to escape is the entrance to the north.'), nl,
        write('No time to consider long, you have to make a decision.'), nl, nl,
        write('Run away... or fight?'), nl.

describe(forest) :-
        write('Now you''re in the Midori Forest, a very quiet and vivid place.'), nl,
        write('To the west are badlands, where things might become uncertain'), nl,
        write('but there used to be a lot of wizards doing magic training at'), nl,
        write('badlands because of its unique magic source. To the east is a long'), nl,
        write('river. To the south is the way back to your familiar home.'), nl.

describe(badlands) :-
        write('You are now at the badlands. Nothing can ever live in this barren'), nl,
        write('land yet it''s strangely an optimal place for magic refillment.'), nl,
        write('You notice a Brobdingnagian cabinet to the west end of the land.'), nl,
        write('To leave here you should go east, back to the Midori Forest.'), nl.

describe(cabinet) :-
        at(gem, cabinet),
        write('You open the cabinet using the mysterious key. The only thing'), nl,
        write('you can see here is a large Alexandrites Gem. You are totally'), nl,
        write('obsessed by it shining color and perfect beauty.'), nl,
        write('To the east is the road back to badlands'), nl, !.

describe(cabinet) :-
        write('You open the cabinet using the mysterious key. The cabinet'), nl,
        write('appears to be empty now.'), nl,
        write('To the east is the road back to badlands'), nl.

describe(river) :-
        write('You''are now on the river, using your Ark. To the south is a gigantic'), nl,
        write('whirlpool, who knows what''s inside it. To the east is the bank'), nl,
        write('connecting to another unknown land.'), nl.

describe(whirlpool) :-
        write('You are struggling inside the whirlpool and it seems you can'), nl,
        write('not easily escape from it. You start to realize this is more'), nl,
        write('than a simple trap, a kind of magic is in fact protecting here.'), nl,
        write('Wait, something you desired for is at the center of the whirlpool, '), nl,
        write('Coming close to it, you know this is a legendary sword of King'), nl,
        write('Arthur - the Sacred Excalibur.'), nl,
        write('To leave, head north.'), nl.

describe(mountain) :-
        write('Now you are on the land of unknown, an undiscovered mountainous'), nl,
        write('world full of darkness and fears. To the south is the Dead Sea; to'), nl,
        write('the east is the Fire Woods; to the north, however, you can''t feel'), nl,
        write('any sense of livingness - your intuition tells you that''s an'), nl,
        write('extremely dangerous place.'), nl.

describe(deadsea) :-
        write('You made your way to this Dead Sea and it''s too late - there is'), nl,
        write('in fact no coming back. You are sinking under the sea, which'), nl,
        write('are made from the dead spirits of the scaring monsters. Your'), nl,
        write('magic power is lost here, you cannot survive.'), nl,
        die.

describe(firewoods) :-
        write('You are now in the forest of fire. Everything here is scorching'), nl,
        write('and dead - except for a giant Decarabia, staring at you and'), nl,
        write('roaring. You realize the true master of the Fire Woods is nothing'), nl,
        write('but this daunting monster. The only way to escape is to the west.'), nl,
        write('No time to consider long, you have to make a decision.'), nl, nl,
        write('Run away... or fight?'), nl.

describe(dragon) :-
        write('Finally, you come to the den of the Devil Dark Dragon, the'), nl,
        write('treacherous monster that prowl in the darkest corners of the'), nl,
        write('unknown world. You are a knight, you''re responsible for protecting'), nl,
        write('people in your country. You''re supposed to save the world!'), nl,
        write('You''are repeatedly asking yourself: CAN I DO THAT?'), nl,
        write('No time to consider long, you have to make a decision.'), nl, nl,
        write('Run away... or fight?'), nl.
