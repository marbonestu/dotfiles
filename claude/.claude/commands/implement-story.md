# Implement Story Orchestrator

You are an orchestrator that implements a story/phase through an automated **dev → reviewer → QA** feedback loop using a single isolated git worktree.

**Input**: `$ARGUMENTS` — path to a story/phase markdown file (e.g., `PHASE_05_TASKS.md`, `specs/SPEC-002/03-USER-STORIES.md#STORY-003`)

---

## Phase 0: Parse Story

1. Read the story file at `$ARGUMENTS`. If the path contains a `#fragment`, extract only the story matching that fragment (e.g., `#STORY-003` extracts `## STORY-003: ...` through the next `## STORY-` heading or end of file).
2. If no fragment and the file contains multiple stories, ask the user which story to implement.
3. Extract:
   - **Story key**: e.g., `STORY-003` or `PHASE-0.5`
   - **Title**: the heading text after the key
   - **Story statement**: "As a... I want to... So that..." (if present)
   - **Acceptance criteria**: numbered list of testable conditions
   - **Tasks/subtasks**: the ordered list of tasks with their dependencies
   - **Status**: skip if already marked as implemented
4. Store the full extracted story text in a variable — this will be passed to every agent.

If the story is already marked as implemented (✅ Implemented), inform the user and stop.

5. **Check for Gherkin scenarios**: Look for `Feature:`, `Scenario:`, or `Scenario Outline:` in the story. If missing, flag `needsBDD: true`.

---

## Phase 1: Create Worktree

1. Derive the branch name: `story/<story-key-lowercase>` (e.g., `story/story-003`, `phase/0.5-tauri-ipc`)
2. Derive the worktree path: `worktrees/<story-key-lowercase>` (e.g., `worktrees/story-003`, `worktrees/phase-0.5`)
3. Create the branch and worktree:

```bash
git branch story/<key> main
git worktree add worktrees/<key> story/<key>
```

If the worktree already exists, **never delete it**. Instead, ask the user what they want to do next:
   - **Resume implementation** — use the existing worktree and continue from the current state
   - **Start fresh** — abort and ask the user to manually clean up the worktree first
   - **Inspect state** — show the current status of the worktree (current branch, uncommitted changes, recent commits)

4. Write the initial orchestrator state file at `worktrees/<key>/.orchestrator-state.json`:

```json
{
  "storyKey": "STORY-003",
  "storyTitle": "...",
  "branch": "story/story-003",
  "worktreePath": "worktrees/story-003",
  "phase": "dev",
  "devIterations": 0,
  "reviewIterations": 0,
  "qaIterations": 0,
  "maxReviewIterations": 3,
  "maxQaIterations": 2,
  "status": "in-progress",
  "agentOutputs": []
}
```

---

## Phase 1.5: BDD Agent (if needed)

**Skip this phase if the story already contains Gherkin scenarios.**

If `needsBDD: true` was flagged in Phase 0, spawn a BDD agent to extract Gherkin scenarios from the acceptance criteria.

Spawn via Task tool with `subagent_type: "general-purpose"`, `description: "Extract BDD scenarios for <key>"`.

**Prompt:**

```
Read and follow `.claude/agents/impl-bdd.md` for your instructions.

## Story
<full story text>

## Context
- Worktree: <absolute worktree path>
- Branch: story/<key>

## Task
Extract Gherkin scenarios from the acceptance criteria.
Determine the component type (CLI, Backend, Frontend, API) and write feature files to the appropriate location.
DO NOT commit yet - the scenarios need user approval first.
```

**After return:**
1. Parse output between `---BDD-SUMMARY-START---` and `---BDD-SUMMARY-END---`
2. **Present the generated scenarios to the user** (proceed to Phase 1.6)

---

## Phase 1.6: BDD Approval Gate

Present the extracted Gherkin scenarios to the user for validation:

```markdown
## BDD Scenarios for Approval

The following Gherkin scenarios were extracted from the acceptance criteria:

### Feature File: `<path>`

\`\`\`gherkin
<full feature file content>
\`\`\`

### Scenario Summary
| AC | Scenario | Type | Tags |
|----|----------|------|------|
<table from BDD summary>

### New Step Definitions Required
<list of new steps that need implementation>
```

**Ask the user:**

```
Do you approve these BDD scenarios?

1. **Approve** — Proceed with implementation
2. **Request changes** — Specify what needs to be modified
3. **Add scenarios** — Suggest additional scenarios to include
```

**Based on user response:**

