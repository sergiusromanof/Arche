# Presentation speech style rules

Rules distilled from two speeches the author approved after correcting them line by line: the iOS 7.4.0 speech (2026-08-24, one slide) and the iOS 7.5.0 deck (2026-08-31, two slides).
Each rule carries the correction that produced it, so the reasoning survives.
Apply these on the first draft — they are what the author would otherwise ask for.
Rules 1–15 came from the first speech, 16–22 from the second; both approved speeches are at the bottom.

---

## 1. One paragraph per slide bullet. No catch-all sweep line.

A single line that names four topics without saying anything about them will be sent back.
Every bullet on the slide earns its own short paragraph, even the small ones.

Rejected:

> Everything else was smaller work: Unowned Items in the Collection, the new Aura anti-cheat errors, the web store on by default, the voice peer list moved off the main thread, and the Perfect Match integration is still going.

Approved: five separate paragraphs, one per topic, one to three sentences each.

A "smaller work" grouping is only allowed for items that are *not* on the slide.

## 2. The release line is one sentence.

Released version plus health, nothing else.

> We released 7.4.0, and it's looking stable.

## 3. Never attribute slide bullets to the version that just shipped.

The slide lists what the team is working on now, not what went out.
The changelog will often disagree — a ticket can sit under a released version there and still be open and in flight.
When they conflict, write the speech per the slide and flag the conflict in the reply.

## 4. Name the person when the stream is someone else's.

Ownership is what the room wants to hear on another developer's work.

> On Standalone Poker, Vadim is making good progress on the auth flow — sign in, sign up, sign out — and the delete account flow. We expect all of that to be done soon.

## 5. Group sibling tickets into one flow.

Four separate account tickets became "the auth flow — sign in, sign up, sign out — and the delete account flow".
Speak the shape of the work, not the ticket list.

## 6. Say the target release, and say when fixes are split across releases on purpose.

A deliberate split is a decision the room should hear, not an accident to hide.

> We're splitting the fixes between 7.5.0 and 7.6.0 so we don't mix them up in one release.

## 7. Feature paragraphs: what it does, then status, then release.

> We also finished Unowned Items in the Collection. The collection now shows the items a user doesn't own next to the ones they do, so they can see what's still missing, and there's a switch to hide them if they only want to see their own. It's in testing now and planned for 7.5.0.

## 8. Third person for end users. Never "you".

"the items you don't own … if you only want your own" was corrected to "the items a user doesn't own … if they only want to see their own".
The audience is the team, not the user.

## 9. Infra and tech-debt: goal plus target release. Nothing else.

Rehearsal detail, build evidence and blockers do not belong in the spoken version.

Rejected:

> Migrating away from CocoaPods is a work in progress. We rehearsed it end to end — with CocoaPods fully gone, both Plato and Poker built. What blocks us is push access on the mediasoup fork.

Approved:

> We're also getting rid of the legacy CocoaPods and moving everything to Swift Package Manager. It should be finished by the 7.5.0 release.

Blockers still matter — raise them in the reply to the author, not in the speech.

## 10. Give the why when people will ask for it.

Long-deferred work needs one sentence of honest history, in the author's voice.

> We kept postponing it because other tasks had higher priority, and now it looks like we finally have a bit of time to actually do it.

## 11. Say what changes for the team.

When work changes how colleagues write code or work day to day, name that consequence.

> Swift 6 comes with much stricter rules for how we write code, and from now on we all have to follow them.

## 12. Cut metrics the author did not state.

"around 26 thousand warnings in a single week in July" was true and sourced, and it was still cut.
Numbers slow a spoken update down unless the author put them in the notes.

## 13. Explain internal names in passing, in the same sentence.

> a new POOP message that delivers the game info to the clients

## 14. Vary the opening transition of each paragraph.

Rotate through: "On Standalone Poker...", "The Swift 6 migration...", "On the messages side...", "We're also...", "We also finished...", "On Aura...", "For games...", "And Perfect Match...".
Never start three paragraphs in a row the same way.

## 15. Length.

One platform lands around 350–400 words across roughly ten paragraphs.
Under 250 words means bullets got merged that should not have been.
A two-slide deck lands around 600 words total — roughly 300 per slide, not 350–400 per slide.

## 16. Round every number you speak.

A spoken number is heard once and never re-read, so precision past the first two digits is noise.
The author rounded every figure that survived the cut: 44,000 users became "around 40 thousand", 32.5% became "about 30 percent", 98.3% stayed as it was because it is already the headline.
This does not loosen rule 12 — most numbers still get dropped. It governs the ones that stay.

## 17. Say what the author said, and stop there.

Explaining a mechanism the author did not explain reads as padding, and it invites a correction you cannot defend.

Rejected:

> On anti-cheat, I finished the iOS side of App Check attestation. It checks the session at the server level so nobody can pretend to be a platform they're not, and it will ship behind a feature flag.

Approved:

> On anti-cheat, I finished the iOS side of App Check attestation. It's added under a feature flag for the 7.5.0 release.

## 18. Never credit a result to a cause the source does not name.

Tying two slide items together because they share a word is a guess, and guesses about causation are the ones that get caught.
"we added the vacuum metrics, which is what gave us all those numbers from the first slide" was wrong — the metrics were added for longer-term analysis, and the numbers came from elsewhere.

## 19. Let the numbers land without a verdict.

Cut the clause that tells the room how to feel about what they just heard.

