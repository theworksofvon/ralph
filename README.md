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

## Usage

```bash
cd /your/project
ralph                       # default API
ralph --profile zai         # z.ai backend
ralph -t my-tasks.md        # custom task file
ralph --profile zai -m haiku
```

## Task File

Create `tasks.md` in your project:

```markdown
# Tasks

- [ ] Create auth system
- [ ] Add form validation
- [ ] Write tests

## References

- Use patterns in src/auth.ts
- Run tests with npm test
```

Claude picks a task, does it, marks it `[x]`, logs to `CHANGELOG.md`, repeats.

## Flags

| Flag | Description |
|------|-------------|
| `-t, --tasks` | Tasks file (default: tasks.md) |
| `-c, --changelog` | Changelog file (default: CHANGELOG.md) |
| `-p, --profile` | API profile (zai, default) |
| `-m, --model` | Model (opus, sonnet, haiku) |
| `-C, --cli` | CLI tool (claude, opencode) |

## Workflow

- `Ctrl+C` stops everything
- Run `ralph` again to resume (picks up where tasks left off)
- Run `claude` directly if you need to intervene manually
