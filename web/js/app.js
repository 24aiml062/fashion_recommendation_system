// ── State ──────────────────────────────────────────────
let currentUser = null;
let styleProfile = null;
let wardrobeItems = [];
let tinderOutfits = [];
let tinderIndex = 0;
let quizStep = 0;
let quizData = {
  outfit_ratings: {}, lifestyle: 'student', social_frequency: 'occasionally',
  daily_environment: 'campus', fashion_importance: 3, budget_range: 'medium',
  favorite_colors: [], avoided_colors: [], fit_preference: 'regular', fashion_goals: []
};

// ── Page routing ────────────────────────────────────────
function showPage(id) {
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  if (id === 'page-app') initApp();
  if (id === 'page-profile') loadProfile();
}

function switchTab(tab) {
  document.querySelectorAll('.tab-content').forEach(t => t.style.display = 'none');
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.getElementById('tab-' + tab).style.display = 'block';
  document.getElementById('nav-' + tab).classList.add('active');
  if (tab === 'discover') loadDiscover();
  if (tab === 'wardrobe') loadWardrobe();
  if (tab === 'calendar') loadCalendar();
  if (tab === 'stylist') loadChatHistory();
}

function showProfilePage() {
  showPage('page-profile');
}

// ── Auth ────────────────────────────────────────────────
async function doLogin() {
  const email = document.getElementById('login-email').value.trim();
  const pass = document.getElementById('login-password').value;
  const errEl = document.getElementById('login-error');
  errEl.style.display = 'none';
  try {
    const res = await api.login(email, pass);
    setToken(res.access_token);
    currentUser = await api.getMe();
    if (!currentUser.onboarding_complete) {
      initQuiz();
      showPage('page-quiz');
    } else {
      showPage('page-app');
    }
  } catch (e) {
    errEl.textContent = e.message;
    errEl.style.display = 'block';
  }
}

async function doSignup() {
  const name = document.getElementById('signup-name').value.trim();
  const email = document.getElementById('signup-email').value.trim();
  const pass = document.getElementById('signup-password').value;
  const errEl = document.getElementById('signup-error');
  errEl.style.display = 'none';
  try {
    const res = await api.signup(email, name, pass);
    setToken(res.access_token);
    currentUser = await api.getMe();
    initQuiz();
    showPage('page-quiz');
  } catch (e) {
    errEl.textContent = e.message;
    errEl.style.display = 'block';
  }
}

function doLogout() {
  clearToken();
  currentUser = null;
  styleProfile = null;
  showPage('page-login');
}

// ── Auto-login ──────────────────────────────────────────
window.addEventListener('load', async () => {
  const token = getToken();
  if (!token) return;
  try {
    apiRequest; // ensure api.js loaded
    currentUser = await api.getMe();
    if (!currentUser.onboarding_complete) {
      initQuiz(); showPage('page-quiz');
    } else {
      showPage('page-app');
    }
  } catch (_) { clearToken(); }
});

// ── Quiz ────────────────────────────────────────────────
const OUTFITS = [
  { id: 't1', emoji: '🤍', style: 'Minimalist', desc: 'White tee, tailored trousers, white sneakers' },
  { id: 't2', emoji: '🎿', style: 'Old Money', desc: 'Polo shirt, chinos, loafers' },
  { id: 't3', emoji: '🖤', style: 'Streetwear', desc: 'Graphic hoodie, cargo pants, chunky sneakers' },
  { id: 't4', emoji: '🎩', style: 'Formal', desc: 'Slim suit, dress shirt, Oxford shoes' },
  { id: 't5', emoji: '🏃', style: 'Athleisure', desc: 'Track jacket, joggers, clean sneakers' },
  { id: 't6', emoji: '🌻', style: 'Vintage', desc: 'Denim jacket, mom jeans, retro sneakers' },
];
const COLORS = ['white','black','grey','navy','beige','brown','blue','red','green','yellow','pink','purple','olive','camel','burgundy'];
const GOALS = ['Look More Professional','Build Confidence','Dress Better For College','Build a Capsule Wardrobe','Event Styling','Express Personal Style'];

function initQuiz() { quizStep = 0; renderQuizStep(); }

