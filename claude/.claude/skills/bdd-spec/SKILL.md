---
name: bdd-spec
description: Write BDD behavioral specifications following the book "BDD in Action 2nd Edition" methodology. Produces Gherkin feature files organized by capability with proper rules, examples, and tags. Supports functional and non-functional requirements.
argument-hint: "<feature-description> [--nfr] [--capability <name>] [--dry-run]"
---

# BDD Behavioral Specification Writer

Write behavioral specifications (NOT implementation/architecture specs) following the BDD in Action 2nd Edition methodology.

## When to Use This Skill

Use this when the user needs to specify **what the system should do** from a business perspective. This produces Gherkin `.feature` files with Given/When/Then scenarios.

**DO NOT** use this for:
- Architecture specs (phase DAGs, trait designs, migration plans) — those are implementation specs
- Technical design documents
- API contracts or data schemas

## Spec Type Distinction

| Behavioral Spec (this skill) | Architecture/Implementation Spec |
|------------------------------|----------------------------------|
| What the system does + why | How to build it |
| Business-readable Gherkin | Code, diagrams, phase plans |
| Organized by capability/feature | Organized by implementation phase |
| Living documentation | Consumed during build |
| Validates business rules | Validates architecture decisions |

## Input

The user provides one of:
- A feature description in plain language
- A user story or business requirement
- A conversation/discovery session output
- `--nfr` flag to include non-functional requirements
- `--capability <name>` to place it within an existing capability hierarchy
- `--dry-run` to output the spec without writing files

## Process

### Step 1: Understand the Domain

Before writing anything, ask clarifying questions if needed:
- Who are the personas/actors? (Never use "the user" — use named personas like "Trevor the frequent flyer")
- What business goal does this serve?
- What capability does this belong to?
- Are there non-functional concerns (security, performance, compliance)?

### Step 2: Discover Rules and Examples

Apply Example Mapping mentally:
1. Identify the **feature** (yellow card)
2. Extract **business rules** (blue cards) — each rule is a distinct behavioral constraint
3. For each rule, find **concrete examples** (green cards) — happy path first, then edge cases
4. Note **questions/unknowns** (pink cards) — surface these to the user

### Step 3: Determine File Placement

Organize by **capability**, not by story/sprint/release:

```
features/
  <capability>/
    <sub-capability>/
      <feature>.feature
```

The directory structure should read like a table of contents of what the system does.

### Step 4: Write the Feature File

Use this template:

```gherkin
@<capability-tag>
Feature: <Feature name — what the system does, not how>

  <1-2 sentence description connecting this feature to the business goal>

  Background:
    <Only shared preconditions that apply to ALL scenarios below>

  Rule: <Business rule 1 — a single behavioral constraint>

    Example: <Descriptive title summarizing Given+When, not the outcome>
      Given <relevant precondition — only what matters for this rule>
      When <the action/event — ONE action per scenario>
      Then <observable outcome in business terms>

    Example: <Edge case or counterexample for the same rule>
      Given ...
      When ...
      Then ...

  Rule: <Business rule 2>

    Example: <Title>
      Given ...
      When ...
      Then ...

    Scenario Outline: <Title — use when multiple data combinations test the same rule>
      Given <precondition with <parameter>>
      When <action with <parameter>>
      Then <outcome with <parameter>>

      Examples:
        | parameter | expected_result |
        | value1    | outcome1        |
        | value2    | outcome2        |
```

### Step 5: Add NFR Tags (when --nfr or when relevant)

Tag non-functional requirements using the `@<nfr-type>:<detail>` convention:

```gherkin
@security:authentication
@performance:response-time
@compliance:gdpr
@reliability:failover
```

NFR scenarios read like functional scenarios — the NFR aspect is identified by the **tag**, not by different syntax:

```gherkin
@security:password-strength
Rule: Passwords must meet minimum strength requirements

  Example: Strong password is accepted
    Given Trevor is registering for an account
    When he sets his password to "SeagullHedgehogCatapult"
    Then the password strength should be "Very strong"
    And his registration should be accepted

  Example: Weak password is rejected
    Given Trevor is registering for an account
    When he sets his password to "password1"
    Then the password strength should be "Weak"
    And he should see a message explaining the password is too weak
```

For performance NFRs that are better verified at the API/service level, write the spec but add a `@manual` or `@api-test` tag to indicate it won't run as a standard Gherkin acceptance test:

```gherkin
@performance:api-latency @api-test
Rule: Search results must return within acceptable time

  Example: Search responds within 200ms under normal load
    Given the system is under normal load (< 100 concurrent users)
    When a user searches for available flights
    Then results should be returned within 200 milliseconds
```

## Writing Rules — MANDATORY

### DO

1. **One rule per scenario** — each scenario tests exactly one business rule
2. **Declarative style** — describe WHAT the user achieves, not HOW they click
   - Good: `When Trevor searches for flights from Paris to London`
   - Bad: `When Trevor clicks the "from" field and types "Paris" and clicks the "to" field and types "London" and clicks "Search"`
3. **Independent scenarios** — no scenario depends on another running first
4. **Start simple, build up** — simple happy-path examples first, then edge cases
5. **Only relevant preconditions** — if a Given doesn't influence the outcome, remove it
6. **Meaningful titles** — summarize the Given+When context, not the expected outcome
   - Good: `Example: Transfer points between family members`
   - Bad: `Example: Points are transferred successfully`
7. **Named personas** — "Trevor the frequent flyer", not "the user" or "the customer"
8. **Self-contained data** — set up state explicitly, never rely on external/production data
9. **Use Background sparingly** — only for preconditions shared by ALL scenarios in the feature
10. **Use Rule keyword** — group related examples under the business rule they illustrate
11. **Business language in Then** — outcomes in business terms, not technical assertions
    - Good: `Then Trevor should see his booking confirmation`
    - Bad: `Then the response status code should be 200`

### DO NOT

1. **No end-to-end test scripts** — long sequences of UI interactions testing multiple rules
2. **No converted manual tests** — words like "verify", "check", "validate" are red flags
3. **No chained scenarios** — "Step 1", "Step 2", "Step 3" that depend on each other
4. **No excessive duplication** — use Scenario Outline for data-driven variations
5. **No implementation details** — no CSS selectors, API endpoints, DB tables in scenarios
6. **No generic actors** — never "The User", always a persona with context
7. **No production data dependencies** — scenarios manage their own state
8. **No organizing by story/sprint** — organize by capability (what the system does)

## Three Abstraction Layers

When scenarios will be automated, keep these layers in mind:

```
1. Business Rules Layer    → The .feature file (this skill's output)
                             Stable, changes only when business rules change

2. Business Flow Layer     → Step definitions in business language
                             No direct system interaction, delegates to technical layer

3. Technical Layer         → Locators, API calls, DB queries
                             Absorbs implementation churn, isolates upper layers
```

This skill ONLY produces Layer 1. The other layers are implementation concerns.

## Output

After writing, summarize:
- Feature file path and capability placement
- Number of rules and examples
- Any questions/unknowns discovered (pink cards)
- NFR tags applied (if any)
- Suggested next: related features or rules to explore

If `--dry-run`, show the spec in a code block without writing any file.