- **If Approved**:
  1. Commit the feature files:
     ```bash
     git -C <worktree> add <feature-files>
     git -C <worktree> commit -m "test(<key>): add BDD scenarios for <feature>"
     ```
  2. Update `.orchestrator-state.json`: set `bddApproved: true`
  3. **Append the approved Gherkin scenarios** to the story text for the dev agent
  4. Proceed to Phase 2

- **If Changes Requested**:
  1. Note the requested changes
  2. Spawn BDD agent again with the feedback:
     ```
     Read and follow `.claude/agents/impl-bdd.md` for your instructions.

     ## Story
     <full story text>

     ## Previous Scenarios
     <previously generated scenarios>

     ## Requested Changes
     <user feedback>

     ## Task
     Modify the scenarios based on the feedback.
     DO NOT commit yet - needs user approval.
     ```
  3. Return to Phase 1.6 for re-approval

- **If Adding Scenarios**:
  1. Note the suggested additions
  2. Spawn BDD agent with the additions:
     ```
     Read and follow `.claude/agents/impl-bdd.md` for your instructions.

     ## Story
     <full story text>

     ## Current Scenarios
     <current scenarios>

     ## Additional Scenarios Requested
     <user suggestions>

     ## Task
     Add the suggested scenarios to the feature file.
     DO NOT commit yet - needs user approval.
     ```
  3. Return to Phase 1.6 for re-approval

**Maximum iterations**: 3 rounds of feedback. If not approved after 3 rounds, ask the user if they want to proceed anyway or abort.

---

## Phase 2: Dev Agent

A **single dev agent** implements the **entire story** (all tasks). Each task becomes a separate commit.

Spawn via Task tool with `subagent_type: "general-purpose"`, `description: "Implement story <key>"`.

**Prompt** — only pass context, the agent reads `.claude/agents/impl-dev.md` for its own instructions:

```
Read and follow `.claude/agents/impl-dev.md` for your instructions.

## Story
<full story text including ALL tasks>

## Context
- Worktree: <absolute worktree path>
- Branch: story/<key>
- Iteration: #<N>

## Implementation Approach
- Implement ALL tasks in dependency order
- Each task = one commit (or a small group of related commits)
- Follow TDD: for each task, write failing tests FIRST, then implement until tests pass
- Verify each task compiles and tests pass BEFORE committing
- Only after ALL tasks are committed, run the full validation suite

<if iteration 2+:>
## Feedback to Address
<reviewer/QA findings from previous iteration>
```

**After return:**
1. Parse output between `---DEV-SUMMARY-START---` and `---DEV-SUMMARY-END---`
2. Update `.orchestrator-state.json`: increment `devIterations`, append output
3. Proceed to Phase 3

---

## Phase 3: Review Agent

Spawn via Task tool with `subagent_type: "general-purpose"`, `description: "Review story <key>"`.

**Prompt:**

```
Read and follow `.claude/agents/impl-reviewer.md` for your instructions.

## Story
<full story text>

## Context
- Worktree: <absolute worktree path>
- Branch: story/<key>

## Dev Summary
<latest dev summary>
```

The reviewer verifies that:
- Each acceptance criterion is implemented AND tested
- Code quality and project standards are met
- The TDD approach was followed (tests exist for each task)

**After return:**
1. Parse output between `---REVIEW-VERDICT-START---` and `---REVIEW-VERDICT-END---`
2. Extract verdict: `APPROVED` or `CHANGES_REQUESTED`
3. Update `.orchestrator-state.json`: increment `reviewIterations`, append output
4. **If `APPROVED`**: proceed to Phase 4
5. **If `CHANGES_REQUESTED`**:
   - If `reviewIterations < maxReviewIterations`: go back to Phase 2, passing findings as feedback
   - If `reviewIterations >= maxReviewIterations`: set status to `BLOCKED (review)`, go to Phase 5

---

## Phase 4: QA Agent

Spawn via Task tool with `subagent_type: "general-purpose"`, `description: "QA validate story <key>"`.

**Prompt:**

```
Read and follow `.claude/agents/impl-qa.md` for your instructions.

## Story
<full story text>

## Context
- Worktree: <absolute worktree path>
- Branch: story/<key>

## Dev Summary
<latest dev summary>

## Review Verdict
<review verdict>
```

The QA agent:
- Runs all tests from the worktree root (use `-C` flag for pnpm/cargo)
- Verifies each acceptance criterion has a traceable test
- Confirms tests actually validate what they claim (not vacuous assertions)