function renderQuizStep() {
  const steps = ['Visual Style', 'Lifestyle', 'Budget', 'Colors', 'Fit', 'Goals'];
  document.getElementById('quiz-step-label').textContent = `Step ${quizStep + 1} of 6 — ${steps[quizStep]}`;
  document.getElementById('quiz-progress').style.width = `${((quizStep + 1) / 6) * 100}%`;
  document.getElementById('quiz-back').style.display = quizStep > 0 ? 'block' : 'none';
  document.getElementById('quiz-next').textContent = quizStep === 5 ? 'Finish' : 'Next';

  const body = document.getElementById('quiz-body');
  body.innerHTML = '';

  if (quizStep === 0) {
    body.innerHTML = `<div class="section-title">Rate each outfit</div>` +
      OUTFITS.map(o => `
        <div class="outfit-rate-card">
          <div class="rate-emoji">${o.emoji}</div>
          <div style="flex:1">
            <div style="font-weight:600;font-size:14px">${o.style}</div>
            <div style="font-size:11px;color:var(--muted)">${o.desc}</div>
          </div>
          <div class="rate-buttons">
            <button class="rate-btn" style="background:#fee2e2" onclick="rateOutfit('${o.id}',-1,this)">✕</button>
            <button class="rate-btn" style="background:#fef3c7" onclick="rateOutfit('${o.id}',0,this)">〜</button>
            <button class="rate-btn" style="background:#d1fae5" onclick="rateOutfit('${o.id}',1,this)">♥</button>
          </div>
        </div>`).join('');

  } else if (quizStep === 1) {
    body.innerHTML = `
      <div class="form-group"><label>I am a</label>
        <select class="form-control" onchange="quizData.lifestyle=this.value">
          <option value="student">Student</option><option value="professional">Working Professional</option>
        </select></div>
      <div class="form-group"><label>Social events</label>
        <select class="form-control" onchange="quizData.social_frequency=this.value">
          <option value="rarely">Rarely</option><option value="occasionally" selected>Occasionally</option><option value="frequently">Frequently</option>
        </select></div>
      <div class="form-group"><label>Daily environment</label>
        <select class="form-control" onchange="quizData.daily_environment=this.value">
          <option value="campus">Campus</option><option value="office">Office</option><option value="home">Work from Home</option><option value="mixed">Mixed</option>
        </select></div>
      <div class="form-group"><label>Fashion importance: <span id="imp-val">3</span>/5</label>
        <input type="range" min="1" max="5" value="3" style="width:100%;margin-top:8px" oninput="quizData.fashion_importance=+this.value;document.getElementById('imp-val').textContent=this.value">
      </div>`;

  } else if (quizStep === 2) {
    body.innerHTML = `<div class="section-title">Shopping Budget</div>` +
      [['low','Budget Friendly','Under $30 per item','💰'],
       ['medium','Mid Range','$30–$100 per item','🛍️'],
       ['high','Premium','Over $100 per item','💎']].map(([val,title,sub,ico]) => `
        <div class="card" style="cursor:pointer;border:2px solid ${quizData.budget_range===val?'var(--primary)':'var(--border)'};margin-bottom:10px" onclick="selectBudget('${val}',this)">
          <div style="display:flex;align-items:center;gap:14px">
            <span style="font-size:28px">${ico}</span>
            <div><div style="font-weight:600">${title}</div><div style="font-size:12px;color:var(--muted)">${sub}</div></div>
          </div>
        </div>`).join('');

  } else if (quizStep === 3) {
    body.innerHTML = `
      <div class="section-title">Favorite Colors</div>
      <div class="color-grid" id="fav-colors">
        ${COLORS.map(c => `<div class="color-dot" title="${c}" style="background:${c};border:2px solid #ccc" onclick="toggleColor(this,'fav','${c}')"></div>`).join('')}
      </div>
      <div class="section-title" style="margin-top:20px">Colors You Avoid</div>
      <div class="color-grid" id="avoid-colors">
        ${COLORS.map(c => `<div class="color-dot" title="${c}" style="background:${c};border:2px solid #ccc" onclick="toggleColor(this,'avoid','${c}')"></div>`).join('')}
      </div>`;

  } else if (quizStep === 4) {
    body.innerHTML = `<div class="section-title">Fit Preference</div>` +
      [['slim','Slim Fit','Close to the body'],
       ['regular','Regular Fit','Classic comfortable cut'],
       ['relaxed','Relaxed Fit','Loose and comfortable'],
       ['oversized','Oversized','Big and boxy']].map(([val,title,sub]) => `
        <div class="card" style="cursor:pointer;border:2px solid ${quizData.fit_preference===val?'var(--primary)':'var(--border)'};margin-bottom:10px" onclick="selectFit('${val}',this)">
          <div style="font-weight:600">${title}</div><div style="font-size:12px;color:var(--muted)">${sub}</div>
        </div>`).join('');

  } else if (quizStep === 5) {
    body.innerHTML = `<div class="section-title">Fashion Goals</div><div class="section-title" style="font-size:12px;font-weight:400;color:var(--muted)">Select all that apply</div>` +
      GOALS.map(g => `
        <label style="display:flex;align-items:center;gap:12px;background:white;padding:14px;border-radius:12px;margin-bottom:8px;cursor:pointer">
          <input type="checkbox" onchange="toggleGoal('${g}',this.checked)" ${quizData.fashion_goals.includes(g)?'checked':''}>
          <span style="font-size:14px">${g}</span>
        </label>`).join('');
  }
}

