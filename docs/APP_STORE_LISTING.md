# App Store listing — Mindkeep

Copy-paste into App Store Connect. Character counts verified against Apple's
limits; do not lengthen without re-checking.

---

## Name (limit 30)
```
Mindkeep: Expiry Reminders
```
Do not shorten this back to "Mindkeep". Two apps already hold that token
on the store ("MindKeep Pro" and "MindKeep: Private AI"), and App Store
Connect rejects the bare word. Apple checks the whole name string, not
the first word, which is why those two coexist and why the qualifier
clears it. The home-screen name (`CFBundleDisplayName`) stays plain
"Mindkeep" — the qualifier only exists in the store listing.

## Subtitle (limit 30)
```
A second memory for daily life
```

## Promotional text (limit 170 — editable any time without a new build)
```
Save a photo, document, date or thought. Mindkeep finds what matters and reminds you when you need it.
```

## Keywords (limit 100, comma-separated, no spaces)
```
renewal,passport,insurance,warranty,document,deadline,subscription,trial,scan,expire,visa,license
```
97/100. Deliberately excludes "reminder", "memory", "expiry" and
"Mindkeep" — Apple already indexes the app name and subtitle, so
repeating those words wastes characters that could cover a search you
don't otherwise rank for. "expiry" and "remind" were dropped when the
name changed to "Mindkeep: Expiry Reminders", which freed the room for
"visa" and "license".

## Description (limit 4000)
```
Some things you only need to remember once — and exactly once, months later, on the right day.

A passport that expires. An insurance renewal. The last day to return something. A free trial that quietly becomes a paid subscription. The blue box in the wardrobe where you put the spare key.

Mindkeep is where those go.


CAPTURE IN SECONDS

Photograph a document, pick a screenshot you already have, or just type it. That is the whole interaction.


IT READS THE DATES FOR YOU

Mindkeep reads the text on your document and shows you the dates it found. If a date could be read two ways — is 03/04/2026 the third of April or the fourth of March? — it shows you both and lets you choose. It never guesses, and it never quietly decides for you.


YOU CONFIRM, THEN FORGET IT

Nothing is saved until you have looked at it. Choose when you want to be reminded — 30 days before, 7 days, the day before — and then put it out of your mind. That is the entire point.


CALM BY DESIGN

No streaks. No badges. No list of things you are failing to do. Mindkeep stays quiet until something actually needs you, and tells you plainly when a reminder is too soon to set.


YOUR DOCUMENTS STAY YOURS

Everything lives in an encrypted database on your iPhone. Your documents are read on your device. There is no account to create, no server, and nothing is uploaded anywhere. Delete the app and it is all gone — because it was only ever on your phone.


FREE AND PREMIUM

Free includes every feature: photo capture, document reading, and all your reminders, for up to 10 saved memories.

Premium removes the limit.

Anything you have already saved stays readable whether or not you subscribe. Your own passport expiry is never held behind a payment.
```

## URLs
- **Privacy Policy URL** (required): `https://dleventis.github.io/KeepMind/privacy.html`
  — **enable GitHub Pages first** (repo Settings → Pages → Deploy from a branch → `main`, `/docs`) or this 404s and review will reject.
- **Support URL** (required): a page or even a mailto-style contact page. The
  GitHub repo URL works if the repo is public.
- **Marketing URL**: optional, leave blank.

## Age rating
4+ — no objectionable content, no user-generated content shared between users,
no web browsing.

## App Privacy ("nutrition label")
Answer **"Data Not Collected"**. Mindkeep has no analytics, no tracking, no
account, and no server. RevenueCat receives an anonymous install identifier and
purchase status, which is disclosed in the privacy policy; if App Store Connect
asks about purchase data, declare **Purchases → not linked to identity, not
used for tracking**.

## Notes on accuracy

The description deliberately does **not** claim artificial intelligence.
Date-finding is deterministic pattern matching running on the device (see
docs/DECISIONS.md ADR-0006). Claiming AI would be untrue today, and
unsubstantiated claims are a rejection risk as well as a credibility one.
Revisit this copy if and when Phase E/F ships real semantic extraction.
