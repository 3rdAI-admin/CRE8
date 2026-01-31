const FAVORITES_KEY = 'daily-quote-favorites';

const bgEl = document.getElementById('bg');
const quoteText = document.getElementById('quote-text');
const authorEl = document.getElementById('author');
const heartBtn = document.getElementById('heart');
const newQuoteBtn = document.getElementById('new-quote');
const categoriesEl = document.getElementById('categories');
const favoritesBtn = document.getElementById('favorites-btn');
const quoteCard = document.getElementById('quote-card');
const favoritesView = document.getElementById('favorites-view');
const favoritesList = document.getElementById('favorites-list');
const backToQuoteBtn = document.getElementById('back-to-quote');

let currentCategory = '';

function getFavorites() {
  try {
    const raw = localStorage.getItem(FAVORITES_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function setFavorites(items) {
  localStorage.setItem(FAVORITES_KEY, JSON.stringify(items));
}

function isFavorite(quote, author) {
  return getFavorites().some(f => f.quote === quote && f.author === author);
}

function addFavorite(quote, author, category, imageUrl) {
  const fav = getFavorites();
  if (!fav.some(f => f.quote === quote && f.author === author)) {
    fav.push({ quote, author, category, imageUrl });
    setFavorites(fav);
  }
}

function removeFavorite(quote, author) {
  setFavorites(getFavorites().filter(f => !(f.quote === quote && f.author === author)));
}

function updateHeart(filled) {
  heartBtn.textContent = filled ? '♥' : '♡';
  heartBtn.classList.toggle('filled', filled);
}

async function fetchQuote(category = '') {
  const url = category
    ? `/api/quote?category=${encodeURIComponent(category)}`
    : '/api/quote';
  const res = await fetch(url);
  if (!res.ok) throw new Error('Failed to load quote');
  return res.json();
}

function showQuote(data) {
  quoteText.textContent = data.quote;
  authorEl.textContent = `— ${data.author}`;
  var imgUrl = (data.image_url && data.image_url.trim()) || 'https://picsum.photos/seed/inspiration/1920/1080';
  bgEl.style.backgroundImage = 'url(' + imgUrl + ')';
  bgEl.style.opacity = '1';
  updateHeart(isFavorite(data.quote, data.author));
  quoteCard.classList.remove('hidden');
  favoritesView.classList.add('hidden');
}

function renderFavorites() {
  const fav = getFavorites();
  favoritesList.innerHTML = fav.length === 0
    ? '<li>No favorites yet. Click the heart on a quote to save it.</li>'
    : fav.map(f => `
        <li>
          <strong>${escapeHtml(f.quote)}</strong>
          <span class="author">— ${escapeHtml(f.author)}</span>
        </li>
      `).join('');
}

function escapeHtml(s) {
  const div = document.createElement('div');
  div.textContent = s;
  return div.innerHTML;
}

async function loadQuote(category = '') {
  try {
    quoteText.textContent = 'Loading…';
    const data = await fetchQuote(category);
    showQuote(data);
  } catch {
    quoteText.textContent = 'Could not load quote. Try again.';
    authorEl.textContent = '—';
  }
}

categoriesEl.addEventListener('click', (e) => {
  const pill = e.target.closest('.pill');
  if (!pill || pill.id === 'favorites-btn') return;
  document.querySelectorAll('.pill').forEach(p => p.classList.remove('active'));
  pill.classList.add('active');
  currentCategory = pill.dataset.category || '';
  loadQuote(currentCategory);
});

favoritesBtn.addEventListener('click', () => {
  quoteCard.classList.add('hidden');
  favoritesView.classList.remove('hidden');
  renderFavorites();
  document.querySelectorAll('.pill').forEach(p => p.classList.remove('active'));
  favoritesBtn.classList.add('active');
});

backToQuoteBtn.addEventListener('click', () => {
  favoritesView.classList.add('hidden');
  quoteCard.classList.remove('hidden');
  favoritesBtn.classList.remove('active');
  document.querySelector('.pill[data-category="' + currentCategory + '"]')?.classList.add('active');
});

newQuoteBtn.addEventListener('click', () => loadQuote(currentCategory));

heartBtn.addEventListener('click', () => {
  const quote = quoteText.textContent;
  const author = authorEl.textContent.replace(/^—\s*/, '');
  if (!quote || quote === 'Loading…' || quote.startsWith('Could not')) return;
  const fav = isFavorite(quote, author);
  if (fav) {
    removeFavorite(quote, author);
    updateHeart(false);
  } else {
    const url = bgEl.style.backgroundImage?.slice(4, -1).replace(/"/g, '') || '';
    addFavorite(quote, author, currentCategory, url);
    updateHeart(true);
  }
});

loadQuote();
