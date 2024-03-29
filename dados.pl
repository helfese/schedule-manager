/*
O predicado eventosSemSalas/1 encontra IDs de eventos sem salas. Sendo eventosSemSalas(EventosSemSala)
true, se EventosSemSala for uma lista ordenada de IDs de eventos sem sala, sem IDs repetidos.
*/
eventosSemSalas(EventosSemSala) :- findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).

/*
O predicado eventosSemSalasDiaSemana/2 encontra IDs de eventos sem salas dum dia da semana.
Sendo eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) true, se EventosSemSala for uma
lista ordenada de IDs de eventos sem sala, sem IDs repetidos, dum dia de semana DiaDaSemana.
*/
eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) :-
    findall(ID, (evento(ID, _, _, _, semSala), horario(ID, DiaDaSemana, _, _, _, _)), EventosSemSala).

/*
O predicado eventosSemSalasPeriodo/2 encontra IDs de eventos sem salas dum periodo. Sendo
eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) true, se EventosSemSala for uma lista
ordenada de IDs de eventos sem sala, sem IDs repetidos, dos periodos duma lista ListaPeriodos.
*/
eventosSemSalasPeriodo([], []).
eventosSemSalasPeriodo([Periodo | RestoListaPeriodos], EventosSemSala) :-
    findall(ID,(evento(ID, _, _, _, semSala), eventoSemestral(Periodo, PeriodoSemestre),
    horario(ID, _, _, _, _, PeriodoSemestre)), EventosSemSalasDumPeriodo), !,
    eventosSemSalasPeriodo(RestoListaPeriodos, MaisEventosSemSala),
    append([EventosSemSalasDumPeriodo, MaisEventosSemSala], EventosSemSalasPeriodos),
    sort(EventosSemSalasPeriodos, EventosSemSala).

% O predicado eventoSemestral/2, ou eventoSemestral(Periodo, Periodos), associa
% o periodo Periodo ao respetivo semestre, devolvendo-os no periodo PeriodoSemestre.
eventoSemestral(Periodo, PeriodoSemestre) :-
    Periodo == p1, member(PeriodoSemestre, [Periodo, p1_2]);
    Periodo == p2, member(PeriodoSemestre, [Periodo, p1_2]);
    Periodo == p3, member(PeriodoSemestre, [Periodo, p3_4]);
    Periodo == p4, member(PeriodoSemestre, [Periodo, p3_4]).

/*
O predicado organizaEventos/3 encontra e ordena os IDs de eventos em duns do mesmo. Sendo
organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) true, se EventosNoPeriodo for uma
lista ordenada de IDs de eventos duma lista ListaEventos, sem IDs repetidos, dum periodo Periodo.
*/
organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) :-
    organizaEventosDesordenado(ListaEventos, Periodo, EventosNoPeriodoDesordenados),
    sort(EventosNoPeriodoDesordenados, EventosNoPeriodo).

% O predicado organizaEventosDesordenado/3, ou organizaEventos(ListaEventos, Periodo, EventosNoPeriodoDesordenados),
% encontra IDs de eventos duma lista ListaEventos em duns do mesmo periodo
% Periodo, organizando-os numa lista desordenada EventosNoPeriodoDesordenados.
organizaEventosDesordenado([], _, []).
organizaEventosDesordenado([Evento | RestoListaEventos], Periodo, [Evento | EventosNoPeriodo]) :-
    eventoSemestral(Periodo, PeriodoSemestre), horario(Evento, _, _, _, _, PeriodoSemestre), !,
    organizaEventosDesordenado(RestoListaEventos, Periodo, EventosNoPeriodo).
organizaEventosDesordenado([_ | RestoListaEventos], Periodo, EventosNoPeriodo) :-
    organizaEventosDesordenado(RestoListaEventos, Periodo, EventosNoPeriodo).

/*
O predicado eventosMenoresQue/2 encontra IDs de eventos com um dado limite maximo de duracao.
Sendo eventosMenoresQue(Duracao, ListaEventosMenoresQue) true, se ListaEventosMenoresQue for uma
lista ordenada de IDs de eventos, sem IDs repetidos, de duracao menor ou igual a duracao duma Duracao.
*/
eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    findall(ID, (horario(ID, _, _, _, Duracoes, _), Duracoes =< Duracao), ListaEventosMenoresQue).

/*
O predicado eventosMenoresQueBool/2 verifica se um evento tem um dado limite maximo de duracao. Sendo
eventosMenoresQueBool(ID, Duracao) true, se o evento identificado pelo ID tiver duracao menor ou igual a duracao duma Duracao.
*/
eventosMenoresQueBool(ID, Duracao) :- horario(ID, _, _, _, Duracoes, _), Duracoes =< Duracao.