function rateOutfit(id, val, btn) {
  quizData.outfit_ratings[id] = val;
  const parent = btn.closest('.rate-buttons');
  parent.querySelectorAll('.rate-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
}
function selectBudget(val, el) {
  quizData.budget_range = val;
  document.querySelectorAll('#quiz-body .card').forEach(c => c.style.borderColor = 'var(--border)');
  el.style.borderColor = 'var(--primary)';
}
function selectFit(val, el) {
  quizData.fit_preference = val;
  document.querySelectorAll('#quiz-body .card').forEach(c => c.style.borderColor = 'var(--border)');
  el.style.borderColor = 'var(--primary)';
}
function toggleColor(el, type, color) {
  if (type === 'fav') {
    const i = quizData.favorite_colors.indexOf(color);
    if (i >= 0) { quizData.favorite_colors.splice(i,1); el.classList.remove('selected'); }
    else { quizData.favorite_colors.push(color); el.classList.add('selected'); }
  } else {
    const i = quizData.avoided_colors.indexOf(color);
    if (i >= 0) { quizData.avoided_colors.splice(i,1); el.classList.remove('selected'); }
    else { quizData.avoided_colors.push(color); el.classList.add('selected'); }
  }
}
function toggleGoal(goal, checked) {
  if (checked) quizData.fashion_goals.push(goal);
  else quizData.fashion_goals = quizData.fashion_goals.filter(g => g !== goal);
}

function quizBack() { if (quizStep > 0) { quizStep--; renderQuizStep(); } }
async function quizNext() {
  if (quizStep < 5) { quizStep++; renderQuizStep(); return; }
  const btn = document.getElementById('quiz-next');
  btn.disabled = true; btn.textContent = 'Saving...';
  try {
    await api.submitQuiz(quizData);
    currentUser = await api.getMe();
    showPage('page-app');
  } catch (e) {
    alert('Error: ' + e.message);
    btn.disabled = false; btn.textContent = 'Finish';
  }
}

// ── App Init ────────────────────────────────────────────
async function initApp() {
  if (!currentUser) return;
  document.getElementById('home-greeting').textContent = `Hi, ${currentUser.full_name.split(' ')[0]} 👋`;
  loadWeather();
  try { styleProfile = await api.getProfile(); renderDNASnapshot(); } catch(_) {}
}

async function loadWeather() {
  try {
    const w = await api.getWeather('London');
    const emojis = { Clear:'☀️', Clouds:'⛅', Rain:'🌧️', Snow:'❄️', Thunderstorm:'⛈️' };
    const emoji = emojis[w.condition] || '🌤️';
    document.getElementById('home-weather').innerHTML = `
      <div class="weather-card">
        <div class="weather-emoji">${emoji}</div>
        <div>
          <div class="temp">${Math.round(w.temperature)}°C</div>
          <div class="desc">${w.condition} · ${w.city}</div>
          <div style="font-size:12px;opacity:.8;margin-top:4px">💧 ${w.humidity}% · 💨 ${w.wind_speed}m/s</div>
        </div>
      </div>`;
  } catch(_) {}
}

function renderDNASnapshot() {
  if (!styleProfile) return;
  const dominant = (styleProfile.dominant_style || '').replace('_',' ').toUpperCase();
  document.getElementById('home-dna').innerHTML = `
    <div class="card">
      <div class="section-title">✨ Your Style DNA</div>
      <div style="color:var(--primary);font-weight:700;font-size:18px;margin-bottom:8px">${dominant || 'Not set'}</div>
      ${styleProfile.favorite_colors.length ? `<div>${styleProfile.favorite_colors.slice(0,5).map(c=>`<span class="tag">${c}</span>`).join('')}</div>` : ''}
    </div>`;
}

// ── Recommendation ──────────────────────────────────────
async function getRecommendation() {
  const occasion = document.getElementById('home-occasion').value;
  const el = document.getElementById('home-outfit');
  el.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    const rec = await api.getRecommendation(occasion, 'London');
    renderOutfitCard(el, rec);
  } catch(e) {
    el.innerHTML = `<div class="alert alert-error">${e.message}</div>`;
  }
}

