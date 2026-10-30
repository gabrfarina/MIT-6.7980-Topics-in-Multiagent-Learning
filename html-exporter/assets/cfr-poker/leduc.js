/* Leduc rules: two copies of J/Q/K, one bet and one raise per round. */
(function (global) {
  'use strict';
  const CARDS = Object.freeze(['J', 'Q', 'K']);
  const CHANCE_PLAYER = -1, TERMINAL_PLAYER = -2;
  const fail = message => { throw new Error(message); };
  const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

  function roundStatus(history, number) {
    if (!Array.isArray(history) || ![1, 2].includes(number)) fail('Invalid round');
    let player = 0, contributions = [0, 0], raises = 0;
    let actions = ['CHECK', 'BET'], fold_winner = null;
    history.forEach((action, index) => {
      if (!actions.includes(action)) fail('Invalid betting history');
      let closed = false;
      if (action === 'FOLD') { closed = true; fold_winner = 1 - player; }
      else if (action === 'CALL') { contributions[player] = contributions[1 - player]; closed = true; }
      else if (action === 'CHECK') closed = index > 0 && history[index - 1] === 'CHECK';
      else { contributions[player] = contributions[1 - player] + (number === 1 ? 2 : 4); raises += action === 'RAISE'; }
      player = 1 - player;
      actions = closed ? [] : contributions[0] === contributions[1] ? ['CHECK', 'BET'] :
        raises ? ['CALL', 'FOLD'] : ['CALL', 'FOLD', 'RAISE'];
    });
    return {player, contributions, actions, closed: !actions.length, fold_winner};
  }

  function makeState(fields = {}) {
    const state = {cards: null, public_card: null, round1_history: [], round2_history: [], ...fields};
    const first = roundStatus(state.round1_history, 1);
    roundStatus(state.round2_history, 2);
    if (state.cards === null) {
      if (state.public_card !== null || state.round1_history.length || state.round2_history.length)
        fail('Cannot act or reveal cards before the private deal');
    } else {
      if (!Array.isArray(state.cards) || state.cards.length !== 2 || !state.cards.every(card => CARDS.includes(card)))
        fail('Private cards must be ranks from J, Q, K');
      if (state.public_card !== null) {
        if (!CARDS.includes(state.public_card) || state.cards.filter(card => card === state.public_card).length === 2)
          fail('Public card violates rank multiplicities');
        if (!first.closed || first.fold_winner !== null) fail('Public deal requires a completed non-fold first round');
      } else if (state.round2_history.length) fail('Cannot bet in round two before the public deal');
    }
    state.cards = state.cards === null ? null : Object.freeze([...state.cards]);
    state.round1_history = Object.freeze([...state.round1_history]);
    state.round2_history = Object.freeze([...state.round2_history]);
    return Object.freeze(state);
  }
  const root = () => makeState();
  const roundNumber = state => state.public_card === null ? 1 : 2;
  const bettingStatus = state => roundStatus(state.public_card === null ? state.round1_history : state.round2_history, roundNumber(state));
  function isTerminal(state) {
    const status = bettingStatus(state);
    return status.fold_winner !== null || (state.public_card !== null && status.closed);
  }
  function currentPlayer(state) {
    if (isTerminal(state)) return TERMINAL_PLAYER;
    if (state.cards === null || (state.public_card === null && bettingStatus(state).closed)) return CHANCE_PLAYER;
    return bettingStatus(state).player;
  }
  function chanceOutcomes(state) {
    if (currentPlayer(state) !== CHANCE_PLAYER) fail('Not a chance state');
    if (state.cards === null) return CARDS.flatMap(a => CARDS.map(b => [[a, b], (2 / 6) * ((2 - (a === b)) / 5)]));
    return CARDS.map(card => [card, (2 - state.cards.filter(rank => rank === card).length) / 4]).filter(([, p]) => p > 0);
  }
  function legalActions(state) {
    const player = currentPlayer(state);
    return player === TERMINAL_PLAYER ? [] : player === CHANCE_PLAYER ? chanceOutcomes(state).map(([action]) => action) : bettingStatus(state).actions;
  }
  function nextState(state, action) {
    if (!legalActions(state).some(legal => same(legal, action))) fail('Illegal action');
    if (state.cards === null) return makeState({cards: action});
    if (currentPlayer(state) === CHANCE_PLAYER) return makeState({...state, public_card: action});
    const field = state.public_card === null ? 'round1_history' : 'round2_history';
    return makeState({...state, [field]: [...state[field], action]});
  }
  function informationSet(state) {
    const player = currentPlayer(state);
    if (![0, 1].includes(player)) fail('Information sets exist only at player decisions');
    return `P${player + 1}:${state.cards[player]}|public:${state.public_card || '-'}|R1:${state.round1_history.join(' ') || 'START'}|R2:${state.round2_history.join(' ') || 'START'}`;
  }
  function contributions(state) {
    const first = roundStatus(state.round1_history, 1).contributions;
    const second = roundStatus(state.round2_history, 2).contributions;
    return [0, 1].map(player => 1 + first[player] + second[player]);
  }
  function utility(state, player) {
    if (![0, 1].includes(player) || !isTerminal(state)) fail('Utility requires a terminal state and player 0 or 1');
    const chips = contributions(state), pot = chips[0] + chips[1];
    let winner = bettingStatus(state).fold_winner;
    if (winner === null) {
      const strengths = state.cards.map(card => (card === state.public_card ? 3 : 0) + CARDS.indexOf(card));
      if (strengths[0] === strengths[1]) return pot / 2 - chips[player];
      winner = strengths[0] > strengths[1] ? 0 : 1;
    }
    return player === winner ? pot - chips[player] : -chips[player];
  }
  function actionCost(state, action) {
    if (![0, 1].includes(currentPlayer(state))) fail('Action costs require a player decision');
    const player = currentPlayer(state);
    return contributions(nextState(state, action))[player] - contributions(state)[player];
  }
  function publicEvents(state) {
    if (state.cards === null) return [];
    let replay = nextState(root(), state.cards), events = ['Private cards dealt'];
    [state.round1_history, state.round2_history].forEach((history, index) => {
      if (index === 1 && state.public_card !== null) {
        replay = nextState(replay, state.public_card);
        events.push(`Public card: ${state.public_card}`);
      }
      history.forEach(action => {
        events.push(`P${currentPlayer(replay) + 1} ${action}`);
        replay = nextState(replay, action);
      });
    });
    return events;
  }
  function view(state, human) {
    if (![0, 1].includes(human)) fail('Human player must be 0 or 1');
    const terminal = isTerminal(state), chips = contributions(state);
    const showdown = terminal && bettingStatus(state).fold_winner === null;
    return {your_card: state.cards ? state.cards[human] : null,
      opponent_card: showdown ? state.cards[1 - human] : '?', public_card: state.public_card,
      round: roundNumber(state), pot: chips[0] + chips[1], contributions: chips, events: publicEvents(state),
      terminal, showdown, legal_actions: legalActions(state), net_gain: terminal ? utility(state, human) : null};
  }
  function editDecision(state, changes, human) {
    if (![0, 1].includes(currentPlayer(state))) fail('Probes require a player decision');
    if (human !== undefined && currentPlayer(state) !== human) fail('Not the human decision');
    const fields = ['cards', 'public_card', 'round1_history', 'round2_history'];
    if (!changes || Object.keys(changes).some(key => !fields.includes(key))) fail('Unsupported state field');
    const candidate = makeState({...state, ...changes});
    if (![0, 1].includes(currentPlayer(candidate)) || (human !== undefined && currentPlayer(candidate) !== human))
      fail('Probe must leave you with a decision to make');
    publicEvents(candidate); // Replay with ordinary transitions before committing any edit.
    return candidate;
  }
  function sample(weights, rng = Math.random) {
    const entries = Array.isArray(weights) ? weights : Object.entries(weights);
    if (!entries.length || entries.some(([, p]) => !Number.isFinite(p) || p < 0)) fail('Invalid sampling weights');
    const total = entries.reduce((sum, [, p]) => sum + p, 0);
    if (!(total > 0)) fail('Sampling weights must have positive total');
    const random = rng();
    if (!Number.isFinite(random) || random < 0 || random >= 1) fail('Random value must be in [0, 1)');
    let threshold = random * total;
    for (const [action, weight] of entries) { threshold -= weight; if (threshold < 0) return action; }
    return entries.filter(([, p]) => p > 0).at(-1)[0];
  }
  const api = Object.freeze({CARDS, CHANCE_PLAYER, TERMINAL_PLAYER, root, roundStatus, roundNumber,
    bettingStatus, isTerminal, currentPlayer, chanceOutcomes, legalActions, nextState, informationSet,
    contributions, utility, actionCost, publicEvents, view, editDecision, sample});
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  global.Leduc = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
