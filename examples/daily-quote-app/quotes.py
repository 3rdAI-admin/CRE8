"""Quote data organized by category for the Daily Quote app."""

import random
from typing import Optional

QUOTES = {
    "motivation": [
        {
            "text": "The only way to do great work is to love what you do.",
            "author": "Steve Jobs",
        },
        {
            "text": "It does not matter how slowly you go as long as you do not stop.",
            "author": "Confucius",
        },
        {
            "text": "Everything you've ever wanted is on the other side of fear.",
            "author": "George Addair",
        },
        {
            "text": "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            "author": "Winston Churchill",
        },
        {
            "text": "The future belongs to those who believe in the beauty of their dreams.",
            "author": "Eleanor Roosevelt",
        },
    ],
    "success": [
        {
            "text": "The only place where success comes before work is in the dictionary.",
            "author": "Vidal Sassoon",
        },
        {
            "text": "Success usually comes to those who are too busy to be looking for it.",
            "author": "Henry David Thoreau",
        },
        {
            "text": "Don't be afraid to give up the good to go for the great.",
            "author": "John D. Rockefeller",
        },
        {
            "text": "I find that the harder I work, the more luck I seem to have.",
            "author": "Thomas Jefferson",
        },
        {
            "text": "Success is walking from failure to failure with no loss of enthusiasm.",
            "author": "Winston Churchill",
        },
    ],
    "wisdom": [
        {
            "text": "The only true wisdom is in knowing you know nothing.",
            "author": "Socrates",
        },
        {"text": "The unexamined life is not worth living.", "author": "Socrates"},
        {
            "text": "It is the mark of an educated mind to be able to entertain a thought without accepting it.",
            "author": "Aristotle",
        },
        {
            "text": "Wisdom is not a product of schooling but of the lifelong attempt to acquire it.",
            "author": "Albert Einstein",
        },
        {
            "text": "Knowing others is intelligence; knowing yourself is true wisdom.",
            "author": "Lao Tzu",
        },
    ],
    "life": [
        {
            "text": "In the end, it's not the years in your life that count. It's the life in your years.",
            "author": "Abraham Lincoln",
        },
        {
            "text": "Life is what happens when you're busy making other plans.",
            "author": "John Lennon",
        },
        {"text": "The purpose of our lives is to be happy.", "author": "Dalai Lama"},
        {"text": "Get busy living or get busy dying.", "author": "Stephen King"},
        {
            "text": "You only live once, but if you do it right, once is enough.",
            "author": "Mae West",
        },
    ],
    "ai": [
        {
            "text": "Artificial intelligence is the new electricity.",
            "author": "Andrew Ng",
        },
        {
            "text": "The development of full artificial intelligence could spell the end of the human race.",
            "author": "Stephen Hawking",
        },
        {
            "text": "AI is a fundamental risk to the existence of human civilization.",
            "author": "Elon Musk",
        },
        {
            "text": "Machine learning is the last invention that humanity will ever need to make.",
            "author": "Nick Bostrom",
        },
        {
            "text": "The question of whether a computer can think is no more interesting than the question of whether a submarine can swim.",
            "author": "Edsger W. Dijkstra",
        },
    ],
}


def get_random_quote(category: Optional[str] = None) -> Optional[dict]:
    """Return a random quote, optionally filtered by category."""
    if category and category.lower() in QUOTES:
        cat = category.lower()
        pool = [(q, cat) for q in QUOTES[cat]]
    else:
        pool = [(q, cat) for cat, quotes in QUOTES.items() for q in quotes]
    if not pool:
        return None
    quote, cat = random.choice(pool)
    return {**quote, "category": cat}


def get_all_categories() -> list[str]:
    """Return list of category keys."""
    return list(QUOTES.keys())