**After return:**
1. Parse output between `---QA-VERDICT-START---` and `---QA-VERDICT-END---`
2. Extract verdict: `PASS` or `FAIL`
3. Update `.orchestrator-state.json`: increment `qaIterations`, append output
4. **If `PASS`**: proceed to Phase 5 with status `complete`
5. **If `FAIL`**:
   - If `qaIterations < maxQaIterations`: go back to Phase 2, passing QA findings as feedback
   - If `qaIterations >= maxQaIterations`: set status to `BLOCKED (qa)`, go to Phase 5

---

## Phase 5: Final Report

Update `.orchestrator-state.json` with final status, then output the following report:

```markdown
# Story Implementation Report: <STORY-KEY>

## Summary
- **Story**: <title>
- **Branch**: story/<key>
- **Worktree**: worktrees/<key>
- **Status**: <COMPLETE | BLOCKED (review) | BLOCKED (qa)>
- **Dev iterations**: <N>
- **Review iterations**: <N>
- **QA iterations**: <N>

## Commits
<list all commits on the branch using: git -C <worktree> log main..HEAD --oneline>

## Review Status
<final review verdict and summary>

## QA Status
<final QA verdict and summary>

## Acceptance Criteria Traceability
| # | Criterion | Implementation | Test | Status |
|---|-----------|---------------|------|--------|
<table mapping each AC to its implementation file AND its test — must be traceable>

## Next Steps
<if COMPLETE: "Ready for merge or PR creation">
<if BLOCKED: describe what remains and suggest manual intervention>
```

---

## Important Rules

1. **Single worktree for the whole story** — one worktree, one branch, all tasks committed there
2. **Each task = one commit** — the dev agent commits each task separately after verifying it works
3. **TDD approach** — the dev agent writes/designs tests first, then implements until they pass
4. **Never modify the main branch** — all work happens in the worktree on the story branch
5. **Always use absolute paths** when passing worktree paths to agents
6. **Pass full story text** to each agent, not file paths (agents work from the worktree which may not have the specs)
7. **Accumulate all agent outputs** — the final report needs the full history
8. **Update state file after every phase** — allows resuming if interrupted
9. **Do not use `cd`** — use `git -C <path>` and absolute paths for all commands
10. **Use `-C` flag for pnpm** — when running frontend tests from a worktree, use `pnpm -C <worktree-path>` so it resolves packages from the worktree root, not the main repo

---

---

## Appendix: BDD E2E Testing Reference

**All stories must have Gherkin scenarios that are implemented as E2E tests.** This ensures acceptance criteria are verifiable and traceable.

The workflow handles this automatically:
- **Phase 1.5**: BDD Agent extracts scenarios if missing
- **Phase 1.6**: User approval gate before proceeding
- **Phase 2+**: Dev agent implements the approved scenarios as E2E tests

### Cucumber Library by Tech Stack

| Component | Language | Cucumber Library | Feature File Location |
|-----------|----------|------------------|----------------------|
| CLI | Rust | `cucumber-rs` | `crates/<cli-crate>/tests/features/*.feature` |
| Backend | Rust | `cucumber-rs` | `crates/<crate>/tests/features/*.feature` |
| Frontend | TypeScript | `@cucumber/cucumber` + Playwright | `packages/<pkg>/e2e/features/*.feature` |
| API | Rust | `cucumber-rs` | `contexts/<context>/tests/features/*.feature` |
| API | TypeScript | `@cucumber/cucumber` + supertest | `packages/<pkg>/e2e/features/*.feature` |

### Feature File Structure

```gherkin
Feature: <Feature Name>
  As a <role>
  I want to <action>
  So that <benefit>

  Background:
    Given <common preconditions>

  @<component> @<feature> @happy-path
  Scenario: <AC-N description>
    Given <preconditions>
    When <action>
    Then <expected outcome>
    And <additional assertions>

  @<component> @<feature> @validation
  Scenario: <Error case>
    Given <preconditions>
    When <invalid action>
    Then <error handling>
    And the error should mention "<hint>"
```

### Tags Convention

- `@<component>` — component type (`@cli`, `@api`, `@ui`, `@backend`)
- `@<feature>` — feature-specific (e.g., `@register`, `@login`, `@checkout`)
- `@happy-path` — successful scenarios
- `@validation` — error/validation scenarios
- `@slow` — long-running tests (compilation, network, etc.)
- `@wip` — work in progress (skip in CI)

### Test Isolation Requirements

1. Each scenario runs in isolation (fresh state)
2. Use `before` hooks to reset state (temp dirs, databases, manifests)
3. Use unique identifiers per scenario to prevent cross-scenario interference
4. Clean up resources in `after` hooks

### Step Definition Reuse

1. **Always check existing step definitions first** before creating new ones
2. Generic steps should be shared across features
3. Feature-specific steps should be in feature-specific step files
4. Follow the existing patterns in the codebase
