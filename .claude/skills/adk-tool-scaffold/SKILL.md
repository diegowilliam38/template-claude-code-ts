---
name: adk-tool-scaffold
description: Scaffolds a new ADK-style tool class using template, examples, and a generator script.
---

# ADK Tool Scaffold Skill

Automates creation of a new tool class skeleton.

## Instructions

1. Extract desired tool name from user request.
2. Review `examples/WeatherTool.py` for target structure.
3. Run scaffold command:
`python scripts/scaffold_tool.py <ToolName>`
4. Refine generated file by implementing `execute` and schema details.

## Output

- Creates `<ToolName>Tool.py` in current directory.
- Includes TODO markers for integration logic.