Rejected:

> idle reports are down about 30 percent and long reports have dropped by half — and that's a good thing, because what disappeared was all the invalid ones.

Approved: the same sentence, ending at "dropped by half."

## 20. A number is an example unless the superlative is sourced.

"the biggest database we saw went from 1.4 gigabytes down to about 200 megabytes" claimed a maximum nobody had established.
It became "as one example of a vacuum doing its job, a database went from 1.4 gigabytes down to about 200 megabytes".

## 21. The release line grows when the release is the news.

Rule 2 holds for a release that simply shipped.
When something happened to it, the release earns its sentences.

> On iOS release 7.5.0 — Apple rejected the build, and Joe has already resubmitted it for review. The build itself is tested and there's nothing left to fix on our side, so we're ready to ship the moment it gets approved.

## 22. Notes in another language are substance, not phrasing.

The author writes notes in Russian and expects English back — translate the reasoning, the ordering and the caveats, and let the wording become plain spoken English rather than a literal rendering.
Their "мы заметили уменьшения логов" carried the point that the drop is in *invalid* reports; that point survived while their sentence shape did not.

---

## Approved reference speech (iOS, 2026-08-24)

Now, iOS.

We released 7.4.0, and it's looking stable.

On Standalone Poker, Vadim is making good progress on the auth flow — sign in, sign up, sign out — and the delete account flow. We expect all of that to be done soon.

The Swift 6 migration is a work in progress. We kept postponing it because other tasks had higher priority, and now it looks like we finally have a bit of time to actually do it. One thing worth knowing: Swift 6 comes with much stricter rules for how we write code, and from now on we all have to follow them.

On the messages side, we found a few bugs around duplicated messages. We're splitting the fixes between 7.5.0 and 7.6.0 so we don't mix them up in one release. And the logs should now give us much more information about the duplicates themselves.

We're also getting rid of the legacy CocoaPods and moving everything to Swift Package Manager. It should be finished by the 7.5.0 release.

We also finished Unowned Items in the Collection. The collection now shows the items a user doesn't own next to the ones they do, so they can see what's still missing, and there's a switch to hide them if they only want to see their own. It's in testing now and planned for 7.5.0.

On Aura, we handled two new anti-cheat errors coming from the server — the email verification requirement, and the sender-wide like limit, which we now apply as a cooldown across the sender instead of per receiver.

The web store is now on by default, so a fresh install gets the web store and not the native one. We kept the feature flag in place for now, just in case.

For games, we moved the voice chat peer list read off the main thread. Our hang rate had been up since 7.2.0, and this was one of the causes.

And Perfect Match, the new game kind, is still being integrated. We did a pass on the animations and the colors, and we're working on a new POOP message that delivers the game info to the clients — that part is still in progress.

That's the iOS update.

---

## Approved reference deck (iOS, 2026-08-31, two slides)

On iOS release 7.5.0 — Apple rejected the build, and Joe has already resubmitted it for review. The build itself is tested and there's nothing left to fix on our side, so we're ready to ship the moment it gets approved.

We had a few wins:

1st one is Vacuum.
Incremental vacuum is now enabled, which means that for users who have already run a full vacuum, the database gets cleaned up gradually on its own from now on. Our main goal here is to make it less likely that the database grows out of control, both for the users we already have and for new ones, and to fix the situation for around 40 thousand users who were reporting a database above the 50 megabyte limit. And the numbers look good: we purged over 250 gigabytes in total, and as one example of a vacuum doing its job, a database went from 1.4 gigabytes down to about 200 megabytes.

On the connection side, we found that some of our Long and Idle reports were simply wrong. The clearest example: a user would report a long connection while they had no internet at all. Those reports aren't valid and they don't tell us anything, so we fixed a number of cases like that. We're now seeing fewer of those logs — idle reports are down about 30 percent and long reports have dropped by half.

And the images cache. We added telemetry there to find out whether our image cache actually works and how well, we collected data for a week, and the data confirms it's working well — a 98.3 percent cache hit rate, with the disk cache about 30 percent full. We plan to turn those logs off soon, because the plan was always to switch them on when we need them, not to collect them all the time.

Next slide please

-------------------------------------------------------------------------------

On Standalone Poker, Vadim finished all the account flows. He also restyled the connection warning bar and the buttons, and updated the EULA screen. The main screen restyle is still in progress.

Perfect Match is moving too. Maria is now powering the feature with the real API instead of the mock data, and that's still a work in progress.

The Swift 6 migration continues. I've started publishing pull requests for the simple modules — the ones that migrated easily — so it's going out package by package instead of one huge change.

On anti-cheat, I finished the iOS side of App Check attestation. It's added under a feature flag for the 7.5.0 release.

For bugs, we fixed a popup that didn't fit long text, corrected the Thai translation, and cut out unnecessary vacuum calls. One more is still open — updating Realm so it works with Xcode 27.

On telemetry, we added the vacuum metrics. Those are there for longer-term analysis, so we can keep an eye on how the databases behave over time.

We also finished getting rid of CocoaPods. Every dependency now comes through Swift Package Manager, so that whole legacy setup is gone.

And a small quality-of-life one: the app icon now shows the environment and the version number, so you can tell at a glance which build is on the device. There's an example of it on the slide.

Two more are still in progress: a dependency injection system, and fixing the GRDB unit tests that broke. We also added a script that downloads the i18n CLI, so translations are one less manual step.

That's the iOS update.
