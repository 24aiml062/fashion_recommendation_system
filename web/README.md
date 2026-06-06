# Fashion Copilot — Web Frontend

Plain HTML + CSS + JavaScript. No install, no build step, no Node.js needed.

## How to run

1. Make sure the backend is running:
   ```
   cd backend
   uvicorn app.main:app --reload --port 8000
   ```

2. Open `web/index.html` directly in Chrome.
   - Right-click the file → Open with → Chrome
   - Or drag it into Chrome

That's it. No server needed for the frontend.

## File structure

```
web/
├── index.html       ← All screens in one file
├── css/
│   └── style.css    ← All styles
└── js/
    ├── api.js       ← All API calls to backend
    └── app.js       ← All app logic
```

## Screens

- Login / Signup
- Style DNA Quiz (6 steps)
- Home — weather widget + outfit recommendation + quick actions
- Discover — Outfit Tinder (swipe to train style AI)
- AI Stylist — chat interface
- Wardrobe — add/view/delete items with category tabs
- Calendar — create events + generate outfits
- Profile — Style DNA bars + evolution + shopping insights

## Changing the backend URL

Open `web/js/api.js` and change line 1:
```js
const BASE_URL = 'http://localhost:8000';
```
Change to your deployed backend URL when ready.
