:- dynamic(clouse_term_body/2).

clouse_term_body(Function,Term_Body) :-
	nonvar(Function),
	clause(Function,Term_Body); !, fail.	

% существует ли файл с именем, если существует, возвращает false  переходит к следующему предикату
% получаем размер файла в Size, Size == 0 то false иначе true
control_result(PathName) :- \+ file_exists(PathName), !, fail.
control_result(PathName) :-
	file_property(PathName,size(Size)),
	Size = 0 -> !, fail;
	true, !.

control_function_mask_one([],_,0) :- !, fail.
control_function_mask_one([],_,_) :- !.
control_function_mask_one([A|B],Var,Nonvar) :-
	A = '0x0000' -> Var1 is Var + 1, control_function_mask_one(B,Var1,Nonvar);
	Nonvar1 is Nonvar + 1, control_function_mask_one(B,Var,Nonvar1).

control_function_mask_two(Mask1,Mask2) :- 
	reverse(Mask1,Mask11), 
	list_equal_two(Mask11,Mask2) -> !, fail. % если равны маски, то мы пропускаем данный вариант. 
control_function_mask_two(Mask1,Mask2) :-
	(Mask1 \= Mask2, \+ list_equal(Mask1,Mask2)) -> !, fail; true, !.


%функции list_equal(равенство пропуская), list_equal_two(не было случая ) позволяют проверить образ(маску) получившихся функций по хэшу
list_equal([],[]) :- !.
list_equal(['0x0000'|B1],[_|B2]) :-
	list_equal(B1,B2), !.
list_equal([_|B1],['0x0000'|B2]) :-
	list_equal(B1,B2), !.
list_equal([A1|B1],[A2|B2]) :-
	A1 = A2 -> list_equal(B1,B2), !; !, fail.

list_equal_two([],[]) :- !.
list_equal_two(['0x0000'|B1],[A2|B2]) :-
	A2 \= '0x0000' -> !, fail;
	list_equal_two(B1,B2), !.
list_equal_two([A1|B1],['0x0000'|B2]) :-
	A1 \= '0x0000' -> !, fail;
	list_equal_two(B1,B2), !.
list_equal_two([_|B1],[_|B2]) :-
	list_equal_two(B1,B2).

body_function_mask([],Hash,Res) :- reverse(Hash,Res), !. % если список пустой, то результат равен перевернутому хэшу
body_function_mask([El|B],Hash,Res) :-
	(var(El) -> Op = '0x0000'; Op = El), 
	body_function_mask(B,[Op|Hash],Res).

save_term_in_file(PathName,Term) :-
	telling(Old),
	append(PathName),
	portray_clause(Term), nl,											% portray_clause(PathName,Term) - не работает
	told,
	tell(Old).

save(PathName) :-
	bagof(_,save_next(PathName), _), % аналог forall
	control_result(PathName).

save_next(PathName) :-
	unlink(PathName),
	predicate_property(Function, public),
	forall(clouse_term_body_three(PathName,Function),Function).
	%control_result(PathName).

% для поиска и сохранения предикатов с инициализированными переменными
save(PathName,Function) :-
	unlink(PathName),
	Function =.. [Head_Function|Body_Function],
	functor(Function,Head_Function,Arity),								% learn Arity
	functor(New_Function,Head_Function,Arity),							% generate a new function
	body_function_mask(Body_Function,[],Body_Function_Mask),
	\+ memberchk('0x0000',Body_Function_Mask), !,						%сть ли такое значение в этом списке, если результат Yes, то переходим к следующему save
	forall(clouse_term_body_one(PathName,New_Function,Body_Function_Mask),New_Function),
	control_result(PathName).

% для поиска и сохранения предикатов с неинициализированными переменными
save(PathName,Function) :-
	Function =.. [Head_Function|Body_Function],
	functor(Function,Head_Function,Arity),								% learn Arity
	length(New_Body_Function,Arity),
	body_function_mask(Body_Function,[],Body_Function_Mask),
	body_function_mask(New_Body_Function,[],Body_Function_Mask), !,		% Пороверка на то, что у нас все аргументы неинициализированны
	forall(clouse_term_body_three(PathName,Function),Function),
	control_result(PathName).

% для поиска и сохранения предикатов с отличными друг от друга переменными
save(PathName,Function) :-
	Function =.. [Head_Function|Body_Function],
	functor(Function,Head_Function,Arity),
	functor(New_Function,Head_Function,Arity),
	body_function_mask(Body_Function,[],Body_Function_Mask), %построение маски
	forall(clouse_term_body_two(PathName,New_Function,Body_Function_Mask),New_Function),
	control_result(PathName).

clouse_term_body_one(PathName,Function,Body_Function_Mask) :-
	clouse_term_body(Function,Term_Body),
	Function =.. [_|Body_Function],
	body_function_mask(Body_Function,[],Body_Function_Mask), % проверка подходит ли маска данной функции под данную
	Term =.. [:-,Function,Term_Body],
	save_term_in_file(PathName,Term).

clouse_term_body_two(PathName,Function,Body_Function_Mask) :-
	clouse_term_body(Function,Term_Body),
	Function =.. [_|Body_Function],
	body_function_mask(Body_Function,[],New_Body_Function_Mask),
	control_function_mask_one(New_Body_Function_Mask,0,0),
	control_function_mask_two(New_Body_Function_Mask,Body_Function_Mask),
	Term =.. [:-,Function,Term_Body],
	save_term_in_file(PathName,Term).

clouse_term_body_three(PathName,Function) :-
	clouse_term_body(Function,Term_Body),
	Term =.. [:-,Function,Term_Body],
	save_term_in_file(PathName,Term).
