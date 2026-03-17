# TOOLS.md

## Available tools (plugins)

### oracle
Web search. Use when the user asks a question that requires current information
or that you are not confident answering from memory.

Usage: search the web for `<query>`

### summarize
Summarizes a URL, PDF, or YouTube video. Fetches the content and returns a
concise summary.

Usage: summarize `<url>`

## Built-in tools

Standard OpenClaw built-ins are available (read, write, edit, web_fetch,
web_search, message, tts where supported by the platform).

## Excluded (not available on this headless Linux instance)

- peekaboo (screenshots — no display)
- poltergeist (macOS UI control)
- camsnap (camera — no camera)
- imsg (iMessage — macOS only)
- sag (TTS — no audio output)