O predicado procuraDisciplinas/2 procura as disciplinas dum curso. Sendo procuraDisciplinas(Curso, ListaDisciplinas)
true, se ListaDisciplinas for uma lista ordenada alfabeticamente das disciplinas dum curso Curso.
*/
procuraDisciplinas(Curso, ListaDisciplinas) :-
    findall(NomeDisciplina,(turno(ID, Curso, _, _), evento(ID, NomeDisciplina, _, _, _)), ListaDisciplinasDesordenada),
    sort(ListaDisciplinasDesordenada, ListaDisciplinas).

/*
O predicado organizaDisciplinas/3 organiza as disciplinas dum curso por semestre. Sendo
organizaDisciplinas(ListaDisciplinas, Curso, Semestres) true, se Semestres for uma lista com duas listas
ordenadas alfabeticamente de disciplinas semestrais, sem disciplinas repetidas, duma lista ListaDisciplinas
dum curso Curso. Sendo a primeira e a segunda lista do primeiro e do segundo semestre, respetivamente.
*/
organizaDisciplinas(ListaDisciplinas, Curso, Semestres) :-
    encontraDisciplinasPorSemestre(ListaDisciplinas, Curso, Semestre1, Semestre2), !, append([[Semestre1], [Semestre2]], Semestres).

% O predicado encontraDisciplinasPorSemestre/4, ou organizaDisciplinas(ListaDisciplinas, Curso, Semestre1, Semestre2),
% organiza as disciplinas duma lista ListaDisciplinas dum curso Curso por semestre nas listas ordenadas alfabeticamente de disciplinas
% semestrais Semestre1 e Semestre2, a primeira e a segunda lista do primeiro e do segundo semestre, respetivamente, sem disciplinas repetidas.
encontraDisciplinasPorSemestre([], _, [], []).
encontraDisciplinasPorSemestre([NomeDisciplina | RestoListaDisciplinas], Curso, [NomeDisciplina | Semestre1], Semestre2) :-
    evento(ID, NomeDisciplina, _, _, _), turno(ID, Curso, _, _),
    member(Periodos, [p1, p2, p1_2]), horario(ID, _, _, _, _, Periodos),
    encontraDisciplinasPorSemestre(RestoListaDisciplinas, Curso, Semestre1, Semestre2).
encontraDisciplinasPorSemestre([NomeDisciplina|RestoListaDisciplinas], Curso, Semestre1, [NomeDisciplina|Semestre2]) :-
    evento(ID, NomeDisciplina, _, _, _), turno(ID, Curso, _, _),
    member(Periodos, [p3, p4, p3_4]), horario(ID, _, _, _, _, Periodos),
    encontraDisciplinasPorSemestre(RestoListaDisciplinas, Curso, Semestre1, Semestre2).

/*
O predicado horasCurso/4 calcula as horais totais dum curso num periodo dum ano. Sendo horasCurso(Periodo, Curso, Ano, TotalHoras)
true, se TotalHoras forem as horas totais dos eventos dum curso Curso num periodo Periodo dum ano Ano.
*/
horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    findall(ID, turno(ID, Curso, Ano, _), ListaEventosAux), sort(ListaEventosAux, ListaEventos),
    findall(Duracao, (member(ID, ListaEventos), eventoSemestral(Periodo, PeriodoSemestre),
        horario(ID, _, _, _, Duracao, PeriodoSemestre)), ListaHoras), !, sum_list(ListaHoras, TotalHoras).

/*
O predicado evolucaoHorasCurso/2 encontra a evolucao das horas totais dum curso a cada periodo de cada ano. Sendo
evolucaoHorasCurso(Curso, Evolucao) true, se Evolucao for uma lista de tuplos da forma (Ano, Periodo, TotalHoras)
ordenada ascendentemente por ano Ano e periodo Periodo e TotalHoras sendo as horas totais dum curso Curso num periodo Periodo dum ano Ano.
*/
evolucaoHorasCurso(Curso, Evolucao) :-
    evolucaoHorasCursoPorLista([1, 2, 3], Curso, EvolucaoEmListas), append(EvolucaoEmListas, Evolucao).

% O predicado evolucaoHorasCursoPorLista/3, ou evolucaoHorasCursoPorLista([1, 2, 3], Curso, EvolucaoEmListas),
% encontra a evolucao das horas totais dum curso Curso a cada periodo Periodo de um ano Ano, organizando-as
% numa lista de listas de tuplos da forma (Ano, Periodo, TotalHoras) ordenada ascendentemente por ano
% Ano, periodo Periodo e TotalHoras sendo as horas totais dum curso num periodo Periodo dum ano Ano.
evolucaoHorasCursoPorLista([], _, []).
evolucaoHorasCursoPorLista([Ano | RestoAnos], Curso, [EvolucaoAnual | RestoEvolucao]) :-
    horasCursoAnual(Curso, Ano, ListaTotalHorasAnual),
    evolucaoAnual(Ano, ListaTotalHorasAnual, Curso, EvolucaoAnual),
    evolucaoHorasCursoPorLista(RestoAnos, Curso, RestoEvolucao).

