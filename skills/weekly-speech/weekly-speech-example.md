# Worked example — presentation mode, Android

A run with invented but realistic materials: three raw sources reconciled into one finished speech. Use this to calibrate tone, paragraph length, and how much of a source's detail actually survives into a spoken line.

The product here is a fictional podcast app — the point is the shape of the reasoning, not the domain.

## Input 1 — slide bullets ("Clients: Android")

- **4.2.0** released with Offline Downloads. **4.3.0** to release this Wednesday
- Subscriptions: new paywall inside the app
- Discovery: editor's picks on the home screen
- Telemetry: audio buffering, artwork loading
- Performance: cold start, move feed parsing off the main thread
- Playback diagnostics: network-switch logging
- Networking: callback interfaces unified to suspend API
- Local DB migrations: playlist storage

## Input 2 — raw chat notes (developer, in another language, messy)

> основное, что сделали и будем релизить — это новый пейвол и офлайн-загрузки, ещё добавили
> метрику буферизации аудио (из сети/кеша/памяти)
>
> на той неделе был релиз 4.2.0 с фиксами плеера, парой ANRов и тех долгом (рефакторинг и
> оптимизация экрана подписки)
>
> на этой неделе будем саппортить пейвол после релиза, фиксить ui баги, добавлять немецкий
> язык и улучшать телеметрию плеера
>
> пейвол и офлайн только сейчас будем (в среду планируем)

A follow-up correction arrived later, after the first draft was already written:

> только именно офлайн-загрузки зарелизили на прошлой неделе, а на этой неделе будет просто
> несколько небольших фиксов плеера + подборка редакции на главном экране

**This is the case FACT RULES calls out explicitly:** the developer's first message reads as if the paywall and Offline Downloads both ship this week ("пейвол и офлайн только сейчас будем"), but the slide already marks 4.2.0 as released with Offline Downloads, and the correction confirms it. The slide plus the correction won — not the ambiguous first message.

## Input 3 — weekly report excerpt (`~/Desktop/android-weekly-2026-03-09.md`)

Only the parts that matched slide bullets were pulled in — the report has ~30 more PRs that never made it onto the slide, and none of them were forced in:

> **Networking migration complete** — replaced ~30 bespoke callback interfaces with one shared suspend API (`request()` + a sealed `RequestResult` type) that handles readiness, single-flight, timeout, throttle, and cancellation in one tested place. Closes the #812 epic.
>
> **Audio buffering metrics** (network/memory/disk) shipped behind a flag. Closes #859.
>
> **Cold-start perf** — offload eager init off main thread at process start, background scheduler init deferred.
>
> Subscriptions: prewarm-webview PR (#877) still **open** at report time.

## Output — the finished speech

```
Alright, update on Android.

We shipped 4.2.0 last week — the headline there was Offline Downloads, and it also carried some player fixes and tech debt work like refactoring and optimizing the subscription screen. Release looks good.

And release 4.3.0 goes out this Wednesday. The main thing here is the new paywall — a full subscription flow inside the app, with plans and purchases routed through the native billing dialog. We're also prewarming the web view so it opens fast. Once it's live, we'll be actively supporting it and watching how it behaves in production.

Also on discovery — for release 4.3.0 we've bundled in a few small player fixes, and editor's picks will now be showcased on the home screen.

On telemetry, we added new metrics around audio buffering and artwork loading — which gives us a much better picture of playback performance.

For performance, we focused on cold start — eager initialization at process start has been moved off the main thread — and we're moving feed parsing off the main thread as well.

On playback diagnostics, we added network-switch logging plus more precise socket error classification, so when playback stalls we can actually tell why.

A big tech debt win: the networking callback interfaces are now unified into a single suspend API. We had around 30 hand-rolled callback interfaces, and they've all been replaced with one shared, tested implementation that handles timeouts, throttling, and cancellation in one place. That closes the whole epic.

And finally, local DB migrations — playlist storage has been migrated over, with listening history staged next.

For the coming week we plan to support the paywall after release, fix UI bugs, add German localization, and improve player telemetry.

That's the Android update.
```

## What to notice

- **One number per topic, not every number.** The report's "~30 interfaces" made it into the networking paragraph because it's the one fact a listener will actually remember; the report's other numbers (single-flight, timeout, throttle mechanics) stayed out — they explain *how*, the speech only needs *what changed*.
- **Open work is spoken as open.** PR #877 (prewarm) was still open at report time, so the speech says "we're also prewarming" (present, ongoing) — never "we've prewarmed" (done).
- **A slide bullet with thin sourcing gets a thin paragraph.** "Telemetry: audio buffering, artwork loading" had no numbers behind it anywhere — the paragraph stays one sentence instead of padding with invented detail.
- **Conflicting sources: newer, more specific note wins**, and the resolution is silent in the speech itself — the conflict goes in the reply to the author, not in the spoken text.
