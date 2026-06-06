const BASE_URL = 'http://localhost:8000';

function getToken() {
  return localStorage.getItem('token');
}

function setToken(token) {
  localStorage.setItem('token', token);
}

function clearToken() {
  localStorage.removeItem('token');
}

async function apiRequest(method, path, body = null) {
  const headers = { 'Content-Type': 'application/json' };
  const token = getToken();
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const options = { method, headers };
  if (body) options.body = JSON.stringify(body);

  const res = await fetch(BASE_URL + path, options);
  if (res.status === 204) return null;
  const data = await res.json();
  if (!res.ok) throw new Error(data.detail || 'Request failed');
  return data;
}

const api = {
  // Auth
  signup: (email, fullName, password) =>
    apiRequest('POST', '/auth/signup', { email, full_name: fullName, password }),
  login: (email, password) =>
    apiRequest('POST', '/auth/login', { email, password }),
  getMe: () => apiRequest('GET', '/auth/me'),

  // Style
  submitQuiz: (data) => apiRequest('POST', '/style/quiz', data),
  getProfile: () => apiRequest('GET', '/style/profile'),
  getTinderOutfits: () => apiRequest('GET', '/style/tinder/outfits'),
  swipe: (outfitId, preference, outfitData) =>
    apiRequest('POST', '/style/tinder/swipe', { outfit_id: outfitId, preference, outfit_data: outfitData }),
  getEvolution: () => apiRequest('GET', '/style/evolution'),

  // Wardrobe
  getWardrobe: (category = '', search = '') => {
    let path = '/wardrobe/?';
    if (category) path += `category=${category}&`;
    if (search) path += `search=${encodeURIComponent(search)}&`;
    return apiRequest('GET', path);
  },
  addItem: (data) => apiRequest('POST', '/wardrobe/', data),
  deleteItem: (id) => apiRequest('DELETE', `/wardrobe/${id}`),

  // Recommendations
  getRecommendation: (occasion, location) =>
    apiRequest('POST', '/recommendations/', { occasion, location }),
  getSaved: () => apiRequest('GET', '/recommendations/saved'),

  // Chat
  sendMessage: (content) => apiRequest('POST', '/chat/', { content }),
  getChatHistory: () => apiRequest('GET', '/chat/history'),
  clearChat: () => apiRequest('DELETE', '/chat/history'),

  // Weather
  getWeather: (city) => apiRequest('GET', `/weather/?city=${city}`),

  // Events
  getEvents: () => apiRequest('GET', '/events/'),
  createEvent: (data) => apiRequest('POST', '/events/', data),
  deleteEvent: (id) => apiRequest('DELETE', `/events/${id}`),
  generateEventOutfit: (id) => apiRequest('POST', `/events/${id}/outfit`),

  // Shopping
  getInsights: () => apiRequest('GET', '/shopping/insights'),
};
