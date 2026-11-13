# Global Agent Configuration

This is a global constitution/configuration file. Subprojects
may have their own patterns, constitutions, preferences, and
they should supersede this one when they are in conflict.

## Core Principles

Apply these principles to every task.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

-   State assumptions explicitly. If uncertain, ask.
-   If multiple interpretations exist, present them - don't pick silently.
-   If a simpler approach exists, say so. Push back when warranted.
-   If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

-   No features beyond what was asked.
-   No abstractions for single-use code.
-   No "flexibility" or "configurability" that wasn't requested.
-   If you write 200 lines and it could be 50, rewrite it.

**The test:** Would a senior engineer say this is overcomplicated? If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

-   Don't "improve" adjacent code, comments, or formatting.
-   Don't refactor things that aren't broken.
-   Match existing style, even if you'd do it differently.
-   If you notice unrelated dead code, mention it - don't delete it.
-   Remove imports/variables/functions that YOUR changes made unused.
-   Don't remove pre-existing dead code unless asked.

**The test:** Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

| Instead of...    | Transform to...                                       |
| ---------------- | ----------------------------------------------------- |
| "Add validation" | "Write tests for invalid inputs, then make them pass" |
| "Fix the bug"    | "Write a test that reproduces it, then make it pass"  |
| "Refactor X"     | "Ensure tests pass before and after"                  |

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

## Preferences

-   **Testing**: Tests verify behavior and prevent regressions. Add them when they
    catch something a future change could break; don't add them just to lift coverage.
-   **Linting and Formatting**: All code must adhere to the project's linting and formatting
    standards. Before committing code, ensure that it passes all linting checks and is
    properly formatted.
-   **Documentation**: Update project documentation (README, CHANGELOG, etc.) when changes
    are meaningful enough to warrant it.
-   **DRY**: Avoid code duplication. If you find yourself copying and pasting code, consider refactoring
    to create reusable functions or modules.
-   **YAGNI**: You aren't gonna need it. Avoid adding functionality until it is necessary. This helps to
    keep the codebase clean and maintainable.

## Dev Workflows

Use these skills when they apply:

-   **`spec-driven-development`**: plan non-trivial features, bug fixes, refactors, and
    migrations with Spec Kit before implementing.
-   **`taskfiles`**: run development workflows through `task`.
-   **`python-style`**: `uv` environment management and Python code style.
-   **`pr-conventional`**: open and refine pull requests.

## Committing Code

-   When committing code, use conventional commits unless the project uses a different
    convention:

    ```
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
    ```

    -   Example:

        ```
        feat(perf): increase parallel computations

        Use asynchronous thread workers to get more work done concurrently.
        ```

    -   When you know it from the branch name, history, context, use the Jira ticket number:

        ```
        feat(CED-123): increase parallel computations

        Use asynchronous thread workers to get more work done concurrently.
        ```

-   Don't add yourself as a Co-Author unless explicitly requested to, or if the project
    documentation requires it.

### Committing Workflow

Before committing, ensure that your code passes all checks:

1. Run `task fix` to automatically fix any formatting or linting issues.
2. Run the project's formatting, linting, and type-checking tasks (see `task --list-all`).
3. Run `task test` to ensure all tests pass and coverage is sufficient.
4. Run `pre-commit` hooks if the project uses them.

## Security Considerations

-   PHI/PII (for projects that touch sensitive data): Under no circumstances should Patient
    Health Information or Personally Identifiable Information be included in code,
    comments, or PR descriptions.
-   Secrets: Use environment variables. Never commit API keys or database credentials.
-   Synthetic Data: Use only generated synthetic data for unit and integration tests.
-   Never read secret files like `.env` or use tools to decrypt secrets in your context.
    If you are requested to use secrets, ensure they are injected securely at runtime.
