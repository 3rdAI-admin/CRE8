"""Daily Quote Flask application."""

import os

import requests
from dotenv import load_dotenv
from flask import Flask, jsonify, render_template, request

from quotes import get_all_categories, get_random_quote

load_dotenv()

app = Flask(__name__)

UNSPLASH_ACCESS_KEY = os.environ.get("UNSPLASH_ACCESS_KEY")

# Category-specific default images when no API key (Picsum seed = stable, working image per category)
_PICSUM = "https://picsum.photos/seed"
DEFAULT_IMAGES = {
    "motivation": f"{_PICSUM}/motivation/1920/1080",
    "success": f"{_PICSUM}/success/1920/1080",
    "wisdom": f"{_PICSUM}/wisdom/1920/1080",
    "life": f"{_PICSUM}/life/1920/1080",
    "ai": f"{_PICSUM}/artificial-intelligence/1920/1080",
}
DEFAULT_IMAGE = f"{_PICSUM}/inspiration/1920/1080"


def _search_query_for_category(category: str) -> str:
    """Return a richer Unsplash search query for the category."""
    queries = {
        "motivation": "determination achievement mountain",
        "success": "success celebration achievement",
        "wisdom": "wisdom philosophy books nature",
        "life": "life journey sunset nature",
        "ai": "artificial intelligence technology robot",
    }
    return queries.get(category, "inspiration nature")


def fetch_unsplash_image(category: str) -> str:
    """Fetch a random Unsplash photo relevant to the quote category. Use category-specific default if no API key."""
    fallback = (
        DEFAULT_IMAGES.get(category, DEFAULT_IMAGE) if category else DEFAULT_IMAGE
    )
    if not UNSPLASH_ACCESS_KEY:
        return fallback
    try:
        url = "https://api.unsplash.com/photos/random"
        params = {
            "client_id": UNSPLASH_ACCESS_KEY,
            "query": _search_query_for_category(category),
            "orientation": "landscape",
        }
        resp = requests.get(url, params=params, timeout=5)
        resp.raise_for_status()
        data = resp.json()
        urls = data.get("urls") or {}
        raw = urls.get("regular") or urls.get("full") or urls.get("raw")
        return (raw or "").strip() or fallback
    except Exception:
        return fallback


@app.route("/")
def index():
    """Serve the main page."""
    return render_template("index.html", categories=get_all_categories())


@app.route("/api/quote")
def api_quote():
    """Return a random quote as JSON, optionally filtered by category."""
    category = request.args.get("category")
    quote = get_random_quote(category)
    if not quote:
        return jsonify({"error": "No quote found"}), 404
    category = quote.get("category") or "life"
    image_url = fetch_unsplash_image(category) or DEFAULT_IMAGE
    return jsonify(
        {
            "quote": quote["text"],
            "author": quote["author"],
            "category": quote.get("category", ""),
            "image_url": image_url,
        }
    )


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5002))
    app.run(host="0.0.0.0", port=port, debug=True)
