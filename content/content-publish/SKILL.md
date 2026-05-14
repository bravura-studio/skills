---
name: content-publish
description: |
  Ship phase of the Scripta content pipeline. Moves an approved draft from
  content/drafts/ to content/published/, sets status to "published", creates
  the PR. Handles the andochoa.com repo mechanics. Use after content-edit
  passes with PUBLISH verdict, or when someone says "publish this", "make it
  live", "ship the article".
version: 1.0.0
category: content
interactive: false
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Edit
  - Write
triggers:
  - "publish this"
  - "make it live"
  - "ship the article"
  - "push it to the site"
benefits-from:
  - content-edit
feeds-into: []
qmd: []
reads-learnings: true
writes-learnings: true
---

# Content Publish

## Context

The final mechanical step. The draft has been researched, written with the founder's voice, and edited for quality. This skill handles the git/deployment mechanics to get it live on andochoa.com.

**Critical rule:** content/published/ = LIVE. The code at lib/posts.ts uses directory as fallback for status. Putting a file in content/published/ makes it visible on the site immediately, regardless of frontmatter status. This is why we always draft in content/drafts/ first and move to published in a separate, explicit step.

## Prerequisites

- An approved draft (content-edit verdict: PUBLISH, or founder override)
- The draft file exists in `content/drafts/journals/` in the andochoa.com repo
- If working from build-fun-free, the draft is at `skills/_output/content-draft-*.md`

## Steps

### Step 1: Locate the Draft

Find the approved draft:
```bash
# In andochoa.com repo
ls content/drafts/journals/*.mdx 2>/dev/null

# Or in build-fun-free (if drafted here)
ls skills/_output/content-draft-*.md 2>/dev/null
```

Read the file. Verify:
- Frontmatter exists (title, date, excerpt, tags)
- Status is "draft"
- Content ends with "Keep building. -Ochoa"

### Step 2: Prepare for Publishing

Update the frontmatter:
- Set `status: "published"`
- Verify `date` is the intended publish date (today unless specified)
- Confirm slug is clean and readable

If the draft is in build-fun-free, it needs to be moved to the andochoa.com repo.

### Step 3: Move to Published Directory

**If in the andochoa.com repo:**
```bash
# Move from drafts to published
mv content/drafts/journals/{slug}.mdx content/published/journals/{slug}.mdx
```

**If in build-fun-free:**
Note the file path and instruct that it needs to be copied to the andochoa.com repo:
```
File: skills/_output/content-draft-{date}-{slug}.md
→ Copy to: andochoa.com/content/published/journals/{slug}.mdx
→ Update status: "published"
```

### Step 4: Create PR

If in the andochoa.com repo, create a PR:

```bash
git checkout -b content/{slug}
git add content/published/journals/{slug}.mdx
git commit -m "content: publish {title}"
git push -u origin content/{slug}

gh pr create --title "content: publish {title}" --body "$(cat <<'EOF'
## Summary
- Publishes: "{title}"
- Mode: {short punchy | wisdom piece}
- Research brief: {path or "N/A"}
- Edit verdict: PUBLISH

## Checklist
- [ ] Title reads well
- [ ] Excerpt works as social preview
- [ ] Content ends with sign-off
- [ ] No draft artifacts or TODOs in body
- [ ] Tags are consistent with existing articles

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 5: Verify Deployment

After the PR is merged (Vercel auto-deploys from main):
1. Check the Vercel deployment status
2. Visit the live URL: `https://andochoa.com/journal/{slug}`
3. Verify the page renders correctly
4. Check OG/social meta tags render properly

If working from build-fun-free and can't verify directly, note that verification is needed post-merge.

### Step 6: Report

State:
- PR URL (if created)
- Live URL (if deployed)
- Article title and publish date
- Any post-publish tasks (social sharing, cross-posting)

## Completion

Report status:
- **DONE** — Article published (or PR created for publishing). State the URL.
- **DONE_WITH_CONCERNS** — Published but something looks off (rendering issue, meta tags wrong).
- **BLOCKED** — Can't publish (wrong repo, missing access, build failure).
- **NEEDS_CONTEXT** — Draft location unclear or multiple drafts exist. Ask which one.

## Learnings Capture

After completion, evaluate:
1. Did the deployment process hit any friction? (Slug conflicts, build errors)
2. Did the live page render as expected? (Note any rendering gotchas for this site.)
3. Was the frontmatter complete or did we have to add fields? (Note missing fields for content-draft.)