function categoryEmoji(cat) {
  return { tops:'👕', bottoms:'👖', footwear:'👟', accessories:'⌚', outerwear:'🧥' }[cat] || '👔';
}

function renderOutfitCard(el, rec) {
  const items = ['top','bottom','footwear','accessory','outerwear'].filter(k => rec[k]);
  const pct = Math.round(rec.confidence_score * 100);
  const confClass = pct >= 70 ? 'conf-high' : pct >= 40 ? 'conf-mid' : 'conf-low';
  el.innerHTML = `
    <div class="outfit-card">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
        <span style="font-size:11px;font-weight:700;letter-spacing:1px;color:var(--primary)">${rec.occasion.toUpperCase()}</span>
        <span class="confidence ${confClass}">${pct}% match</span>
      </div>
      <div class="outfit-items">
        ${items.map(k => `<div class="outfit-item"><span class="emoji">${categoryEmoji(rec[k].category)}</span>${rec[k].name}</div>`).join('')}
      </div>
      <div class="explanation">
        💡 ${rec.explanation.summary || 'A well-matched outfit for your style.'}
      </div>
      ${rec.explanation.reasons ? `<ul style="margin-top:10px;padding-left:18px;font-size:12px;color:var(--muted)">${rec.explanation.reasons.map(r=>`<li style="margin-bottom:4px">${r}</li>`).join('')}</ul>` : ''}
    </div>`;
}

// ── Discover ────────────────────────────────────────────
async function loadDiscover() {
  const body = document.getElementById('discover-body');
  if (tinderOutfits.length === 0) {
    try {
      tinderOutfits = await api.getTinderOutfits();
      tinderIndex = 0;
    } catch(e) {
      body.innerHTML = `<div class="alert alert-error">${e.message}</div>`; return;
    }
  }
  renderTinder();
}

function renderTinder() {
  const body = document.getElementById('discover-body');
  if (tinderIndex >= tinderOutfits.length) {
    body.innerHTML = `<div class="empty-state"><div class="icon">🎉</div><h3>All caught up!</h3><p>Your style AI has been updated.</p><br><button class="btn btn-primary" onclick="tinderIndex=0;renderTinder()">See again</button></div>`;
    return;
  }
  const o = tinderOutfits[tinderIndex];
  const remaining = tinderOutfits.length - tinderIndex;
  body.innerHTML = `
    <div style="margin-bottom:8px;font-size:13px;color:var(--muted);text-align:center">${remaining} outfits left</div>
    <div style="background:var(--border);border-radius:4px;height:4px;margin-bottom:16px">
      <div style="background:var(--primary);height:4px;border-radius:4px;width:${(tinderIndex/tinderOutfits.length)*100}%"></div>
    </div>
    <div class="tinder-card">
      <div class="tinder-emoji">${o.image_placeholder}</div>
      <div class="tinder-style">${o.style}</div>
      <div class="tinder-desc">${o.description}</div>
      <div style="margin-top:12px">${o.colors.map(c=>`<span class="tag">${c}</span>`).join('')}</div>
      <div style="margin-top:8px;opacity:.7;font-size:12px">${o.occasion}</div>
    </div>
    <div class="swipe-buttons">
      <div style="text-align:center">
        <button class="swipe-btn btn-nope" onclick="doSwipe('dislike')">✕</button>
        <div style="font-size:11px;margin-top:4px;color:var(--muted)">Nope</div>
      </div>
      <div style="text-align:center">
        <button class="swipe-btn btn-save" onclick="doSwipe('save')">🔖</button>
        <div style="font-size:11px;margin-top:4px;color:var(--muted)">Save</div>
      </div>
      <div style="text-align:center">
        <button class="swipe-btn btn-like" onclick="doSwipe('like')">♥</button>
        <div style="font-size:11px;margin-top:4px;color:var(--muted)">Love it</div>
      </div>
    </div>`;
}

