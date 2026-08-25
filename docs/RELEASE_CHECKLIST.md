# Release checklist — Mindkeep 1.0

Target: live on the App Store before **30 September 2026, 11:45pm PDT**
(RevenueCat Shipaton deadline). Shipaton requires the app to be genuinely
live on a store *and* to make at least one real purchase through the
RevenueCat SDK, so step 3 is not optional polish — it is an entry
requirement.

Work top to bottom. Steps 2 and 3 have review/propagation delays measured
in hours to days, so start them before the parts that only need an
afternoon.

Fixed values, for copy-paste:

| Thing | Value |
|---|---|
| Bundle ID | `com.dleventis.keepmind` |
| Display name (on the home screen) | `Mindkeep` |
| App Store name | `Mindkeep: Expiry Reminders` |
| Version / build | `1.0.0` / `1` (from `app/pubspec.yaml`) |
| RevenueCat entitlement ID | `premium` |
| Build-time key define | `REVENUECAT_IOS_KEY` |
| Privacy policy URL | https://dleventis.github.io/KeepMind/privacy.html |

---

## 0. Push the local commits

Everything since the App Store listing commit is local-only. The sandbox
this repo is edited from has no outbound network, so run this yourself in
Terminal on the Mac:

```sh
cd ~/Developer/KeepMind
git push origin main
```

If it asks for a password, GitHub removed password auth in 2021 — use a
personal access token as the password, or switch the remote to SSH:

```sh
git remote set-url origin git@github.com:dleventis/KeepMind.git
```

This matters beyond backup: GitHub Pages serves the privacy policy from
`main`, and the live page still shows the old placeholder contact address
until this push lands. **App Review will open that URL.**

---

## 1. App Store Connect — create the app record

My Apps → **+** → New App.

- Platform: iOS
- Name: `Mindkeep: Expiry Reminders` — the bare word `Mindkeep` is
  rejected; see `docs/APP_STORE_LISTING.md`
- Primary language: English (UK) or (US) — pick one and keep the
  screenshots consistent with it
- Bundle ID: select `com.dleventis.keepmind` (it appears once the app ID
  exists in the Developer portal; Xcode creates it on first
  archive/upload, so if it is missing, do step 6 first and come back)
- SKU: anything private and stable, e.g. `mindkeep-ios-001`
- User access: Full Access

---

## 2. App Store Connect — create the subscription

Subscriptions cannot be sold until Apple has your **Paid Applications
Agreement** signed and your banking + tax forms complete (Business →
Agreements). Do this first; it is the single most common reason a
first-time developer's products stay stuck in "Missing Metadata".

Then: the app record → Monetization → Subscriptions → create a
Subscription Group.

- Group reference name: `Mindkeep Premium`
- Subscription:
  - Reference name: `Mindkeep Premium Monthly`
  - Product ID: `com.dleventis.keepmind.premium.monthly`
  - Duration: 1 month
  - Price: your call — look at what comparable single-purpose utilities
    charge before picking
- Required per subscription: a localised **display name** and
  **description**, and a **1024×1024 promotional image** is optional
- Group-level: a localised group display name (users see this in Manage
  Subscriptions)

The app's paywall reads whatever RevenueCat serves as the *current
offering*, so adding an annual product later needs no code change.

Review the subscription's own metadata and submit it — a subscription is
reviewed alongside the first build that references it.

---

## 3. RevenueCat — wire the entitlement

1. Create a project (`Mindkeep`) and add an **App Store** app to it with
   bundle ID `com.dleventis.keepmind`.
2. Upload the **App Store Connect API key** (In-App Purchase key) so
   RevenueCat can validate receipts and read your products. Without this,
   offerings come back empty and the paywall shows nothing.
3. Products → import / add `com.dleventis.keepmind.premium.monthly`.
4. Entitlements → create one with identifier exactly **`premium`** →
   attach the product. The identifier is hard-coded as the default in
   `app/lib/data/purchases/revenuecat_entitlement_service.dart`; if you
   name it anything else the app will never see a purchase.
5. Offerings → create the **default/current** offering → add a package
   containing the product. `getOfferings().current` is what the app
   reads; if no offering is marked current, `current()` returns an empty
   package list and the paywall is empty.
6. Copy the **public SDK key** for Apple (`appl_...`) from Project
   Settings → API keys.

The SDK key is public by design and safe in a build. It is still passed
in at build time rather than committed, so the repo has no key in it at
all — see §45 of the brief.

---

## 4. Build with the key and test the purchase

```sh
cd ~/Developer/KeepMind/app
flutter build ios --release --dart-define=REVENUECAT_IOS_KEY=appl_xxxxxxxx
```

With no key supplied the app deliberately runs free-tier with no paywall
rather than crashing, so **a build that "works fine" may simply mean you
forgot the define.** Confirm the paywall actually lists a price before
you archive.

