# Daily Quote App – Sample INITIAL.md

> Copy this into your new project's `INITIAL.md` when following the [Getting Started tutorial](../../tutorials/getting-started-walkthrough.md).

---

## FEATURE:

Create a "Daily Quote" web application with Python Flask that:

- Displays inspirational quotes with beautiful background images (Unsplash when an API key is set; otherwise Picsum Photos)
- Shows the author's name with each quote
- Has categories (Motivation, Success, Wisdom, Life; optionally A.I.) that users can filter by
- Allows users to save favorite quotes (stored in browser localStorage)
- Includes a "New Quote" button to get another random quote
- Has a responsive design that works on mobile and desktop

**Core User Flows:**

1. User opens app → sees a random quote with relevant background image
2. User clicks category → sees quotes filtered to that category
3. User clicks heart icon → quote is saved to favorites
4. User clicks "Favorites" → sees all their saved quotes
5. User clicks "New Quote" → gets a different random quote

## EXAMPLES:

For Flask patterns, reference:

- Flask official quickstart: https://flask.palletsprojects.com/en/3.0.x/quickstart/
- Jinja2 templates: https://flask.palletsprojects.com/en/3.0.x/tutorial/templates/

## DOCUMENTATION:

- Flask documentation: https://flask.palletsprojects.com/en/3.0.x/
- Unsplash API: https://unsplash.com/documentation
- Unsplash API – Get random photo: https://unsplash.com/documentation#get-a-random-photo
- Picsum Photos (fallback): https://picsum.photos/
- Python requests library: https://docs.python-requests.org/en/latest/
- localStorage JavaScript API: https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage

## OTHER CONSIDERATIONS:

### Unsplash API Setup (optional)

- Requires free Unsplash developer account at https://unsplash.com/developers
- API key should be stored in `.env` file, never hardcoded
- Use `python-dotenv` to load environment variables
- Free tier allows 50 requests/hour – sufficient for demo
- **If no API key:** Use Picsum Photos for background images so the app still works

### Project Structure

```
daily-quote-app/
├── app.py              # Flask application
├── templates/
│   └── index.html      # Main page template
├── static/
│   ├── style.css       # Styles
│   └── app.js          # Frontend JavaScript
├── quotes.py           # Quote data organized by category
├── .env                # API keys (not in git)
├── .env.example        # Template for .env
└── requirements.txt    # Python dependencies
```

### Quote Categories

Include at least 5 quotes per category:

- **Motivation:** Quotes about taking action and pushing forward
- **Success:** Quotes about achievement and perseverance
- **Wisdom:** Timeless philosophical quotes
- **Life:** Quotes about living fully and finding meaning
- **A.I. (optional):** Quotes about artificial intelligence; display label as "A.I." in the UI

### UI/UX Requirements

- Full-screen background image that changes with each quote
- Quote text readable over any image (text shadow or overlay)
- Smooth fade transition when changing quotes
- Heart icon that fills when quote is favorited
- Category pills/buttons at the top
- Mobile-first responsive design

### Technical Notes

- Use Flask's `render_template` for the main page
- Create a `/api/quote` endpoint that returns JSON for AJAX requests
- Use `/api/quote?category=motivation` for filtered quotes
- Favorites are client-side only (localStorage) – no database needed
- Include proper error handling for Unsplash API failures (fallback to Picsum or default image)