async function doSwipe(pref) {
  const o = tinderOutfits[tinderIndex];
  try { await api.swipe(o.id, pref, { style: o.style, colors: o.colors }); } catch(_) {}
  tinderIndex++;
  renderTinder();
}

// ── Chat ────────────────────────────────────────────────
async function loadChatHistory() {
  try {
    const msgs = await api.getChatHistory();
    const el = document.getElementById('chat-messages');
    if (msgs.length === 0) {
      el.innerHTML = `<div class="empty-state"><div class="icon">💬</div><h3>Your AI Stylist</h3><p>Ask me anything about fashion, style, or outfits.</p>
        <div style="margin-top:20px;text-align:left">
          ${['What should I wear to an interview?','How do I style navy chinos?','Suggest a date night outfit'].map(s=>`<button onclick="document.getElementById('chat-input').value='${s}'" style="display:block;width:100%;text-align:left;padding:10px 14px;background:white;border:1.5px solid var(--border);border-radius:10px;margin-bottom:8px;cursor:pointer;font-size:13px">${s}</button>`).join('')}
        </div></div>`;
      return;
    }
    el.innerHTML = msgs.map(m => renderMsg(m.role, m.content)).join('');
    el.scrollTop = el.scrollHeight;
  } catch(_) {}
}

function renderMsg(role, content) {
  return `<div class="msg msg-${role === 'user' ? 'user' : 'ai'}">
    <div class="msg-bubble">${content.replace(/\n/g,'<br>')}</div>
  </div>`;
}

async function sendChat() {
  const input = document.getElementById('chat-input');
  const content = input.value.trim();
  if (!content) return;
  input.value = '';
  const el = document.getElementById('chat-messages');
  el.innerHTML += renderMsg('user', content);
  el.innerHTML += `<div class="msg msg-ai" id="typing"><div class="msg-bubble" style="color:var(--muted)">✨ Thinking...</div></div>`;
  el.scrollTop = el.scrollHeight;
  try {
    const res = await api.sendMessage(content);
    document.getElementById('typing').remove();
    el.innerHTML += renderMsg('assistant', res.assistant_message.content);
    el.scrollTop = el.scrollHeight;
  } catch(e) {
    document.getElementById('typing').remove();
    el.innerHTML += renderMsg('assistant', 'Sorry, something went wrong. Try again.');
  }
}

async function clearChat() {
  try { await api.clearChat(); } catch(_) {}
  document.getElementById('chat-messages').innerHTML = '';
  loadChatHistory();
}

// ── Wardrobe ────────────────────────────────────────────
async function loadWardrobe(category = '', search = '') {
  const grid = document.getElementById('wardrobe-grid');
  grid.innerHTML = '<div class="loading" style="grid-column:span 2"><div class="spinner"></div></div>';
  try {
    wardrobeItems = await api.getWardrobe(category, search);
    document.getElementById('wardrobe-count').textContent = `${wardrobeItems.length} items`;
    if (wardrobeItems.length === 0) {
      grid.innerHTML = `<div class="empty-state" style="grid-column:span 2"><div class="icon">👕</div><p>No items yet. Add your first item!</p></div>`;
      return;
    }
    grid.innerHTML = wardrobeItems.map(item => `
      <div class="wardrobe-item-card">
        <button class="delete-btn" onclick="deleteItem(${item.id})">✕</button>
        <div class="cat-emoji">${categoryEmoji(item.category)}</div>
        <h4>${item.name}</h4>
        <p style="text-transform:capitalize">${item.category}</p>
        <p>${item.primary_color}</p>
        ${item.style_tags.length ? `<div style="margin-top:6px">${item.style_tags.slice(0,2).map(t=>`<span class="tag">${t}</span>`).join('')}</div>` : ''}
      </div>`).join('');
  } catch(e) {
    grid.innerHTML = `<div class="alert alert-error" style="grid-column:span 2">${e.message}</div>`;
  }
}

