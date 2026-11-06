(function () {
  'use strict';
  const esc = value => String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  const number = (value, digits = 0) => Number(value).toLocaleString('en-US', {minimumFractionDigits: digits, maximumFractionDigits: digits});
  const signed = (value, digits = 0) => `${value > 0 ? '+' : ''}${number(value, digits)}`;
  const percent = value => `${(100 * value).toFixed(1)}%`;
  const actionLabel = (action, cost) => `${action[0]}${action.slice(1).toLowerCase()}${cost ? ` (${cost})` : ''}`;

  const normalize = values => {
    const total = Object.values(values).reduce((sum, value) => sum + value, 0);
    return Object.fromEntries(Object.entries(values).map(([action, value]) =>
      [action, total > 0 ? value / total : 1 / Object.keys(values).length]));
  };

  function mount(element, model = window.CFR_POKER_MODEL, engine = window.Leduc) {
    if (!element || element.dataset.pokerMounted) return;
    element.dataset.pokerMounted = 'true';
    let state, human = 0, pnl = 0, scored = false, edited = false;
    let inspect = false, probe = false, baseline = null, error = '', fatal = false, revision = 0;
    const button = (label, command, extra = '') => `<button type="button" data-command="${command}" ${extra}>${label}</button>`;
    const closePanels = () => { inspect = false; probe = false; baseline = null; error = ''; };
    const decision = () => !fatal && state && engine.currentPlayer(state) === human;
    function modelNode() {
      const node = model.nodes[engine.informationSet(state)], actions = engine.legalActions(state);
      if (!node || actions.some(a => !Number.isFinite(node.regret_sum[a]) ||
          !Number.isFinite(node.strategy_sum[a]) || node.strategy_sum[a] < 0))
        throw new Error('Model does not cover this decision.');
      return {actions, node: {...node,
        current_strategy: normalize(Object.fromEntries(actions.map(a => [a, Math.max(0, node.regret_sum[a])]))),
        average_strategy: normalize(node.strategy_sum)}};
    }

    function advance() {
      while (!engine.isTerminal(state) && engine.currentPlayer(state) !== human) {
        const actor = engine.currentPlayer(state);
        const action = actor === engine.CHANCE_PLAYER ? engine.sample(engine.chanceOutcomes(state)) :
          engine.sample(modelNode().node.average_strategy);
        state = engine.nextState(state, action);
      }
      if (engine.isTerminal(state) && !scored) {
        pnl += engine.utility(state, human); scored = true;
      }
    }
    function newHand() {
      closePanels(); state = engine.root(); scored = false; edited = false; advance();
    }
    function reset() {
      pnl = 0; newHand(); render();
    }
    function report() {
      const {node, actions} = modelNode();
      const definition = {...state, player: human, card: state.cards[human]};
      const rank = card => ({J: 'Jack (J)', Q: 'Queen (Q)', K: 'King (K)'})[card];
      const history = actions => actions.length ? actions.map((action, index) =>
        `P${index % 2 + 1} ${{CHECK: 'checks', BET: 'bets', CALL: 'calls', FOLD: 'folds', RAISE: 'raises'}[action]}`).join(', ') : 'No actions yet';
      return `<section class="poker-panel" aria-label="Model inspection">
        <h4>Model inspection</h4><div class="poker-decision">
        <p><strong>P${definition.player + 1} to act</strong> · Your card: ${rank(definition.card)} · Community card: ${definition.public_card ? rank(definition.public_card) : 'not revealed'}</p>
        <p>Round 1: ${esc(history(definition.round1_history))}<br>Round 2: ${definition.public_card ? esc(history(definition.round2_history)) : 'Not started'}</p></div>
        <div class="poker-table-wrap"><table aria-label="Action probabilities and regrets">
        <thead><tr>${[
          ['Action', 'An available action a in A_j.'],
          ['Cumulative counterfactual regret', 'r_j^(T)[a]: signed sum of counterfactual regret updates through training iteration T.'],
          ['Positive part', 'max(0, r_j^(T)[a]): used for regret matching; negative stored regrets are retained.'],
          ['Regret-matching probability', 'b_j^(T+1)[a]: computed from the final regrets for the next training iteration. Uniform when all positive parts are zero.'],
          ['Accumulated strategy weight', 'Sum of each training probability multiplied by this player’s own reach probability.'],
          ['Played probability (training average)', 'The own-reach-weighted average through iteration T; the bot samples this policy. Uniform if no averaging weight has accumulated.']
        ].map(([label, meaning]) => `<th scope="col" title="${esc(meaning)}">${label}</th>`).join('')}</tr></thead>
        <tbody>${actions.map(a => `<tr><th scope="row">${actionLabel(a, engine.actionCost(state, a))}</th><td>${signed(node.regret_sum[a], 2)}</td><td>${number(Math.max(0,node.regret_sum[a]), 2)}</td><td>${percent(node.current_strategy[a])}</td><td>${number(node.strategy_sum[a])}</td><td>${percent(node.average_strategy[a])}</td></tr>`).join('')}</tbody></table></div>
        <details class="poker-explanation"><summary>How CFR calculates these probabilities</summary>
        <p>Each decision point has a local regret minimizer <i>R</i><sub>j</sub>.
        Its cumulative regret vector is <b><i>r</i></b><sub>j</sub>; the table shows one component per action.
        At iteration <i>t</i>, let <i>g</i><sub>j</sub><sup>t</sup>[<i>a</i>] be the counterfactual utility of action <i>a</i>:
        its expected continuation utility weighted by chance and opponent reach and summed over histories in decision point <i>j</i>.
        The cumulative regret update is <i>r</i><sub>j</sub><sup>t</sup>[<i>a</i>] = <i>r</i><sub>j</sub><sup>t−1</sup>[<i>a</i>]
        + <i>g</i><sub>j</sub><sup>t</sup>[<i>a</i>] − ∑<sub><i>a′</i> ∈ <i>A</i><sub>j</sub></sub>
        <i>b</i><sub>j</sub><sup>t</sup>[<i>a′</i>] <i>g</i><sub>j</sub><sup>t</sup>[<i>a′</i>],
        where <i>b</i><sub>j</sub><sup>t</sup> is the local strategy used in that iteration.</p>
        <p>Weights accumulate each iteration’s local probability multiplied by this player’s own reach probability:
        the product of their earlier action probabilities. The bot samples the training average at its own decision points.</p>
        <p>See <a href="learning_efg.html#sec-cfr">local regret minimizers</a>,
        <a href="learning_efg.html#where-the-magic-happens-counterfactual-utilities">counterfactual utilities</a>,
        and <a href="learning_efg.html#algo:cfr">the CFR pseudocode</a>.</p></details>
        ${button('Close inspection','inspect')}</section>`;
    }
    function probeForm() {
      const select = (name, label, value, blank = false) => `<label>${label}<select name="${name}">
        ${(blank ? [null, ...engine.CARDS] : engine.CARDS).map(rank => `<option value="${rank || ''}" ${rank === value ? 'selected' : ''}>${rank || 'Not revealed'}</option>`).join('')}</select></label>`;
      return `<section class="poker-panel" aria-label="State editor"><h4>Edit state · hidden cards revealed</h4>
        <p>Viewing this panel reveals both cards. Applying edits queries the fixed model; it does not retrain CFR. Edited hands count toward session PnL.</p>
        <form data-probe><div class="poker-fields">
        ${select('your_card','Your private rank',state.cards[human])}
        ${select('opponent_card',"Opponent’s private rank",state.cards[1-human])}
        ${select('public_card','Community rank',state.public_card,true)}
        <label>Round 1 history<input name="round1_history" value="${esc(state.round1_history.join(' '))}" placeholder="e.g. CHECK BET CALL"></label>
        <label>Round 2 history<input name="round2_history" value="${esc(state.round2_history.join(' '))}" placeholder="Leave empty at round start"></label></div>
        <p>Use space-separated CHECK, BET, CALL, FOLD, RAISE. The result must be a valid state.</p>
        <p class="poker-error" role="alert" data-probe-error>${esc(error)}</p>
        <div class="poker-controls"><button type="submit" data-command="apply">Apply edits</button>${button('Undo edits','undo',baseline ? '' : 'disabled')}${button('Cancel / close','probe')}</div></form></section>`;
    }
    function render(preserveProbe = true) {
      const form = element.querySelector('[data-probe]');
      const draft = preserveProbe && probe && form ? [...new FormData(form)] : [];
      const focus = document.activeElement?.closest('[data-command], [name], [data-seat]');
      const focusKey = focus?.dataset.command || focus?.name || (focus?.hasAttribute('data-seat') ? 'seat' : '');
      revision++;
      const view = engine.view(state, human), terminal = engine.isTerminal(state);
      const outcome = terminal ? `Hand net: ${signed(view.net_gain)} chips.` : 'Your decision.';
      element.innerHTML = `<div class="poker-toolbar"><label>seat <select data-seat aria-label="seat"><option value="0" ${human === 0 ? 'selected' : ''}>P1</option><option value="1" ${human === 1 ? 'selected' : ''}>P2</option></select></label>
        <span>Session PnL: <strong>${signed(pnl)} chips</strong></span></div>
        <div class="poker-table" role="group" aria-label="Leduc poker table">
        <div class="poker-seat poker-bot"><span>Bot · P${2-human}</span><strong class="poker-card ${view.opponent_card === '?' ? 'poker-card-back' : ''}" aria-label="${view.opponent_card === '?' ? 'Hidden card' : esc(view.opponent_card)}">${esc(view.opponent_card)}</strong></div>
        <div class="poker-seat poker-shared"><span class="poker-pot">Pot: ${view.pot} chips</span><strong class="poker-card ${view.public_card ? '' : 'poker-card-empty'}" aria-label="Community card${view.public_card ? ': ' + esc(view.public_card) : ': not revealed'}">${esc(view.public_card || '—')}</strong><span>Community card</span></div>
        <div class="poker-seat poker-human"><strong class="poker-card">${esc(view.your_card)}</strong><span>You · P${human+1}</span></div></div>
        ${edited ? '<p class="poker-edited-hand">Edited hand</p>' : ''}
        <p role="status" aria-live="polite">${outcome}${terminal && !view.showdown ? ' Opponent card stays hidden after a fold.' : ''}</p>
        <div class="poker-controls">${terminal ? button('Next hand','next') : engine.legalActions(state).map(action => {
          const cost = engine.actionCost(state, action);
          return button(actionLabel(action, cost),'action',`data-action="${action}" data-revision="${revision}"`);
        }).join('')}</div>
        <div class="poker-controls">${button(inspect ? 'Hide inspection' : 'Inspect model','inspect',terminal ? 'disabled' : '')}${button(probe ? 'Close editor' : 'Edit state','probe',terminal ? 'disabled' : '')}</div>
        <details class="poker-history" open><summary>Hand history</summary><ol>${view.events.map(event => `<li>${esc(event.replace(/^Public card:/, 'Community card:'))}</li>`).join('')}</ol></details>
        ${inspect ? report() : ''}${probe ? probeForm() : ''}
        <p class="poker-provenance">Bot is CFR average policy from ${number(model.iteration)} self-play iterations.</p>`;
      for (const [name, value] of draft) element.querySelector(`[name="${name}"]`).value = value;
      if (focusKey) {
        const candidate = [...element.querySelectorAll('[data-command], [name], [data-seat]')].find(el =>
          !el.disabled && (el.dataset.command === focusKey || el.name === focusKey || (focusKey === 'seat' && el.hasAttribute('data-seat'))));
        (candidate || element.querySelector('button:not(:disabled)'))?.focus();
      }
    }
    function fail(exception) {
      fatal = true;
      element.innerHTML = `<p role="alert">The poker demo could not load: ${esc(exception.message)} Please reload the page.</p>`;
    }
    element.addEventListener('click', event => {
      const control = event.target.closest('[data-command]');
      if (!control || !element.contains(control) || control.disabled || event.detail > 1 || fatal) return;
      try {
        const command = control.dataset.command;
        if (command === 'action' && decision() && Number(control.dataset.revision) === revision) {
          state = engine.nextState(state, control.dataset.action); closePanels(); advance();
        } else if (command === 'next' && engine.isTerminal(state)) newHand();
        else if (command === 'inspect' && decision()) inspect = !inspect;
        else if (command === 'probe' && decision()) { probe = !probe; error = ''; }
        else if (command === 'undo' && baseline && decision()) { state = baseline.state; edited = baseline.edited; baseline = null; error = ''; }
        else return;
        render(command !== 'undo');
      } catch (exception) { fail(exception); }
    });
    element.addEventListener('change', event => {
      if (!event.target.matches('[data-seat]') || fatal) return;
      human = Number(event.target.value);
      try { reset(); } catch (exception) { fail(exception); }
    });
    element.addEventListener('submit', event => {
      if (!event.target.matches('[data-probe]') || !decision()) return;
      event.preventDefault();
      const fields = new FormData(event.target);
      const history = key => String(fields.get(key)).trim().toUpperCase().split(/\s+/).filter(Boolean);
      const cards = []; cards[human] = fields.get('your_card'); cards[1-human] = fields.get('opponent_card');
      try {
        const candidate = engine.editDecision(state, {cards, public_card: fields.get('public_card') || null,
          round1_history: history('round1_history'), round2_history: history('round2_history')}, human);
        if (!baseline) baseline = {state, edited};
        state = candidate; edited = true; error = ''; render(false);
      } catch (exception) {
        error = exception.message;
        element.querySelector('[data-probe-error]').textContent = error;
      }
    });
    window.addEventListener('pagehide', () => {
      state = null; pnl = 0; closePanels();
      element.innerHTML = '<p>Session ended. Returning starts a new session.</p>';
    });
    window.addEventListener('pageshow', event => {
      if (event.persisted && !fatal) { try { reset(); } catch (exception) { fail(exception); } }
    });
    try {
      if (!engine) throw new Error('Leduc engine unavailable.');
      if (!model?.nodes) throw new Error('Model unavailable.');
      reset();
    } catch (exception) { fail(exception); }
  }
  window.CFRPoker = {mount};
  const initialize = () => mount(document.getElementById('cfr-poker'));
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initialize, {once: true});
  else initialize();
})();