% O predicado horasCursoAnual/3, ou horasCursoAnual(Curso, Ano, ListaTotalHorasAnual), encontra as
% horas totais, organizando-as numa lista ListaTotalHorasAnual, dum curso Curso a cada periodo dum ano Ano.
horasCursoAnual(Curso, Ano, ListaTotalHorasAnual) :-
    findall(TotalHorasPeriodo, (member(Periodo, [p1, p2, p3, p4]), horasCurso(Periodo, Curso, Ano, TotalHorasPeriodo)), ListaTotalHorasAnual).

% O predicado evolucaoAnual/4, ou evolucaoAnual(Ano, ListaTotalHorasAnual, Curso, EvolucaoAnual),
% organiza a evolucao das horas totais duma lista ListaTotalHorasAnual dum curso Curso por periodo dum ano Ano.
evolucaoAnual(Ano, [TotalHorasPeriodo1, TotalHorasPeriodo2, TotalHorasPeriodo3, TotalHorasPeriodo4], _, EvolucaoAnual) :-
    append([[(Ano, p1, TotalHorasPeriodo1)], [(Ano, p2, TotalHorasPeriodo2)],
        [(Ano, p3, TotalHorasPeriodo3)], [(Ano, p4, TotalHorasPeriodo4)]], EvolucaoAnual).

/*
O predicado ocupaSlot/5 calcula as horais sobrepostas entre um evento e um slot. Sendo
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) true, se Horas forem as horas sobrepostas
entre um evento com entre as horas HoraInicioEvento e HoraFimEvento, e um slot entre a horas HoraInicioDada e HoraFimDada.
*/
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    HoraInicioDada =< HoraInicioEvento, HoraFimDada > HoraInicioEvento,
    HoraFimDada =< HoraFimEvento, !, Horas is HoraFimDada - HoraInicioEvento.
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    HoraFimDada >= HoraFimEvento, HoraInicioDada < HoraFimEvento,
    HoraInicioDada > HoraInicioEvento, !, Horas is HoraFimEvento - HoraInicioDada.
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    HoraInicioDada =< HoraInicioEvento, HoraFimDada >= HoraFimEvento, !,
    Horas is HoraFimEvento - HoraInicioEvento.
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    HoraInicioDada >= HoraInicioEvento, HoraFimDada =< HoraFimEvento, !,
    Horas is HoraFimDada - HoraInicioDada.
ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, _) :-
    \+ (HoraFimDada =< HoraInicioEvento; HoraInicioDada >= HoraFimEvento).

/*
O predicado numHorasOcupadas/6 calcula as horas ocupadas em salas dum tipo num intervalo de tempo num dia de semana dum
periodo. Sendo numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) true, se SomaHoras forem as
horas ocupadas nas salas do tipo TipoSala, entre as horas HoraInicio e HoraFim, num dia de semana DiaSemana dum periodo Periodo.
*/
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicioDada, HoraFimDada, SomaHoras):-
    salas(TipoSala, Salas),
    findall(Horas, (eventoSemestral(Periodo, PeriodoSemestre),member(Sala, Salas),
        horario(ID, DiaSemana, HoraInicio, HoraFim, _Duracao, PeriodoSemestre),
        evento(ID, _NomeDisciplina, _Tipologia, _NumAlunos, Sala),
        ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicio, HoraFim, Horas)), ListaHoras),
    sum_list(ListaHoras, SomaHoras).

/*
O predicado ocupacaoMax/4 calcula as horas possiveis de serem ocupadas em salas dum tipo num
intervalo de tempo. Sendo ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) true, se Max forem as
horas possiveis de serem ocupadas por salas do tipo TipoSala, entre as horas HoraInicio e HoraFim.
*/
ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-
    salas(TipoSala, ListaSalas), length(ListaSalas, NumSalas), Max is NumSalas * (HoraFim - HoraInicio).

/*
O predicado percentagem/3, ou percentagem(SomaHoras, Max, Percentagem), calcula a percentagem Percentagem entre as
horas ocupadas SomaHoras e as possiveis Max em salas dum tipo num intervalo de tempo num dia de semana dum periodo.
*/
percentagem(SomaHoras, Max, Percentagem) :- Percentagem is (SomaHoras / Max) * 100.

/*
O predicado ocupacaoCritica/4 encontra casos de tipos de salas num dia de semana com um dado limite minimo de percentagem
de ocupacao. Sendo ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) true, se Resultados for uma lista ordenada
de tuplos casosCriticos(DiaSemana, TipoSala, Percentagem) com um dia de semana DiaSemana, um tipo de sala TipoSala e uma
percentagem Percentagem de ocupacao arredondada acima dum valor critico Threshold, entre as horas HoraInicio e HoraFim.
*/
ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) :-
    findall(casosCriticos(DiaSemana, TipoSala, PercentagemInt), (salas(TipoSala, _), horario(_, DiaSemana, _, _, _, Periodo),
        numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras), ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