let currentCategory = '';
function filterWardrobe(cat) {
  currentCategory = cat;
  document.querySelectorAll('.cat-tab').forEach(t => {
    t.classList.toggle('active', t.dataset.cat === cat);
  });
  loadWardrobe(cat);
}

let searchTimeout;
function searchWardrobe(val) {
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => loadWardrobe(currentCategory, val), 300);
}

async function deleteItem(id) {
  if (!confirm('Remove this item from your wardrobe?')) return;
  try {
    await api.deleteItem(id);
    loadWardrobe(currentCategory);
  } catch(e) { alert(e.message); }
}

function toggleChip(el, type) {
  el.classList.toggle('selected');
}

function openAddItemModal() {
  document.querySelectorAll('#modal-add-item .chip').forEach(c => c.classList.remove('selected'));
  document.getElementById('item-name').value = '';
  document.getElementById('modal-add-item').classList.add('open');
}

async function submitAddItem() {
  const name = document.getElementById('item-name').value.trim();
  if (!name) { alert('Item name is required'); return; }
  const styleTags = [...document.querySelectorAll('#item-style-tags .chip.selected')].map(c => c.textContent);
  const occasionTags = [...document.querySelectorAll('#item-occasion-tags .chip.selected')].map(c => c.textContent);
  const seasonTags = [...document.querySelectorAll('#item-season-tags .chip.selected')].map(c => c.textContent);
  try {
    await api.addItem({
      name,
      category: document.getElementById('item-category').value,
      primary_color: document.getElementById('item-color').value,
      style_tags: styleTags,
      occasion_tags: occasionTags,
      season_tags: seasonTags,
      brand: '', notes: ''
    });
    closeModal('modal-add-item');
    loadWardrobe(currentCategory);
  } catch(e) { alert(e.message); }
}

// ── Calendar ────────────────────────────────────────────
async function loadCalendar() {
  const el = document.getElementById('calendar-events');
  el.innerHTML = '<div class="loading"><div class="spinner"></div></div>';
  try {
    const events = await api.getEvents();
    if (events.length === 0) {
      el.innerHTML = `<div class="empty-state"><div class="icon">📅</div><p>No events yet. Plan your first event!</p></div>`;
      return;
    }
    const eventEmojis = { interview:'💼', wedding:'💒', party:'🎉', vacation:'✈️', date:'❤️', presentation:'📊', casual:'😊', work:'🏢' };
    el.innerHTML = events.map(ev => {
      const date = new Date(ev.event_date);
      const days = Math.ceil((date - Date.now()) / 86400000);
      const daysText = days === 0 ? 'Today' : days === 1 ? 'Tomorrow' : `${days}d`;
      const urgent = days <= 1;
      return `<div class="event-card">
        <div class="event-icon">${eventEmojis[ev.event_type] || '📅'}</div>
        <div class="event-info">
          <h4>${ev.title}</h4>
          <p>${date.toLocaleDateString('en-IN', { day:'numeric', month:'short', year:'numeric' })}</p>
          ${ev.location ? `<p>📍 ${ev.location}</p>` : ''}
          ${ev.outfit_generated ? `<span style="font-size:11px;color:var(--success)">✅ Outfit ready</span>` :
            `<button onclick="genEventOutfit(${ev.id},this)" style="font-size:11px;background:none;border:none;color:var(--primary);cursor:pointer;padding:0;margin-top:2px;font-weight:600">Get Outfit →</button>`}
        </div>
        <div class="days-badge ${urgent?'urgent':''}">
          <div style="font-size:16px;font-weight:700">${daysText}</div>
          <button onclick="deleteEventItem(${ev.id})" style="font-size:10px;background:none;border:none;color:var(--muted);cursor:pointer;margin-top:4px">Remove</button>
        </div>
      </div>`;
    }).join('');
  } catch(e) {
    el.innerHTML = `<div class="alert alert-error">${e.message}</div>`;
  }
}

async function genEventOutfit(id, btn) {
  btn.textContent = 'Generating...';
  btn.disabled = true;
  try {
    const res = await api.generateEventOutfit(id);
    alert('Outfit ready! ' + (res.explanation?.summary || ''));
    loadCalendar();
  } catch(e) {
    alert(e.message);
    btn.textContent = 'Get Outfit →';
    btn.disabled = false;
  }
}

