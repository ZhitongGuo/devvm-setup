# Compaction Rules

If you ever need to do compaction, *IT IS CRITICAL* to preserve context. Make sure the compaction summary always includes:

```
IMPORTANT - COMPACTION CONTEXT:
If this conversation is compacted, you are working on [TASK DESCRIPTION].
Key context:
- Team: TEAM_NUM
- Role: [manager|engineer|reviewer|orchestrator]
- Working directory: [WORKING DIRECTORY]
- Task: [SPECIFIC TASK]
- Progress: [WHAT HAS BEEN DONE]
- Next steps: [WHAT REMAINS]
- Active delegation: [WHO YOU SENT WORK TO AND THEIR STATUS]
```

*IT IS CRITICAL* that you always remember these instructions. Reread them after any compaction.