Sandbox testing: Users and Access → Sandbox → Testers, create one, then
sign into it on the iPhone under Settings → App Store → Sandbox Account.
Sandbox subscriptions renew on an accelerated clock (a month ≈ 5
minutes), which is convenient for checking that a lapse correctly drops
the user back to free.

Verify end to end:

- [ ] Paywall shows a real price pulled from the store
- [ ] Purchase completes and the 10-memory cap lifts
- [ ] Restore Purchases works after deleting and reinstalling
- [ ] Killing the network still lets the app open, read memories and fire
      reminders (local-first failure policy)
- [ ] Existing memories stay readable when the subscription lapses

---

## 5. Screenshots

The version page asks for the **iPhone 6.5″ Display** slot, and accepts
1242 × 2688 or 1284 × 2778 (portrait). Up to 10; Apple reuses these for
the other display sizes, so one set is enough. Only the first 3 appear on
the install sheet, so put the best ones first.

1284 × 2778 is what an **iPhone 14 Plus** or **13 Pro Max** simulator
produces, which is the easiest way to hit it exactly:

```sh
open -a Simulator
# boot an iPhone 14 Plus, run the app, then Cmd-S saves to Desktop
```

Use real-looking but non-personal content — do not screenshot your own
passport. Suggested order, matching the description's structure: capture
→ dates found with the ambiguous-date choice visible → reminder
confirmation → quiet home screen.

The ambiguous-date screen is the one that actually differentiates the
app. Lead with it if you only ship three.

---

## 6. Archive and upload

```sh
cd ~/Developer/KeepMind/app
flutter build ipa --release --dart-define=REVENUECAT_IOS_KEY=appl_xxxxxxxx
```

Upload `build/ios/ipa/*.ipa` with Transporter, or open
`build/ios/archive/Runner.xcarchive` in Xcode → Distribute App.

Signing must be a **Distribution** certificate with an App Store
provisioning profile — automatic signing in Xcode handles this once
you're signed into the Developer account.

If codesign fails with an unhelpful error, note that this repo was moved
to `~/Developer/KeepMind` precisely because macOS `com.apple.provenance`
extended attributes on the old Documents/GitHub path propagated to every
build product and broke signing. Do not move it back.

---

## 7. Listing, privacy answers, export compliance

Copy from `docs/APP_STORE_LISTING.md` — name, subtitle, promotional text,
keywords and description are already length-checked against Apple's
limits.

- Support URL: the public repo URL works
- App Privacy: **Data Not Collected**; if asked about purchases, declare
  Purchases → not linked to identity, not used for tracking
- Age rating: 4+

**Export compliance.** You will be asked whether the app uses encryption.
It does: the local database is encrypted with SQLite3MultipleCiphers.
Standard cryptography used only to protect the user's own data on their
own device is normally exempt, but *the determination is yours to make,
not mine* — I am not qualified to give you a legal answer, and it is a
declaration you sign. Read Apple's export compliance documentation, and
if it stays ambiguous, ask someone who does this professionally. Adding
`ITSAppUsesNonExemptEncryption` to `Info.plist` afterwards stops it being
asked on every upload.

---

## 8. Submit

Attach the build, answer the review questions, submit. First reviews for
a new account commonly take longer than the usual day or two — budget for
a rejection-and-resubmit cycle before 30 September rather than assuming
one clean pass.

If review asks how date extraction works: it is deterministic pattern
matching on-device, not AI. The listing copy deliberately makes no AI
claim (`docs/DECISIONS.md` ADR-0006).

---

## Appendix — regenerating the launch image

`flutter build ipa` warns if the launch image is still Flutter's
placeholder. The current one is derived from the app icon; if the icon
changes, regenerate it rather than editing the PNGs by hand:

```sh
cd app/ios/Runner
python3 - <<'EOF'
from PIL import Image, ImageDraw
src = Image.open('Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png').convert('RGB')
for scale, name in ((1,'LaunchImage.png'),(2,'LaunchImage@2x.png'),(3,'LaunchImage@3x.png')):
    size, ss = 120*scale, 120*scale*4
    icon = src.resize((ss, ss), Image.LANCZOS)
    mask = Image.new('L', (ss, ss), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0,0,ss-1,ss-1], radius=int(ss*0.2237), fill=255)
    icon.putalpha(mask)
    icon.resize((size, size), Image.LANCZOS).save(f'Assets.xcassets/LaunchImage.imageset/{name}')
EOF
```

The 0.2237 ratio is the iOS icon corner radius, so the launch image reads
as the app's own icon rather than a floating square. The surrounding
colour is the `LaunchBackground` colour set, which has light and dark
variants matching the app's Material 3 surface — keep those in step with
`app/lib/core/theme/app_theme.dart`, or the launch screen will flash a
different shade before the first frame draws.

---

## 9. Shipaton submission

Separate from Apple. Register the app on the Shipaton entry form with the
live App Store link, and check the current rules for what else they want
(demo video, repo link, RevenueCat project ID). Do this the day the app
goes live, not on the 30th.