async function deleteEventItem(id) {
  if (!confirm('Remove this event?')) return;
  try { await api.deleteEvent(id); loadCalendar(); } catch(e) { alert(e.message); }
}

function openAddEventModal() {
  document.getElementById('event-title').value = '';
  document.getElementById('event-location').value = '';
  const d = new Date(); d.setDate(d.getDate() + 7);
  document.getElementById('event-date').value = d.toISOString().slice(0,16);
  document.getElementById('modal-add-event').classList.add('open');
}

async function submitAddEvent() {
  const title = document.getElementById('event-title').value.trim();
  if (!title) { alert('Title is required'); return; }
  try {
    await api.createEvent({
      title,
      event_type: document.getElementById('event-type').value,
      event_date: new Date(document.getElementById('event-date').value).toISOString(),
      location: document.getElementById('event-location').value.trim(),
      notes: ''
    });
    closeModal('modal-add-event');
    loadCalendar();
  } catch(e) { alert(e.message); }
}

// ── Profile ─────────────────────────────────────────────
async function loadProfile() {
  document.getElementById('profile-name').textContent = currentUser?.full_name || '';
  document.getElementById('profile-email').textContent = currentUser?.email || '';
  document.getElementById('profile-avatar').textContent = (currentUser?.full_name?.[0] || '?').toUpperCase();

  try {
    const profile = await api.getProfile();
    styleProfile = profile;
    const scores = [
      ['Minimalist', profile.minimalist_score],
      ['Old Money', profile.old_money_score],
      ['Smart Casual', profile.smart_casual_score],
      ['Streetwear', profile.streetwear_score],
      ['Formal', profile.formal_score],
      ['Athleisure', profile.athleisure_score],
      ['Vintage', profile.vintage_score],
    ].filter(([,v]) => v > 0).sort((a,b) => b[1]-a[1]);

    document.getElementById('profile-dna').innerHTML = `
      <div style="color:var(--primary);font-weight:700;font-size:18px;margin-bottom:16px">${(profile.dominant_style||'').replace('_',' ').toUpperCase()}</div>
      ${scores.map(([label, val]) => `
        <div class="dna-bar">
          <label>${label}</label>
          <div class="bar-track"><div class="bar-fill" style="width:${val*100}%"></div></div>
          <span class="pct">${Math.round(val*100)}%</span>
        </div>`).join('')}
      ${profile.favorite_colors.length ? `<div style="margin-top:12px"><strong style="font-size:12px">Favorite Colors: </strong>${profile.favorite_colors.map(c=>`<span class="tag">${c}</span>`).join('')}</div>` : ''}
      <div style="margin-top:8px;font-size:12px;color:var(--muted)">Budget: ${profile.budget_range} · Fit: ${profile.fit_preference}</div>`;
  } catch(_) {
    document.getElementById('profile-dna').innerHTML = '<p style="color:var(--muted)">Complete the style quiz to see your DNA.</p>';
  }

  try {
    const evo = await api.getEvolution();
    document.getElementById('profile-evolution').innerHTML = evo.monthly_insights.length
      ? evo.monthly_insights.map(i => `<p style="margin-bottom:8px;font-size:13px">✨ ${i}</p>`).join('')
      : '<p style="color:var(--muted);font-size:13px">Like more outfits to see your style evolution.</p>';
  } catch(_) {}

  try {
    const insights = await api.getInsights();
    document.getElementById('profile-insights').innerHTML = insights.length
      ? insights.map(ins => `
          <div class="card insights-card" style="margin-bottom:10px">
            <div style="font-weight:600;font-size:14px">🛍️ ${ins.recommendation}</div>
            <div style="font-size:12px;color:var(--muted);margin-top:4px">${ins.reason}</div>
            <div style="font-size:11px;margin-top:6px;color:var(--accent);font-weight:600">${ins.priority.toUpperCase()} PRIORITY</div>
          </div>`).join('')
      : '<p style="color:var(--muted);font-size:13px">Add more wardrobe items to get shopping insights.</p>';
  } catch(_) {}
}

// ── Utils ────────────────────────────────────────────────
function closeModal(id) {
  document.getElementById(id).classList.remove('open');
}
document.addEventListener('click', e => {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('open');
  }
});
