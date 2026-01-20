# Task File Format for Ralph Wiggum Loop

## Syntax

Use markdown checkbox syntax for each task: `- [ ] task description`

## Rules

1. One task per line
2. Be specific - include file paths, function names, or context needed
3. Order tasks by dependency if needed (or let Claude prioritize)
4. Never use `- [x]` for new tasks (reserved for completed)
5. Keep tasks atomic - one clear objective each

## References Section

You can include a references section with context, links, docs, or notes that Claude can use while working:

```markdown
# Tasks

- [ ] Implement user authentication using JWT
- [ ] Add rate limiting to the API endpoints
- [ ] Write tests for the auth module

## References

- Auth should follow the pattern in src/middleware/auth.ts
- Use the existing logger in src/utils/logger.ts
- API docs: https://example.com/api-spec
- Rate limit: 100 requests per minute per user

## Notes

- Database migrations are in /db/migrations
- Run tests with `npm test`
```

## Tips

- Put important context in the References section
- Claude will read the whole file, so add anything helpful
- Group related tasks together
- Be explicit about file paths and expected behavior
