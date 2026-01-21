# RW Loop

Autonomous task runner for Claude. Give it a task list, let it work.

## Setup

```bash
git clone git@github.com:YOUR_USERNAME/ralph.git ~/.ralph
cp ~/.ralph/profiles/zai.env.example ~/.ralph/profiles/zai.env
# Add your API key to zai.env

echo "alias ralph='~/.ralph/ralph-wiggum-loop.sh'" >> ~/.zshrc
source ~/.zshrc
```

Requires: [Claude Code](https://github.com/anthropics/claude-code), Node.js 18+, zsh

## Workflow

### 1. Plan

```bash
ralph plan --profile zai
```

Opens an interactive Claude session to create/refine your tasks.md. Chat with Claude about what you want to build, refine the task list, then tell it to write the file. Type `/exit` when done.

### 2. Run

```bash
ralph --profile zai
```

Runs the task loop. Claude picks a task, completes it, marks it done, logs to changelog, repeats until all tasks are complete.

### 3. Intervene (if needed)

- `Ctrl+C` stops everything
- Run `ralph` again to resume (picks up where tasks left off)
- Run `claude` directly to fix things manually

## Commands

| Command | Description |
|---------|-------------|
| `ralph plan` | Interactive planning session to create tasks.md |
| `ralph` or `ralph run` | Run the autonomous task loop |

## Flags

| Flag | Description |
|------|-------------|
| `-t, --tasks` | Tasks file (default: tasks.md) |
| `-c, --changelog` | Changelog file (default: CHANGELOG.md) |
| `-p, --profile` | API profile (zai, default) |
| `-m, --model` | Model (opus, sonnet, haiku) |
| `-i, --interactive` | Run with full Claude TUI (see output, manual exit) |
| `-C, --cli` | CLI tool (claude, opencode) |

## Examples

```bash
ralph plan --profile zai              # Plan tasks
ralph --profile zai                   # Run loop
ralph --profile zai -i                # Run with interactive output
ralph --profile zai -m haiku          # Use haiku model
ralph -t docs/tasks.md                # Custom task file
```

## Task File Format

Create `tasks.md` in your project root:

```markdown
# Tasks

- [ ] Create auth system
- [ ] Add form validation
- [ ] Write tests

## References

- Use patterns in src/auth.ts
- Run tests with npm test
```

- `- [ ]` = incomplete
- `- [x]` = done (Claude marks these)
- Add a References section for context Claude can use

## Profiles

Switch between API providers:

```bash
ralph --profile zai      # z.ai backend
ralph --profile default  # Anthropic direct
```

Create new profiles by copying `~/.ralph/profiles/template.env`.
