# Presentation speech style rules

Rules distilled from the iOS 7.4.0 speech (2026-08-24), which the author approved after seven rounds of edits.
Each rule carries the correction that produced it, so the reasoning survives.
Apply these on the first draft — they are what the author would otherwise ask for.

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
