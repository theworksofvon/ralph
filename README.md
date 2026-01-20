# Ralph Wiggum Loop

> "I'm helping!" - Ralph Wiggum

An autonomous task runner that feeds Claude a list of tasks and lets it work through them one by one.

## How It Works

1. You create a `tasks.md` file with checkboxes
2. Ralph loops, giving Claude the task list each iteration
3. Claude picks the most important task, completes it, marks it done
4. Repeat until all tasks are `[x]`

```
┌─────────────────────────────────────┐
│  ralph starts                       │
│  └─> Any incomplete tasks?          │
│       │                             │
│       ├─ No  → Done, exit           │
│       │                             │
│       └─ Yes → Start Claude session │
│                    │                │
│                    ▼                │
│       ┌────────────────────────┐    │
│       │ Claude reads tasks.md  │    │
│       │ Picks most important   │    │
│       │ Completes ONE task     │    │
│       │ Marks it [x]           │    │
│       │ Logs to changelog      │    │
│       │ Exits                  │    │
│       └────────────────────────┘    │
│                    │                │
│                    ▼                │
│       Loop back ───┘                │
└─────────────────────────────────────┘
```

## Installation

### Prerequisites

- [Claude Code](https://github.com/anthropics/claude-code) installed
- zsh shell
- Node.js 18+

### Setup

```bash
# Clone this repo
git clone git@github.com:YOUR_USERNAME/ralph.git ~/.ralph

# Set up your API profile
cp ~/.ralph/profiles/zai.env.example ~/.ralph/profiles/zai.env
# Edit zai.env and add your API key

# Add the alias to your shell
echo "alias ralph='~/.ralph/ralph-wiggum-loop.sh'" >> ~/.zshrc
source ~/.zshrc
```

## Usage

### Basic

```bash
cd /your/project
ralph                      # Uses default Anthropic API
ralph --profile zai        # Uses z.ai backend
```

### Options

| Flag | Short | Description |
|------|-------|-------------|
| `--tasks FILE` | `-t` | Tasks file (default: tasks.md) |
| `--changelog FILE` | `-c` | Changelog file (default: CHANGELOG.md) |
| `--profile NAME` | `-p` | Load API profile (zai, default, etc.) |
| `--model MODEL` | `-m` | Model to use (opus, sonnet, haiku) |
| `--cli TOOL` | `-C` | CLI tool: claude or opencode |
| `--help` | `-h` | Show help |

### Examples

```bash
ralph --profile zai -t my-tasks.md
ralph --profile zai -m haiku
ralph -t docs/tasks.md -c docs/CHANGELOG.md
```

## Task File Format

Create a `tasks.md` in your project root:

```markdown
# Tasks

- [ ] Create user authentication system
- [ ] Add form validation to login page
- [ ] Write unit tests for auth module

## References

- Use JWT for tokens
- Follow patterns in src/middleware/auth.ts
- API docs: https://example.com/api-spec

## Notes

- Run tests with `npm test`
- Database migrations in /db/migrations
```

### Rules

- `- [ ]` = incomplete task
- `- [x]` = completed task (Claude marks these)
- Add a References section for context Claude can use
- Be specific with file paths and requirements

See [TASK_FORMAT.md](./TASK_FORMAT.md) for detailed formatting guide.

## Profiles

Profiles let you switch between API providers (Anthropic, z.ai, etc.)

```bash
# Use z.ai
ralph --profile zai

# Use default Anthropic
ralph --profile default
```

### Creating a Profile

```bash
cp ~/.ralph/profiles/template.env ~/.ralph/profiles/myprofile.env
# Edit with your API settings
ralph --profile myprofile
```

## Workflow Tips

### Stopping Mid-Task

- `Ctrl+C` stops both Claude and the loop
- Completed tasks stay marked `[x]`
- Run `ralph` again to resume from where you left off

### Manual Intervention

If you see Claude doing something wrong:

1. `Ctrl+C` to stop
2. Run `claude` directly to fix things interactively
3. Run `ralph` again to continue the loop

### Checking Progress

- Tasks marked `[x]` in `tasks.md` are complete
- `CHANGELOG.md` has a log of what was done

## File Structure

```
~/.ralph/
├── ralph-wiggum-loop.sh    # Main script
├── claude-profile.sh       # Profile switcher helper
├── TASK_FORMAT.md          # Task file formatting guide
├── README.md               # This file
└── profiles/
    ├── template.env        # Template for new profiles
    ├── zai.env.example     # z.ai example (copy to zai.env)
    └── default.env.example # Anthropic example
```

## License

Do whatever you want with it. "Me fail English? That's unpossible!"
